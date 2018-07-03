***********************************************************
*!*Ӧ�ñ��˳�ʱ
PROCEDURE __appform__exit__
LPARAMETERS oForm as Form
*-----------------------------------------------
*�벻Ҫ���Ĳ�����
*�������û�����
ENDPROC

***********************************************************
*!*Ӧ�ñ�����ʱ
PROCEDURE __appform__start__
LPARAMETERS oForm as Form
*-----------------------------------------------
*�벻Ҫ���Ĳ�����
*�������û�����


=AddProperty(oForm,"_cAppName",oForm.oAppObject.cAppName)
=AddProperty(oForm,"_cBaseTable",oForm.oAppObject.cBaseTable)
=AddProperty(oForm,"_cMAppName",oForm.oAppObject.cDataCursor)
=AddProperty(oForm,"_cTempCursor",sys(2015))
ENDPROC

***********************************************************
*!*Ӧ�÷����˳�ʱ
PROCEDURE __appobject__exit__
LPARAMETERS oAppObject as AppObject
*-----------------------------------------------
*�벻Ҫ���Ĳ�����
*�������û�����

*ʾ������
*alert("appobject exit!")

ENDPROC

***********************************************************
*!*Ӧ�÷�������ʱ
PROCEDURE __appobject__start__
LPARAMETERS oAppObject as AppObject
*-----------------------------------------------
*�벻Ҫ���Ĳ�����
*�������û�����

*ʾ������
*alert("appobject started!")

ENDPROC

***********************************************************
*!*ת���ű�����
PROCEDURE __script__translate__
LPARAMETERS cMethodCode
*--------------------------------------------------
*�������û�����

cMethodCode=strtran(cMethodCode,"this.select_value","GetValue",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.select_data","SelectData",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.exec_sql","Execute",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.closecursor","=CloseAlias",-1,-1,1)
*--------------------------------------------------
*messagebox(cmethodCode)
*����ת����Ĵ���
return cMethodCode
ENDPROC

***********************************************************
*!*ϵͳ�˳�ʱִ�еķ���
PROCEDURE __system__exit__
*ʾ������
*alert("system exited!")
ENDPROC

***********************************************************
*!*ϵͳ����ʱִ�еķ���
PROCEDURE __system__start__
*ʾ������
*alert("system started!")
=AddProperty(_screen,"_SysServer",_screen.cServer)
=AddProperty(_screen,"_SysDatabase",_screen.cDatabase)
=AddProperty(_screen,"_SysPwd",_screen.cPwd)
=AddProperty(_screen,"_SysUser",_screen.cUser)
ENDPROC

***********************************************************
*!*������
PROCEDURE alert
LPARAMETERS strMessage as String
MessageBox1(strMessage)
ENDPROC

***********************************************************
*!*����һ����ʽ
PROCEDURE CreateApplication
LPARAMETERS cAppName,cAppCaption,cRelationExp,isMasterDetail

*ʾ����CreateAppLication("�ͻ��ֵ�","�ͻ��ֵ�","",0)

messagebox("δ���ô��롾CreateApplication��",0+64,"ϵͳ��ʾ")
ENDPROC

***********************************************************
*!*����һ�����ݵ�sql�����ʽ
PROCEDURE GetSqlValue
LPARAMETERS oValue

*ʾ����GetSqlValue(ovalue)

if vartype(oValue)="C"
	return "'"+oValue+"'"
endif

if inlist(vartype(oValue),"D","T")
	return "'"+transform(oValue)+"'"
endif

if vartype(oValue)="L"
	return iif(oValue,"1","0")
endif

return transform(oValue)
ENDPROC

***********************************************************
*!*����һ���ַ�������
PROCEDURE OpenCharForm
LPARAMETERS cChar

*ʾ����OpenCharForm("����")

messagebox("δ���ù��ܴ��롾"+OpenCharForm+"�� !",0+64,"ϵͳ��ʾ")
ENDPROC

***********************************************************
*!*����һ������ѡ���
PROCEDURE OpenFormWithResult
LPARAMETERS cCommandText  ,cReturnField  

*ʾ����OpenFormWithResult("select xx from table","xx")

local oBaseMethod as Base_Method
oBaseMethod=CREATEOBJECT("Base_Method")

return oBaseMethod.open_form_with_result("frm_f7",null,cCommandText,cReturnField)
ENDPROC

***********************************************************
*!*�����ʼ�
PROCEDURE ToMail
LPARAMETERS cSendAccount,cSendName,cSendPwd,cRecipientList,cSubJect,cBody,cAttachmentList,cSmtpServer

*ʾ����TOMail("123456789@qq.com","����������","�������ʼ�����"
*				,"aa@qq.com:����,bb@qq.com:����","�ʼ�����","�ʼ�����"
*,"c:\����.xls","SMTP.QQ.COM")

messagebox("δ���ô��롾ToMail����",0+64,"ϵͳ��ʾ")
ENDPROC

***********************************************************
*!*����pdf
PROCEDURE ToPDF
LPARAMETERS cPrintName,cReportFileName,cPDFFileName,cCursorName

ʾ����TOPDF("pdf��ӡ����","��������","c:\123.pdf",this._ctempcursor)

messagebox("δ���ô��롾"+ToPDF+"����",0+64,"ϵͳ��ʾ")
ENDPROC

***********************************************************
*!*��ӡ����
PROCEDURE ToPrint
LPARAMETERS lcFrx,cCursorName
IF EMPTY(lcFrx) OR EMPTY(cCursorName)
	RETURN 
ENDIF
IF !FILE(lcFrx)
	RETURN 
ENDIF 
IF !USED(cCursorName)
	MESSAGEBOX("��ӡ���ݴ���",0+64,"ϵͳ��ʾ")
	RETURN
ENDIF 
lcFrt=JUSTPATH(lcFrx)+"\"+JUSTSTEM(lcFrx)+".Frt"

cTargeFrx="C:\"+JUSTSTEM(lcFrx)+".frx"
cTargeFrt="C:\"+JUSTSTEM(lcFrt)+".frt"
IF FILE(cTargeFrx)
	DELETE FILE (cTargeFrx)
ENDIF 
IF FILE(cTargeFrt)
	DELETE FILE (cTargeFrt)
ENDIF 
COPY FILE (lcFrx) TO (cTargeFrx)
COPY FILE (lcFrt) TO (cTargeFrt)
Select 0
Use (cTargeFrx) IN 0 ALIAS mFrx Exclusive Again
Replace expr With ''	,tag With '',tag2 With '' For objtype = 1 And objcode = 53
Go Top
Use
SELECT (cCursorName)
keyboard "{CTRL+F10}"
SET PRINTER TO NAME GETPRINTER( )
=SYS(1037)
report form (cTargeFrx) TO PRINTER PROMPT PREVIEW 
IF FILE(cTargeFrx)
	DELETE FILE (cTargeFrx)
ENDIF 
IF FILE(cTargeFrt)
	DELETE FILE (cTargeFrt)
ENDIF
ENDPROC

