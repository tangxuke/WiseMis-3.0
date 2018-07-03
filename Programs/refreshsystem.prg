PROCEDURE RefreshSystem

	Local cAliasList
	cAliasList=""
	cAliasList = _screen.cAlias_AppType
	cAliasList = cAliasList + "," + _screen.cAlias_AppIndex
	cAliasList = cAliasList + "," + _screen.cAlias_Query
	cAliasList = cAliasList + "," + _screen.cAlias_Menu
	cAliasList = cAliasList + "," + _screen.cAlias_Notify
	cAliasList = cAliasList + "," + _screen.cAlias_Language
	cAliasList = cAliasList + "," + _screen.calias_workflowimage
	cAliasList = cAliasList + "," + _screen.calias_favoriteimage

	=CloseAlias(cAliasList)
	LOCAL cSQL
	cSQL="exec WiseMis_RefreshSystemInfo_RuntimeMode"

	IF !SelectData(cSQL,cAliasList)
		RETURN .f.
	ENDIF

	*!*Ë÷Òý
	SELECT (_screen.cAlias_AppIndex)
	INDEX ON AppOrder TAG AppOrder ASCENDING

	SELECT (_screen.cALias_Query)
	INDEX ON OrderId TAG QueryOrder ASCENDING

	SELECT (_screen.cALias_Menu)
	INDEX ON OrderId TAG MenuOrder ASCENDING

	SELECT (_screen.cAlias_AppIndex)
	INDEX ON LastClickTime TAG Schame DESCENDING

	SELECT (_screen.cAlias_Query)
	INDEX ON LastClickTime TAG Schame DESCENDING

	SELECT (_screen.cAlias_Menu)
	INDEX ON LastClickTime TAG Schame DESCENDING 
	

	RETURN .t.
ENDPROC
