*!*��ʽ��������ʾ
Procedure Format_Error
	Local arrayError(7)
	= Aerror(arrayError)
	Local nError , cErrorMsg
	nError = arrayError(1)
	cErrorMsg = ""
	Local cErrorType
	Do Case
		Case nError = 1526
			cErrorType = "���ݿ����"
			Local cSQLError
			cSQLError=arrayError(3)
			If !Empty(Strextract(cSQLError,"{b}","{e}"))
				cSQLError=Strextract(cSQLError,"{b}","{e}")
			Endif
			cErrorMsg = cErrorMsg + cSQLError
		Case nError = 1427 .Or. nError = 1429
			cErrorType = "OLE����"
			cErrorMsg = cErrorMsg + arrayError(3) + Chr(10) + "Ӧ�ó������ƣ�" + arrayError(4) + Chr(10) + "������Ϣ��" + Iif(Isnull(arrayError(5)),"��",arrayError(5)) + Chr(10) + "������Ϣ���ݣ�" + Iif(Isnull(arrayError(6)),"��",arrayError(6)) + Chr(10) + "OLE����ţ�" + Alltrim(Str(arrayError(7)))
		Otherwise
			cErrorType = "��������"
			cErrorMsg = cErrorMsg + arrayError(2)
	Endcase
	cErrorMsg = cErrorType + Chr(10) + Chr(10) + cErrorMsg
	Return cErrorMsg
ENDPROC

*!*�������
Procedure OnError
	*!*�ϱ�����
	IF !_screen.bShowError
		RETURN
	ENDIF
	Local cErrorMessage
	cErrorMessage=Message()
	*!*ֻ��ʾ���ݿ�������������Զ�����
	LOCAL __nLines__
	__nLines__=ALINES(__arr__,cErrorMessage)
	IF __nLines__>=1
		LOCAL __cLine__
		__cLine__=__arr__[1]
		IF ALLTRIM(__cLine__)=="���ݿ����"
			MessageBox1(cErrorMessage,0+64,"�����쳣����")
		ELSE
			IF _screen.IsDebug
				IF MessageBox1(cErrorMessage+REPLICATE(CHR(13)+CHR(10),2)+"�Ƿ����ִ�У�",1+32,"ϵͳ�쳣")<>1
					CANCEL 
				ENDIF 
			ENDIF 
		ENDIF 
	ENDIF 
	
	cErrorMessage=CHR(13)+CHR(10)+"------------------------------------------------------"
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "�ͻ���/ʱ�䣺" + SYS(0) + "/" + TIME()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "����ţ�" + TRANSFORM(ERROR())
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "������Ϣ��" + MESSAGE()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "Դ���룺" + MESSAGE(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "��������" + PROGRAM(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "�����У�" + TRANSFORM(LINENO(1))
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "------------------------------------------------------"
	*!*�ϱ�����
	IF _screen.bReportError
		=ReportError(cErrorMessage)
		_screen.bReportError=.f.
	ENDIF
ENDPROC

*!*��¼���󱨸�
Procedure ReportError
	Lparameters cErrorMessage As String
	*!*�ռ����һ��SQL���
	If Vartype(cErrorMessage)<>"C"
		cErrorMessage=""
	ENDIF
	LOCAL cLastScript
	cLastScript=_screen.cLastScript
	*!*�ռ��ͻ�����ص���Ϣ
	LOCAL cClientInfo
	cClientInfo="�ͻ�����Ϣ��"
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "�汾�ţ�" + _screen.cVersion
	*�ռ������롢��Ʒ��Կ
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "�����룺" + GetMCode()
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "ʶ���룺" + GetPCode()
	*!*�ʼ�����
	LOCAL cMailBody
	cMailBody=cClientInfo+CHR(13)+CHR(10)+cErrorMessage+CHR(13)+CHR(10)+"���ִ�е�SQL��䣺"+CHR(13)+CHR(10)+_screen.cLastSQL+REPLICATE(CHR(13)+CHR(10),4)+"���ִ�еĽű����룺"+CHR(13)+CHR(10)+cLastScript
	LOCAL cErrorFile
	cErrorFile=ADDBS(_screen.cRootPath)+"ERROR.txt"
	=STRTOFILE(cMailBody,cErrorFile)
	*!*�ռ���������ʱ�Ľ�ͼ
	CLEAR RESOURCES
	Local cScreenImage
	cScreenImage=SnapScreen()
	LOCAL cErrorImageFile
	cErrorImageFile=ADDBS(_screen.cRootPath)+"ERROR.png"
	IF FILE(cErrorImageFile)
		ERASE (cErrorImageFile)
	ENDIF
	=STRTOFILE(cScreenImage,cErrorImageFile)
	IF FILE(cErrorImageFile)
		LOCAL cBugExeFile
		cBugExeFile=ADDBS(_screen.cRootPath)+"WiseMisBugReport.exe"
		
		IF FILE(cBugExeFile)
			=ShellExecute(0,"open",cBugExeFile,cAdminEmailAddress,_screen.cRootPath,0)
		ENDIF 
	ENDIF 
Endproc