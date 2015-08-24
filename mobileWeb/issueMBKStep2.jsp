<%@ page contentType="text/html; charset=euc-kr"%>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="kr.co.nicepay.pgweb.util.PGWASLogger" %>
<%@ page import="mup.mcash.module.common.McashCipher"%>
<%
	/*********************************************************************************
	* 인증 성공시 웹 페이지 전환으로 호출되는 페이지이며 가맹점에서 구현해야하는 화면입니다.
	* 암호화 사용시  필수 클래스  
	* mup.mcash.module.common.McashCipher.class 
	* mup.mcash.module.common.McashSeed.class
	*********************************************************************************/
	PGWASLogger logger = new PGWASLogger(request);
	logger.debug("[BILLKEY_MOB] 빌키 발급 요청 (정보입력) ==========================");

	String Svcid		= request.getParameter("Svcid");        //서비스아이디
	String Mobilid		= request.getParameter("Mobilid");      //모빌리언스 거래번호
	String Signdate		= request.getParameter("Signdate");     //결제일자
	String Tradeid		= request.getParameter("Tradeid");      //가맹점 거래번호
	
	String Name			= request.getParameter("Name");         //이름
	String No			= request.getParameter("No");           //휴대폰번호
	String Commid		= request.getParameter("Commid");       //이동통신사
	String Resultcd		= request.getParameter("Resultcd");     //결과코드
	String Resultmsg	= request.getParameter("Resultmsg");    //결과메시지
	
	String Socialno		= request.getParameter("Socialno");     //생년월일
	String Sex			= request.getParameter("Sex");          //성별 (남성:M, 여성:F)
	String Foreigner	= request.getParameter("Foreigner");    //외국인여부 (외국인 : Y)
	
	String Ci			= request.getParameter("Ci");           //CI
	String Di			= request.getParameter("Di");           //DI
	
	String CI_Mode		= request.getParameter("CI_Mode");      //CI_Mode 41:LMS문구설정, 51:SMS문구설정, 61:SMS발송
	String DI_Code		= request.getParameter("DI_Code");      //웹사이트코드
	String Mac			= request.getParameter("Mac");          //검증키
	
	/*********************************************************************************
	* MSTR은 가맹점 확장 변수로 "|"기호를 기준으로 문자열을 분해해서 가맹점에서 필요한 정보를 얻는다.
	* MallReserved는 몰 확장 변수로 MSTR과 동일.
	*********************************************************************************/
	String MSTR				= request.getParameter("MSTR");		//가맹점 확장 변수
	String[] arrMSTR = MSTR.split("\\|");
	
	String MID				= arrMSTR[0];						//가맹점 ID
	String Moid				= arrMSTR[1];						//가맹점 주문 ID
	String GoodsName		= arrMSTR[2];						//상품명
	String Amt				= arrMSTR[3];						//상품가격
	String CardQuota		= arrMSTR[4];						//상품가격
	String BuyerName		= arrMSTR[5];						//구매자 이름
	String BuyerTel			= arrMSTR[6];						//구매자 전화번호
	String BuyerEmail		= arrMSTR[7];						//구매자 이메일
	String ReturnUrl		= arrMSTR[8];						//결과값 리턴 URL
	String MallReserved		= "";								//몰 확장 변수

	for(int i=9;i<arrMSTR.length;i++) {
		MallReserved = MallReserved + arrMSTR[i];
		if(i != (arrMSTR.length-1)) {
			MallReserved = MallReserved + "|";
		}
	}
	
	/*********************************************************************************
	* Okurl 암호화 사용 시 사용자정보 암호문 전달
	* 주) 비밀키는 가맹점에서 전달한 거래번호(Tradeid)와 모빌리언스 거래번호(Mobilid)에서 추출
	*	암호문이 변조되어 전달된 경우 및 Mac값이 일치하지 않을 경우 비 정상 인증 건으로 판단
	*********************************************************************************/
	Name			= McashCipher.decodeString( Name, Tradeid+Mobilid );
	No				= McashCipher.decodeString( No, Tradeid+Mobilid );
	Commid			= McashCipher.decodeString( Commid, Tradeid+Mobilid );
	Socialno		= McashCipher.decodeString( Socialno, Tradeid+Mobilid );
	Sex				= McashCipher.decodeString( Sex, Tradeid+Mobilid );
	Foreigner		= McashCipher.decodeString( Foreigner, Tradeid+Mobilid );
	Ci				= McashCipher.decodeString( Ci, Tradeid+Mobilid );
	Di				= McashCipher.decodeString( Di, Tradeid+Mobilid );
	
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - Step2 loading success.");
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - COMMID: "+Commid);

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
function checkLength(num,here,next) {
    var str = here.value.length;
    if(str == num )
        next.focus();
}
function goPay() {
    var objForm = document.bForm;
    objForm.CardNo.value = objForm.cn1.value + objForm.cn2.value + objForm.cn3.value + objForm.cn4.value;   //카드번호 16자리
/*     if (document.bForm.BuyerEmail.value == "") {
        alert ("이메일을 입력해주세요!")
    } else { */
	if(objForm.CardNo.value.length < 14) {
		alert("카드번호 자리수를 확인해 주십시오.");

		return;
	}

	if(objForm.bpass.value.length < 2) {
		alert("비밀번호 2자리를 입력해 주십시오.");

		return;
	}

		
	if (document.bForm.paycorfirm.checked) {
		document.getElementById("nextbtn").disabled = true;
		document.bForm.method = "POST";
		//document.bForm.action = "../result.jsp";
		document.bForm.action = "https://web.nicepay.co.kr/billing/result.jsp";
		document.bForm.submit();
	} else {
		alert("약관에 동의해주세요.");
	}
/*     }   */
}

</script>
</head>
<body class="bilky">
<form name="bForm" method="post">
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
				<li class="cardinfo">
					<div class="top">
						카드정보
					</div>
					<div class="conwrap">
						<div class="con">
							<div class="tabletypea">
								<table>
									<colgroup><col width="30%" /><col width="*" /></colgroup>
									<tr>
										<th><span>카드번호</span></th>
										<td>
											<input type="text" id="cn1" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4"/>
											<input type="password" id="cn2" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" />
											<input type="password" id="cn3" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" /> 
											<input type="text" id="cn4" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" />
										</td>
									</tr>
									<tr>
										<th><span>유효기간</span></th>
										<td>
											<span class="selbox selecta" style="width:30%">
												<select name="mm">
													<option>월</option>
													<option value="01">1</option>
													<option value="02">2</option>
													<option value="03">3</option>
													<option value="04">4</option>
													<option value="05">5</option>
													<option value="06">6</option>
													<option value="07">7</option>
													<option value="08">8</option>
													<option value="09">9</option>
													<option value="10">10</option>
													<option value="11">11</option>
													<option value="12">12</option>
													
												</select>
											</span>
											<span class="selbox selecta ml5"  style="width:40%">
												<select name="yy">
													<option>년도</option>
													<option value="15">2015</option>
													<option value="16">2016</option>
													<option value="17">2017</option>
													<option value="18">2018</option>
													<option value="19">2019</option>
													<option value="20">2020</option>
													<option value="21">2021</option>
													<option value="22">2022</option>
													<option value="23">2023</option>
													<option value="24">2024</option>
													<option value="25">2025</option>
												</select>
											</span>
										</td>
									</tr>
									<tr>
										<th><span>비밀번호</span></th>
										<td>
											<input name="bpass" type="password" class="intypea" placeholder="입력해주세요.  XX (앞 2자리)" style="width:90%;" maxlength="2"/>
										</td>
									</tr>
									<tr>
										<th><span>이메일</span></th>
										<td>
											<input name="BuyerEmail" type="text" class="intypea" value="<%=BuyerEmail %>" style="width:90%;" maxlength="30"/>
										</td>
									</tr>
								</table>
							</div>
						</div>
						<div class="pay_area">
							<label class="chkcon" for="paycorfirm"><input id= "paycorfirm" type="checkbox" /><span class="txt">상기 결제 내용을 확인  하였습니다</span></label><br />
							<div class="tac">
								<a id="nextbtn" href="#" onClick="javascript:goPay();" class="btn_blue v2 mt15">확인</a>
							</div>
						</div>
					</div>
				</li>

			</ul>
		</div>
		<!--//이용약관동의, 결제카드정보, 정기과금 결제정보-->
	</section>
	<!--//container-->
	
	
	<input type="hidden" name="MID" value="<%=MID %>" />
	<input type="hidden" name="Moid" value="<%=Moid %>" />
	<input type="hidden" name="GoodsName" value="<%=GoodsName %>" />
	<input type="hidden" name="BuyerName" value="<%=BuyerName %>" />
	<input type="hidden" name="BuyerTel" value="<%=BuyerTel %>" />
	<input type="hidden" name="ReturnUrl" value="<%=ReturnUrl %>" />
	<input type="hidden" name="MallReserved" value="<%=MallReserved %>" />
	<input type="hidden" name="Socialno" value="<%=Socialno %>"/>
	<input type="hidden" name="Amt" value="<%=Amt %>"/>
	<input type="hidden" name="Amt" value="<%=CardQuota %>"/>
	<input type="hidden" name="App_co" value="<%=Commid %>"/>
	<input type="hidden" name="Hpp_no" value="<%=No %>"/>
	<input type="hidden" name="Result_cd" value="<%=Resultcd %>"/>
	<input type="hidden" name="CardNo" value="" />
</form>
</body>
</html>