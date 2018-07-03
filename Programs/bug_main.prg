LPARAMETERS cEmailAddress as String
IF VARTYPE(cEmailAddress)<>"C"
	cEmailAddress=""
ENDIF 

SET SAFETY OFF
LOCAL cDefaultPath
cDefaultPath=SYS(5)+SYS(2003)

SET DEFAULT TO (cDefaultPath)

_screen.AddProperty("cRootPath",cDefaultPath)&&,1,"��Ŀ¼")

LOCAL cErrorFile
cErrorFile=ADDBS(_screen.cRootPath)+"ERROR.txt"
IF !FILE(cErrorFile)
	RETURN .f.
ENDIF 
LOCAL cErrorImageFile
cErrorImageFile=ADDBS(_screen.cRootPath)+"ERROR.png"
IF !FILE(cErrorImageFile)
	RETURN .f.
ENDIF 
LOCAL cMailBody
cMailBody=FILETOSTR(cErrorFile)
LOCAL cReceiver
cReceiver="295659187@qq.com"
IF !EMPTY(cEmailAddress)
	cReceiver = cReceiver + "," + cEmailAddress
ENDIF 
=SendMail("smtp.qq.com","295659187","hlh***TXK0921","295659187@qq.com",cReceiver,"����������",cMailBody,cErrorImageFile)





*!*�����ʼ�
PROCEDURE SendMail
	LPARAMETERS cSmtpServer,cEMailAccount,cEMailPassword,cSender,cReceiver,cSubject,cBody,cFileList
	*!*�����ʼ�
	LOCAL oMailObject
	oMailObject=CREATEOBJECT("JMail.Message")
	oMailObject.Silent = .t.&&���Դ���
	oMailObject.Charset = "GB2312"&&�����ַ���
	oMailObject.Encoding = "base64"&&���ø����ı��뷽ʽ
	oMailObject.ContentTransferEncoding = "Base64"&&�����ʼ�����
	oMailObject.From=GETWORDNUM(cSender,1,":")
	oMailObject.FromName=IIF(GETWORDCOUNT(cSender,":")<=1,cSender,GETWORDNUM(cSender,2,":"))
	FOR i=1 TO GETWORDCOUNT(cReceiver,",")
		LOCAL cR,cR1,cR2
		cR=GETWORDNUM(cReceiver,i,",")
		cR1=GETWORDNUM(cR,1,":")
		cR2=GETWORDNUM(cR,2,":")
		oMailObject.AddRecipient(cR1,cR2)
	ENDFOR 
	oMailObject.Subject=cSubject
	oMailObject.Body=cBody
	FOR i=1 TO GETWORDCOUNT(cFileList,"|")
		LOCAL cFile
		cFile=GETWORDNUM(cFileList,i,"|")
		IF FILE(cFile)
			oMailObject.AddAttachment(cFile)
		ENDIF
	ENDFOR
	LOCAL bSendResult
	bSendResult=oMailObject.Send(cEMailAccount+":"+cEMailPassword+"@"+cSmtpServer)
	oMailObject.Close()
	RETURN bSendResult
ENDPROC
