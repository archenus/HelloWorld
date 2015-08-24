<%@ page contentType="text/html; charset=euc-kr"%>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="kr.co.nicepay.pgweb.util.PGWASLogger" %>
<%@ page import="mup.mcash.module.common.McashCipher"%>
<%
	/*********************************************************************************
	* ���� ������ �� ������ ��ȯ���� ȣ��Ǵ� �������̸� ���������� �����ؾ��ϴ� ȭ���Դϴ�.
	* ��ȣȭ ����  �ʼ� Ŭ����  
	* mup.mcash.module.common.McashCipher.class 
	* mup.mcash.module.common.McashSeed.class
	*********************************************************************************/
	PGWASLogger logger = new PGWASLogger(request);
	logger.debug("[BILLKEY_MOB] ��Ű �߱� ��û (�����Է�) ==========================");

	String Svcid		= request.getParameter("Svcid");        //���񽺾��̵�
	String Mobilid		= request.getParameter("Mobilid");      //������� �ŷ���ȣ
	String Signdate		= request.getParameter("Signdate");     //��������
	String Tradeid		= request.getParameter("Tradeid");      //������ �ŷ���ȣ
	
	String Name			= request.getParameter("Name");         //�̸�
	String No			= request.getParameter("No");           //�޴�����ȣ
	String Commid		= request.getParameter("Commid");       //�̵���Ż�
	String Resultcd		= request.getParameter("Resultcd");     //����ڵ�
	String Resultmsg	= request.getParameter("Resultmsg");    //����޽���
	
	String Socialno		= request.getParameter("Socialno");     //�������
	String Sex			= request.getParameter("Sex");          //���� (����:M, ����:F)
	String Foreigner	= request.getParameter("Foreigner");    //�ܱ��ο��� (�ܱ��� : Y)
	
	String Ci			= request.getParameter("Ci");           //CI
	String Di			= request.getParameter("Di");           //DI
	
	String CI_Mode		= request.getParameter("CI_Mode");      //CI_Mode 41:LMS��������, 51:SMS��������, 61:SMS�߼�
	String DI_Code		= request.getParameter("DI_Code");      //������Ʈ�ڵ�
	String Mac			= request.getParameter("Mac");          //����Ű
	
	/*********************************************************************************
	* MSTR�� ������ Ȯ�� ������ "|"��ȣ�� �������� ���ڿ��� �����ؼ� ���������� �ʿ��� ������ ��´�.
	* MallReserved�� �� Ȯ�� ������ MSTR�� ����.
	*********************************************************************************/
	String MSTR				= request.getParameter("MSTR");		//������ Ȯ�� ����
	String[] arrMSTR = MSTR.split("\\|");
	
	String MID				= arrMSTR[0];						//������ ID
	String Moid				= arrMSTR[1];						//������ �ֹ� ID
	String GoodsName		= arrMSTR[2];						//��ǰ��
	String Amt				= arrMSTR[3];						//��ǰ����
	String CardQuota		= arrMSTR[4];						//��ǰ����
	String BuyerName		= arrMSTR[5];						//������ �̸�
	String BuyerTel			= arrMSTR[6];						//������ ��ȭ��ȣ
	String BuyerEmail		= arrMSTR[7];						//������ �̸���
	String ReturnUrl		= arrMSTR[8];						//����� ���� URL
	String MallReserved		= "";								//�� Ȯ�� ����

	for(int i=9;i<arrMSTR.length;i++) {
		MallReserved = MallReserved + arrMSTR[i];
		if(i != (arrMSTR.length-1)) {
			MallReserved = MallReserved + "|";
		}
	}
	
	/*********************************************************************************
	* Okurl ��ȣȭ ��� �� ��������� ��ȣ�� ����
	* ��) ���Ű�� ���������� ������ �ŷ���ȣ(Tradeid)�� ������� �ŷ���ȣ(Mobilid)���� ����
	*	��ȣ���� �����Ǿ� ���޵� ��� �� Mac���� ��ġ���� ���� ��� �� ���� ���� ������ �Ǵ�
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
<title>���̽��������</title>
<script>
function checkLength(num,here,next) {
    var str = here.value.length;
    if(str == num )
        next.focus();
}
function goPay() {
    var objForm = document.bForm;
    objForm.CardNo.value = objForm.cn1.value + objForm.cn2.value + objForm.cn3.value + objForm.cn4.value;   //ī���ȣ 16�ڸ�
/*     if (document.bForm.BuyerEmail.value == "") {
        alert ("�̸����� �Է����ּ���!")
    } else { */
	if(objForm.CardNo.value.length < 14) {
		alert("ī���ȣ �ڸ����� Ȯ���� �ֽʽÿ�.");

		return;
	}

	if(objForm.bpass.value.length < 2) {
		alert("��й�ȣ 2�ڸ��� �Է��� �ֽʽÿ�.");

		return;
	}

		
	if (document.bForm.paycorfirm.checked) {
		document.getElementById("nextbtn").disabled = true;
		document.bForm.method = "POST";
		//document.bForm.action = "../result.jsp";
		document.bForm.action = "https://web.nicepay.co.kr/billing/result.jsp";
		document.bForm.submit();
	} else {
		alert("����� �������ּ���.");
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
				<li class="cardinfo">
					<div class="top">
						ī������
					</div>
					<div class="conwrap">
						<div class="con">
							<div class="tabletypea">
								<table>
									<colgroup><col width="30%" /><col width="*" /></colgroup>
									<tr>
										<th><span>ī���ȣ</span></th>
										<td>
											<input type="text" id="cn1" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4"/>
											<input type="password" id="cn2" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" />
											<input type="password" id="cn3" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" /> 
											<input type="text" id="cn4" style="width:23%; height:25px; border:1px solid #cccccc;" maxlength="4" />
										</td>
									</tr>
									<tr>
										<th><span>��ȿ�Ⱓ</span></th>
										<td>
											<span class="selbox selecta" style="width:30%">
												<select name="mm">
													<option>��</option>
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
													<option>�⵵</option>
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
										<th><span>��й�ȣ</span></th>
										<td>
											<input name="bpass" type="password" class="intypea" placeholder="�Է����ּ���.  XX (�� 2�ڸ�)" style="width:90%;" maxlength="2"/>
										</td>
									</tr>
									<tr>
										<th><span>�̸���</span></th>
										<td>
											<input name="BuyerEmail" type="text" class="intypea" value="<%=BuyerEmail %>" style="width:90%;" maxlength="30"/>
										</td>
									</tr>
								</table>
							</div>
						</div>
						<div class="pay_area">
							<label class="chkcon" for="paycorfirm"><input id= "paycorfirm" type="checkbox" /><span class="txt">��� ���� ������ Ȯ��  �Ͽ����ϴ�</span></label><br />
							<div class="tac">
								<a id="nextbtn" href="#" onClick="javascript:goPay();" class="btn_blue v2 mt15">Ȯ��</a>
							</div>
						</div>
					</div>
				</li>

			</ul>
		</div>
		<!--//�̿�������, ����ī������, ������� ��������-->
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