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
