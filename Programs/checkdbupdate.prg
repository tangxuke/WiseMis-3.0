LPARAMETERS cSystemCode as String
IF VARTYPE(cSystemCode)<>"C" OR EMPTY(cSystemCode)
	RETURN .t.
ENDIF 

LOCAL cCurVersion,dVersionDate,bIsSystemVersion,cDBVersionString
LOCAL cNewVersionSQL,cNewVersionCursor

DO CASE
CASE ALLTRIM(LOWER(_screen.cWiseMisPCode))==ALLTRIM(LOWER(cSystemCode))
	cCurVersion=NVL(GetValue("select [value] from WiseMis_Setting where [key]='WiseMis_SystemDBVersion'"),"")
	bIsSystemVersion=.t.
	cDBVersionString="WiseMis_SystemDBVersion"
CASE ALLTRIM(LOWER(GetPCode()))==ALLTRIM(LOWER(cSystemCode))
	cCurVersion=NVL(GetValue("select [value] from WiseMis_Setting where [key]='WiseMis_DBVersion'"),"")
	cDBVersionString="WiseMis_DBVersion"
OTHERWISE
	RETURN .f.
ENDCASE

TEXT TO cNewVersionSQL NOSHOW TEXTMERGE 
select F002,F003,F005
from T007
where F004>ISNULL((select top 1 F004 from T007 where F002='<<cCurVersion>>' and exists(select * from T001 where F001=T007.F001 and CAST(F008 as varchar(250))='<<cSystemCode>>') order by F004),'')
	and exists(select * from T001 where F001=T007.F001 and CAST(F008 as varchar(250))='<<cSystemCode>>')
order by F004
ENDTEXT 
cNewVersionCursor=SYS(2015)
IF !SelectData(cNewVersionSQL,cNewVersionCursor,_screen.cUpdateServer,_screen.cUpdateDatabase,_screen.cUpdateUserName,_screen.cUpdatePassword)
	RETURN .f.
ENDIF 
*!*平台自身更新**********************************************************************************************************
SELECT (cNewVersionCursor)
SCAN 
	SELECT (cNewVersionCursor)
	LOCAL cTempDataFile,cVersion,cDataPackageURL,cDataPackageURL2
	cTempDataFile="C:\"+SYS(2015)+".dat"
	cVersion=ALLTRIM(F002)
	cDataPackageURL=ALLTRIM(NVL(F003,""))
	cDataPackageURL2=ALLTRIM(NVL(F005,""))
	*下载数据包
	IF !HttpDownFile(cDataPackageURL,cTempDataFile)
		IF !HttpDownFile(cDataPackageURL2,cTempDataFile)
			=CloseAlias(cNewVersionCursor)
			RETURN .f.
		ENDIF 
	ENDIF 
	IF FILE(cTempDataFile)
		IF !ImportDataPackage_Update_New(cTempDataFile)
			RETURN .f.
		ENDIF 
		LOCAL cUpdateVersionSQL
		TEXT TO cUpdateVersionSQL NOSHOW TEXTMERGE 
IF NOT exists(select * from WiseMis_Setting where [key]='<<cDBVersionString>>')
	INSERT INTO WiseMis_Setting([key],[value],[desc]) VALUES ('<<cDBVersionString>>','<<cVersion>>','数据库版本（不要改动，否则影响数据库升级）')
ELSE
	UPDATE WiseMis_Setting SET [value]='<<cVersion>>' WHERE [key]='<<cDBVersionString>>'
		ENDTEXT 
		=Execute(cUpdateVersionSQL)
		ERASE (cTempDataFile)
	ENDIF 
	SELECT (cNewVersionCursor)
ENDSCAN 
*!*清理现场********************************************************************************************************
=CloseAlias(cNewVersionCursor)

RETURN .t.