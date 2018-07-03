LPARAMETERS cUpdateServer

*!*检测是否能连接到官方服务器
LOCAL nHandle,bCheckOnline
nHandle=SQLSTRINGCONNECT("Driver={SQL Server};Server="+cUpdateServer+";Database="+_screen.cUpdateDatabase+";Uid="+_screen.cUpdateUserName+";Pwd="+_screen.cUpdatePassword)
IF nHandle<1
	RETURN .f.
ELSE 
	=SQLDISCONNECT(nHandle)
	RETURN .t.
ENDIF 