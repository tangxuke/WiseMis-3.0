*!*格式化错误显示
Procedure Format_Error
	Local arrayError(7)
	= Aerror(arrayError)
	Local nError , cErrorMsg
	nError = arrayError(1)
	cErrorMsg = ""
	Local cErrorType
	Do Case
		Case nError = 1526
			cErrorType = "数据库错误"
			Local cSQLError
			cSQLError=arrayError(3)
			If !Empty(Strextract(cSQLError,"{b}","{e}"))
				cSQLError=Strextract(cSQLError,"{b}","{e}")
			Endif
			cErrorMsg = cErrorMsg + cSQLError
		Case nError = 1427 .Or. nError = 1429
			cErrorType = "OLE错误"
			cErrorMsg = cErrorMsg + arrayError(3) + Chr(10) + "应用程序名称：" + arrayError(4) + Chr(10) + "帮助信息：" + Iif(Isnull(arrayError(5)),"无",arrayError(5)) + Chr(10) + "帮助信息内容：" + Iif(Isnull(arrayError(6)),"无",arrayError(6)) + Chr(10) + "OLE错误号：" + Alltrim(Str(arrayError(7)))
		Otherwise
			cErrorType = "其他错误"
			cErrorMsg = cErrorMsg + arrayError(2)
	Endcase
	cErrorMsg = cErrorType + Chr(10) + Chr(10) + cErrorMsg
	Return cErrorMsg
ENDPROC

*!*报告错误
Procedure OnError
	*!*上报错误
	IF !_screen.bShowError
		RETURN
	ENDIF
	Local cErrorMessage
	cErrorMessage=Message()
	*!*只提示数据库错误，其他错误自动忽略
	LOCAL __nLines__
	__nLines__=ALINES(__arr__,cErrorMessage)
	IF __nLines__>=1
		LOCAL __cLine__
		__cLine__=__arr__[1]
		IF ALLTRIM(__cLine__)=="数据库错误"
			MessageBox1(cErrorMessage,0+64,"发生异常错误")
		ELSE
			IF _screen.IsDebug
				IF MessageBox1(cErrorMessage+REPLICATE(CHR(13)+CHR(10),2)+"是否继续执行？",1+32,"系统异常")<>1
					CANCEL 
				ENDIF 
			ENDIF 
		ENDIF 
	ENDIF 
	
	cErrorMessage=CHR(13)+CHR(10)+"------------------------------------------------------"
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "客户端/时间：" + SYS(0) + "/" + TIME()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误号：" + TRANSFORM(ERROR())
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误信息：" + MESSAGE()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "源代码：" + MESSAGE(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "程序名：" + PROGRAM(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误行：" + TRANSFORM(LINENO(1))
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "------------------------------------------------------"
	*!*上报错误
	IF _screen.bReportError
		=ReportError(cErrorMessage)
		_screen.bReportError=.f.
	ENDIF
ENDPROC

*!*记录错误报告
Procedure ReportError
	Lparameters cErrorMessage As String
	*!*收集最近一条SQL语句
	If Vartype(cErrorMessage)<>"C"
		cErrorMessage=""
	ENDIF
	LOCAL cLastScript
	cLastScript=_screen.cLastScript
	*!*收集客户端相关的信息
	LOCAL cClientInfo
	cClientInfo="客户端信息："
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "版本号：" + _screen.cVersion
	*收集机器码、产品密钥
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "机器码：" + GetMCode()
	cClientInfo = cClientInfo + CHR(13) + CHR(10) + "识别码：" + GetPCode()
	*!*邮件内容
	LOCAL cMailBody
	cMailBody=cClientInfo+CHR(13)+CHR(10)+cErrorMessage+CHR(13)+CHR(10)+"最近执行的SQL语句："+CHR(13)+CHR(10)+_screen.cLastSQL+REPLICATE(CHR(13)+CHR(10),4)+"最近执行的脚本代码："+CHR(13)+CHR(10)+cLastScript
	LOCAL cErrorFile
	cErrorFile=ADDBS(_screen.cRootPath)+"ERROR.txt"
	=STRTOFILE(cMailBody,cErrorFile)
	*!*收集发生错误时的截图
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