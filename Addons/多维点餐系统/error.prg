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
