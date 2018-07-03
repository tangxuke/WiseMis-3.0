PROCEDURE RefreshSystem
	
	*!*清空基础数据对象
	WITH _screen.oBaseData as Collection
		.Remove(-1)
	ENDWITH 
	*!*清空辅助资料对象
	WITH _screen.oItemData as Collection
		.Remove(-1)
	ENDWITH 
	*!*清空编码规则对象
	WITH _screen.oCodeRule as Collection
		.Remove(-1)
	ENDWITH 
	
	Local cAliasList
	cAliasList = _screen.cAlias_AppType
	cAliasList = cAliasList + "," + _screen.cAlias_AppIndex
	cAliasList = cAliasList + "," + _screen.cAlias_AppDetail
	cAliasList = cAliasList + "," + _screen.cAlias_AppFieldScript
	cAliasList = cAliasList + "," + _screen.cAlias_AppRelation
	cAliasList = cAliasList + "," + _screen.cAlias_AppWorkflow
	cAliasList = cAliasList + "," + _screen.cAlias_AppReport
	cAliasList = cAliasList + "," + _screen.cAlias_Query
	cAliasList = cAliasList + "," + _screen.cAlias_Menu
	cAliasList = cAliasList + "," + _screen.cAlias_Notify
	cAliasList = cAliasList + "," + _screen.cAlias_ExcelImportIndex
	cAliasList = cAliasList + "," + _screen.cAlias_ExcelImportDetail
	cAliasList = cAliasList + "," + _screen.cAlias_SearchSchame
	cAliasList = cAliasList + "," + _screen.cAlias_AppReport2
	cAliasList = cAliasList + "," + _screen.cAlias_ItemData
	cAliasList = cAliasList + "," + _screen.cAlias_BaseData
	cAliasList = cAliasList + "," + _screen.cAlias_CodeRule

	=CloseAlias(cAliasList)
	LOCAL cSQLCmd,cAddonSQL
	cSQLCmd="exec WiseMis_RefreshSystemInfo"

		=SaveUserSchame()

		IF !SelectData(cSQLCmd,cAliasList)
			RETURN .f.
		ENDIF

	*!*索引
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

*!*保存用户系统信息
PROCEDURE SaveUserSystemInfo
	LOCAL cPCode
	cPCode=_screen.cSysMCode
	LOCAL cTempDir
	cTempDir=ADDBS(_screen.cFilesPath)+cPCode+"_"+_screen.cUserName

	IF DIRECTORY(cTempDir)
		IF DBUSED("WiseMisDB")
			SET DATABASE TO WiseMisDB
			CLOSE DATABASES
		ENDIF
		=DeleteFiles(cTempDir)
	ENDIF

	MKDIR (cTempDir)

	*!*缓存到本地

	CREATE DATABASE (ADDBS(cTempDir)+"WiseMisDB")
	OPEN DATABASE (ADDBS(cTempDir)+"WiseMisDB") EXCLUSIVE

	SELECT (_screen.cAlias_AppType)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppType") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppIndex)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppIndex") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppDetail)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppDetail") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppFieldScript)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppFieldScript") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppRelation)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppRelation") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppWorkflow)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppWorkflow") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppReport)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppReport") DATABASE WiseMisDB

	SELECT (_screen.cAlias_Query)
	COPY TO (ADDBS(cTempDir)+"WiseMis_Query") DATABASE WiseMisDB

	SELECT (_screen.cAlias_Menu)
	COPY TO (ADDBS(cTempDir)+"WiseMis_Menu") DATABASE WiseMisDB

	SELECT (_screen.cAlias_Notify)
	COPY TO (ADDBS(cTempDir)+"WiseMis_Notify") DATABASE WiseMisDB

	SELECT (_screen.cAlias_ExcelImportIndex)
	COPY TO (ADDBS(cTempDir)+"WiseMis_ExcelImportIndex") DATABASE WiseMisDB

	SELECT (_screen.cAlias_ExcelImportDetail)
	COPY TO (ADDBS(cTempDir)+"WiseMis_ExcelImportDetail") DATABASE WiseMisDB

	SELECT (_screen.cAlias_SearchSchame)
	COPY TO (ADDBS(cTempDir)+"WiseMis_SearchSchame") DATABASE WiseMisDB

	SELECT (_screen.cAlias_AppReport2)
	COPY TO (ADDBS(cTempDir)+"WiseMis_AppReport2") DATABASE WiseMisDB

	SELECT (_screen.cAlias_ItemData)
	COPY TO (ADDBS(cTempDir)+"WiseMis_ItemData") DATABASE WiseMisDB

	SELECT (_screen.cAlias_BaseData)
	COPY TO (ADDBS(cTempDir)+"WiseMis_BaseData") DATABASE WiseMisDB

	SELECT (_screen.cAlias_CodeRule)
	COPY TO (ADDBS(cTempDir)+"WiseMis_CodeRule")  DATABASE WiseMisDB

	CLOSE DATABASES
ENDPROC
