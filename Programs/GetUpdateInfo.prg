LPARAMETERS cUpdateServer

*!*����Ƿ������ӵ��ٷ�������
LOCAL nHandle,bCheckOnline
nHandle=SQLSTRINGCONNECT("Driver={SQL Server};Server="+cUpdateServer+";Database="+_screen.cUpdateDatabase+";Uid="+_screen.cUpdateUserName+";Pwd="+_screen.cUpdatePassword)
IF nHandle<1
	RETURN .f.
ELSE 
	=SQLDISCONNECT(nHandle)
	RETURN .t.
ENDIF 