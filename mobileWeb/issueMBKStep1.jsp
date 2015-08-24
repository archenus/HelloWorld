<%@ page contentType="text/html; charset=euc-kr"%>
<%@ page import="kr.co.nicepay.pgweb.util.PGWASLogger" %>
<%@ include file="../ipgwebCommon.jsp" %>
<%
	String MID 			= request.getParameter("MID");
	String Moid 		= request.getParameter("Moid");
	String GoodsName	= request.getParameter("GoodsName");
	String BuyerName	= request.getParameter("BuyerName");
	String BuyerTel		= request.getParameter("BuyerTel");
	String BuyerEmail	= request.getParameter("BuyerEmail");
	String ReturnUrl	= request.getParameter("ReturnUrl");
	String MallReserved	= request.getParameter("MallReserved");
	String IsTest		= request.getParameter("IsTest");
	

	String GoodsCl		= getDefaultStr(request.getParameter("GoodsCl"),"0");
	String PayMethod	= getDefaultStr(request.getParameter("PayMethod"),"CARD");
	String Amt			= getDefaultStr(request.getParameter("Amt"),"1004");
	String CardQuota	= getDefaultStr(request.getParameter("CardQuota"),"00");
	
	PGWASLogger logger = new PGWASLogger(request);
	logger.debug("[BILLKEY_MOB] 빌키 발급 요청 (약관동의) ==========================");
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - Step1 loading success.");
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - PayMethod :" + PayMethod);
	
 
		logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - KG Mobilians");
		
		SimpleDateFormat yyyyMMdd = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat HHmmss = new SimpleDateFormat("HHmmss");
		
		String pg_req_date = yyyyMMdd.format(new java.util.Date());                // 11. PG사 요청일자
		String pg_req_time =  HHmmss.format(new java.util.Date().getTime());       // 12. PG사 요청시각
		String Tradeid = MID+pg_req_date+pg_req_time;                              // 28. 가맹점 고유 거래식별번호(주문번호)
		
		/*****************************************************************************************
		- 결제수단 캐시 구분
		*****************************************************************************************/
		String CASH_GB      = "CI";     //대표결제수단
		
		/*****************************************************************************************
		- 필수 입력 항목 
		*****************************************************************************************/
		String PAY_MODE     = "10";     //연동시 테스트,실결제구분 ( 00 : 테스트결제, 10 : 실거래결제   )
		String Siteurl      = "web.nicepay.co.kr";      //가맹점도메인
		
		String CI_SVCID     = "150303960001";       //서비스아이디
		String CI_Mode      = "61";     // 61:SMS발송  67:SMS미발송
		
		
		String Okurl        = "http://web.nicepay.co.kr/billing/mobileWeb/issueMBKStep2.jsp";     //성공URL(리얼) : 결제완료통보페이지 full Url (예:http://test.mobilians.co.kr/MUP/mcash/ci/okurl.jsp )    
		
		if("TEST".equals(IsTest)) {
			Okurl        = "http://172.31.61.90:9090/billing/mobileWeb/issueMBKStep2.jsp";     //성공URL(테스트)
		}

		/*****************************************************************************************
		- 선택 입력 항목 
		*****************************************************************************************/  
		String Failurl      = "http://web.nicepay.co.kr/billing/mobileWeb/issueMBKStep2.jsp";         //실패URL(리얼) : 결제실패시통보페이지 full Url (예:http://www.mcash.co.kr/failurl.jsp )
		if("TEST".equals(IsTest)) {
			Failurl      = "http://172.31.61.90:9090/billing/mobileWeb/issueMBKStep2.jsp";         //실패URL(테스트)
		}
		

		//결제처리에 대한 실패처리 안내를 가맹점에서 제어해야 할 경우만 사용 
		 
		String MSTR         = MID+"|"+Moid+"|"+GoodsName+"|"+Amt+"|"+CardQuota+"|"+BuyerName+"|"+BuyerTel+"|"+BuyerEmail+"|"+ReturnUrl+"|"+MallReserved;      //가맹점콜백변수
		                                //가맹점에서 추가적으로 파라미터가 필요한 경우 사용하며 &, % 는 사용불가 ( 예 : MSTR="a=1|b=2|c=3" ) 
		                                //MallReserved는 MSTR의 마지막에
		/*****************************************************************************************
		 - 디자인 관련 선택항목 ( 향후  변경될 수 있습니다  )
		*****************************************************************************************/
		String LOGO_YN      = "N";      //가맹점 로고 사용여부  ( 가맹점 로고 사용시 'Y'로 설정, 사전에 모빌리언스에 가맹점 로고 이미지가 있어야함  )
		String CALL_TYPE    = "SELF";       //결제창 호출방식( SELF 페이지전환 , P 팝업 ) 

%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr;"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=yes, target-densitydpi=medium-dpi" />
<link rel="stylesheet" type="text/css" href="./common/css/import.css"/>
<script type="text/javascript" src= "./common/js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="./common/js/jquery.pajinate.js"></script>
<script type="text/javascript" src= "./common/js/script.js"></script>
<script src="https://auth.mobilians.co.kr/js/ext/ext_inc_comm.js"></script>
<title>나이스정보통신</title>
<script>
function goPay() {
	if (document.payForm.paycorfirm.checked) {	// 약관동의 체크
		if("MOBILE_BILLING"=='<%=PayMethod%>'){ // 휴대폰 빌링일 경우
			//document.bForm.action = "requestGlxyBilling.jsp";
		}
		MCASH_PAYMENT(document.payForm);
	} else {
		alert("약관에 동의해주세요.");
	}
}

</script>
</head>
<body class="bilky">
<form name="payForm" method="post" target="issueMBKStep2.jsp">
	<!--header-->
	<header>
		<h1><a href="#">NICEPAY</a></h1>
		<span class="title">신용카드 결제</span>
		<a href="#" class="question">?</a>
	</header>
	<!--//header-->

	<!--container-->
	<section id="container">
		<!--구입한 상품정보-->
		<div class="productinfo_area">
			<ul class="productinfo_list">
				<li>
					<span class="tit">상품명</span>
					<span class="detail"><%=GoodsName %></span>
				</li>
				<li>
					<span class="tit">결제금액</span>
					<span class="detail price"><%=Amt %></span>
				</li>
				<li>
					<span class="tit">구매자명</span>
					<span class="detail"><%=BuyerName %></span>
				</li>
			</ul>
		</div>
		<!--//구입한 상품정보-->
		<!--이용약관동의, 결제카드정보, 정기과금 결제정보-->
		<div class="payinfo_area">
			<p class="bilky_tit"><span></span>정기과금 서비스</p>
			<ul class="payinfo_list">
				<li class="agree cnt">
					<div class="top">
						이용약관 동의
					</div>
					<div class="conwrap">
						<div class="con">
							<div class="bilkyagree_txt">
								개인정보취급방침<br /><br />
								귀하가 신청하신 신용카드 정기과금 결제는 나이스 
								정보통신(주)에서 제공하는 서비스로, 귀하의 신용카드 
								결제내역에는 이용가맹점이 NICE로 표기됩니다.
								또한, 나이스정보통신㈜는 정기과금 결제대행만 제공
								하므로, 정기과금 결제신청 및 해지 등 모든 업무는
								해당 인터넷 상점을 통해 직접 요청하셔야 합니다.<br /><br />
								나이스정보통신㈜는 귀하의 본 신청과 관련한 거래
								내역을 e-mail로 통보 드리며, 당사 홈페이지 (http://
								home.nicepay.co.kr)에서도 조회서비스를 제공합니다.<br /><br />
								나이스정보통신(주)는 조회 등의 기본 서비스제공을
								위해 필요한 최소 정보(성명, 이메일)만을 보관하고
								있습니다.<br /><br />
								
							</div>
							<div class="bilkytxt">아래 약관내용에 동의를 하실 경우, 신용카드 정기과금 서비스 신청이 진행됩니다. </div>
							<label class="chkcon" for="paycorfirm"><input id= "paycorfirm" type="checkbox" /><span class="txt">위 약관 내용에 동의하였습니다</span></label><br />
						</div>
					</div>
				</li>

			</ul>
		</div>
		<div class="pay_area">
			<div class="tac">
				<a href="#" onClick="goPay();"  class="btn_blue v2 mt15">확인</a>
			</div>
		</div>
		<!--//이용약관동의, 결제카드정보, 정기과금 결제정보-->
	</section>
	<!--//container-->
	
	<input type="hidden" name="CASH_GB" value="<%=CASH_GB %>" />
	<input type="hidden" name="CI_SVCID" value="<%=CI_SVCID%>" />
	<input type="hidden" name="CALL_TYPE" value="<%=CALL_TYPE %>" />
	<input type="hidden" name="LOGO_YN" value="<%=LOGO_YN %>" />
	<input type="hidden" name="CI_Mode" value="<%=CI_Mode %>" />
	<input type="hidden" name="Siteurl" value="<%=Siteurl %>" />
	<input type="hidden" name="Tradeid" value="<%=Tradeid %>" />
	<input type="hidden" name="PAY_MODE" value="<%=PAY_MODE %>" />
	<input type="hidden" name="Okurl" value="<%=Okurl %>" />
	<input type="hidden" name="Failurl" value="<%=Failurl %>" />
	<input type="hidden" name="MSTR" value="<%=MSTR %>" />
	<input type="hidden" name="CONTRACT_HIDDEN" value="N" />
</form>
</body>
</html>
