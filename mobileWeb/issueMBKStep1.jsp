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
	logger.debug("[BILLKEY_MOB] ��Ű �߱� ��û (�������) ==========================");
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - Step1 loading success.");
	logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - PayMethod :" + PayMethod);
	
 
		logger.debug("[BILLKEY_MOB] " + MID + " (" + Moid + ") - KG Mobilians");
		
		SimpleDateFormat yyyyMMdd = new SimpleDateFormat("yyyyMMdd");
		SimpleDateFormat HHmmss = new SimpleDateFormat("HHmmss");
		
		String pg_req_date = yyyyMMdd.format(new java.util.Date());                // 11. PG�� ��û����
		String pg_req_time =  HHmmss.format(new java.util.Date().getTime());       // 12. PG�� ��û�ð�
		String Tradeid = MID+pg_req_date+pg_req_time;                              // 28. ������ ���� �ŷ��ĺ���ȣ(�ֹ���ȣ)
		
		/*****************************************************************************************
		- �������� ĳ�� ����
		*****************************************************************************************/
		String CASH_GB      = "CI";     //��ǥ��������
		
		/*****************************************************************************************
		- �ʼ� �Է� �׸� 
		*****************************************************************************************/
		String PAY_MODE     = "10";     //������ �׽�Ʈ,�ǰ������� ( 00 : �׽�Ʈ����, 10 : �ǰŷ�����   )
		String Siteurl      = "web.nicepay.co.kr";      //������������
		
		String CI_SVCID     = "150303960001";       //���񽺾��̵�
		String CI_Mode      = "61";     // 61:SMS�߼�  67:SMS�̹߼�
		
		
		String Okurl        = "http://web.nicepay.co.kr/billing/mobileWeb/issueMBKStep2.jsp";     //����URL(����) : �����Ϸ��뺸������ full Url (��:http://test.mobilians.co.kr/MUP/mcash/ci/okurl.jsp )    
		
		if("TEST".equals(IsTest)) {
			Okurl        = "http://172.31.61.90:9090/billing/mobileWeb/issueMBKStep2.jsp";     //����URL(�׽�Ʈ)
		}

		/*****************************************************************************************
		- ���� �Է� �׸� 
		*****************************************************************************************/  
		String Failurl      = "http://web.nicepay.co.kr/billing/mobileWeb/issueMBKStep2.jsp";         //����URL(����) : �������н��뺸������ full Url (��:http://www.mcash.co.kr/failurl.jsp )
		if("TEST".equals(IsTest)) {
			Failurl      = "http://172.31.61.90:9090/billing/mobileWeb/issueMBKStep2.jsp";         //����URL(�׽�Ʈ)
		}
		

		//����ó���� ���� ����ó�� �ȳ��� ���������� �����ؾ� �� ��츸 ��� 
		 
		String MSTR         = MID+"|"+Moid+"|"+GoodsName+"|"+Amt+"|"+CardQuota+"|"+BuyerName+"|"+BuyerTel+"|"+BuyerEmail+"|"+ReturnUrl+"|"+MallReserved;      //�������ݹ麯��
		                                //���������� �߰������� �Ķ���Ͱ� �ʿ��� ��� ����ϸ� &, % �� ���Ұ� ( �� : MSTR="a=1|b=2|c=3" ) 
		                                //MallReserved�� MSTR�� ��������
		/*****************************************************************************************
		 - ������ ���� �����׸� ( ����  ����� �� �ֽ��ϴ�  )
		*****************************************************************************************/
		String LOGO_YN      = "N";      //������ �ΰ� ��뿩��  ( ������ �ΰ� ���� 'Y'�� ����, ������ ������𽺿� ������ �ΰ� �̹����� �־����  )
		String CALL_TYPE    = "SELF";       //����â ȣ����( SELF ��������ȯ , P �˾� ) 

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
<title>���̽��������</title>
<script>
function goPay() {
	if (document.payForm.paycorfirm.checked) {	// ������� üũ
		if("MOBILE_BILLING"=='<%=PayMethod%>'){ // �޴��� ������ ���
			//document.bForm.action = "requestGlxyBilling.jsp";
		}
		MCASH_PAYMENT(document.payForm);
	} else {
		alert("����� �������ּ���.");
	}
}

</script>
</head>
<body class="bilky">
<form name="payForm" method="post" target="issueMBKStep2.jsp">
	<!--header-->
	<header>
		<h1><a href="#">NICEPAY</a></h1>
		<span class="title">�ſ�ī�� ����</span>
		<a href="#" class="question">?</a>
	</header>
	<!--//header-->

	<!--container-->
	<section id="container">
		<!--������ ��ǰ����-->
		<div class="productinfo_area">
			<ul class="productinfo_list">
				<li>
					<span class="tit">��ǰ��</span>
					<span class="detail"><%=GoodsName %></span>
				</li>
				<li>
					<span class="tit">�����ݾ�</span>
					<span class="detail price"><%=Amt %></span>
				</li>
				<li>
					<span class="tit">�����ڸ�</span>
					<span class="detail"><%=BuyerName %></span>
				</li>
			</ul>
		</div>
		<!--//������ ��ǰ����-->
		<!--�̿�������, ����ī������, ������� ��������-->
		<div class="payinfo_area">
			<p class="bilky_tit"><span></span>������� ����</p>
			<ul class="payinfo_list">
				<li class="agree cnt">
					<div class="top">
						�̿��� ����
					</div>
					<div class="conwrap">
						<div class="con">
							<div class="bilkyagree_txt">
								����������޹�ħ<br /><br />
								���ϰ� ��û�Ͻ� �ſ�ī�� ������� ������ ���̽� 
								�������(��)���� �����ϴ� ���񽺷�, ������ �ſ�ī�� 
								������������ �̿밡������ NICE�� ǥ��˴ϴ�.
								����, ���̽�������Ţߴ� ������� �������ุ ����
								�ϹǷ�, ������� ������û �� ���� �� ��� ������
								�ش� ���ͳ� ������ ���� ���� ��û�ϼž� �մϴ�.<br /><br />
								���̽�������Ţߴ� ������ �� ��û�� ������ �ŷ�
								������ e-mail�� �뺸 �帮��, ��� Ȩ������ (http://
								home.nicepay.co.kr)������ ��ȸ���񽺸� �����մϴ�.<br /><br />
								���̽��������(��)�� ��ȸ ���� �⺻ ����������
								���� �ʿ��� �ּ� ����(����, �̸���)���� �����ϰ�
								�ֽ��ϴ�.<br /><br />
								
							</div>
							<div class="bilkytxt">�Ʒ� ������뿡 ���Ǹ� �Ͻ� ���, �ſ�ī�� ������� ���� ��û�� ����˴ϴ�. </div>
							<label class="chkcon" for="paycorfirm"><input id= "paycorfirm" type="checkbox" /><span class="txt">�� ��� ���뿡 �����Ͽ����ϴ�</span></label><br />
						</div>
					</div>
				</li>

			</ul>
		</div>
		<div class="pay_area">
			<div class="tac">
				<a href="#" onClick="goPay();"  class="btn_blue v2 mt15">Ȯ��</a>
			</div>
		</div>
		<!--//�̿�������, ����ī������, ������� ��������-->
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
