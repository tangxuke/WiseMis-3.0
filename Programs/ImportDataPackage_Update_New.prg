LPARAMETERS cDataFile as String

IF VARTYPE(cDataFile)<>"C" OR EMPTY(cDataFile)
	RETURN .f.
ENDIF

IF !FILE(cDataFile)
	RETURN .f.
ENDIF

*�������ݰ�
IF !ZipInfo(cDataFile,"System.info")
	RETURN .f.
ENDIF

*!*������ʱĿ¼
LOCAL cTempDir
cTempDir="C:\"+SYS(2015)
MKDIR (cTempDir)

*ȡ�����ݰ���Ϣ
LOCAL cSystemInfo
IF !UnZip(cDataFile,cTempDir,"hlh***TXK0921")
	IF !UnZip(cDataFile,cTempDir)
		=DeleteFiles(cTempDir)
		RETURN .f.
	ENDIF
ENDIF
cSystemInfo=FILETOSTR(ADDBS(cTempDir)+"System.info")
IF LEN(cSystemInfo)=0
	IF !UnZip(cDataFile,cTempDir)
		=DeleteFiles(cTempDir)
		RETURN .f.
	ENDIF
	cSystemInfo=FILETOSTR(ADDBS(cTempDir)+"System.info")
	IF LEN(cSystemInfo)=0
		=DeleteFiles(cTempDir)
		RETURN .f.
	ENDIF
ENDIF

*��ȡ���ݿ�ű��ļ�
LOCAL cScriptFile
cScriptFile=STREXTRACT(cSystemInfo,"<ScriptFile>","</ScriptFile>")
IF !EMPTY(cScriptFile)
	LOCAL cSqlCmd
	cSqlCmd=FILETOSTR(ADDBS(cTempDir)+cScriptFile)
	IF !Execute(cSqlCmd)
		=DeleteFiles(cTempDir)
		RETURN .f.
	ENDIF
ENDIF

*��������
LOCAL cKeyFieldsSql,cKeyFieldsExpr,cSql


LOCAL cTableName,cFieldsInfo,cInsertFieldsPart,cInsertValuesPart,cInsertSql,cField
LOCAL cUpdateSql,cUpdateFields,cCheckIdentitySql
LOCAL cDataFiles
cDataFiles=STREXTRACT(cSystemInfo,"<DataFiles>","</DataFiles>")

IF !EMPTY(cDataFiles)
	FOR m.i=1 TO GETWORDCOUNT(cDataFiles,",")
		cTableName=GETWORDNUM(cDataFiles,m.i,",")
		*!*����治����
		LOCAL cCheckTableExistsSQL
		TEXT TO cCheckTableExistsSQL NOSHOW TEXTMERGE
IF exists(select * from sysobjects where id=object_id('<<cTableName>>') AND ObjectProperty(id,'IsUserTable')=1)
	SELECT 1
ELSE
	SELECT 0
		ENDTEXT
		IF GetValue(cCheckTableExistsSQL)<>1
			LOOP
		ENDIF

		cFieldsInfo=FILETOSTR(ADDBS(cTempDir)+cTableName+".field")

		STORE "" TO cKeyFieldsSql,cKeyFieldsExpr,cSql
		STORE "" TO cUpdateSql,cUpdateFields

		TEXT TO cKeyFieldsSql NOSHOW TEXTMERGE
		Declare @objid int,@indid int
		Set @objid=object_id('<<cTableName>>')
		Set @indid=(select indid from sysindexes where id=@objid and name=(select name from sysobjects where xtype='PK' and parent_obj=@objid))
		Select Rtrim(name) as ���� from syscolumns where id=@objid and colid in (select colid from sysindexkeys where id=@objid and indid=@indid)
		ENDTEXT
		LOCAL cSqlCmd,cTempCursor
		cSqlCmd=cKeyFieldsSql
		cTempCursor=SYS(2015)
		SELECT 0
		IF !SelectData(cSqlCmd,cTempCursor)
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
		SELECT (cTempCursor)
		SCAN
			FOR m.iKey=1 TO GETWORDCOUNT(cFieldsInfo,",")
				cField=GETWORDNUM(cFieldsInfo,m.iKey,",")
				IF ALLTRIM(LOWER(GETWORDNUM(cField,1,":")))==ALLTRIM(LOWER(����))
					cKeyFieldsExpr = cKeyFieldsExpr + IIF(EMPTY(cKeyFieldsExpr),""," and ") + "[" + ALLTRIM(����) + "]=?" + GETWORDNUM(cField,2,":")
				ENDIF
			ENDFOR
		ENDSCAN
		=CloseAlias(cTempCursor)


		cInsertSql="insert into ["+cTableName+"]("
		STORE "" TO cInsertFieldsPart,cInsertValuesPart

		LOCAL bHasIdentityField
		bHasIdentityField=.f.
		FOR m.j=1 TO GETWORDCOUNT(cFieldsInfo,",")
			cField=GETWORDNUM(cFieldsInfo,m.j,",")
			LOCAL cSql
			TEXT TO cSql NOSHOW TEXTMERGE
			IF exists(select * from syscolumns where id=object_id('<<cTableName>>') AND name='<<GETWORDNUM(cField,1,":")>>')
				SELECT 1
			ELSE
				SELECT 0
			ENDTEXT
			IF GetValue(cSql)=0
				LOOP
			ENDIF
			cInsertFieldsPart = cInsertFieldsPart + IIF(EMPTY(cInsertFieldsPart),"",",") + "[" + GETWORDNUM(cField,1,":") + "]"
			cInsertValuesPart = cInsertValuesPart + IIF(EMPTY(cInsertValuesPart),"",",") + "?" + GETWORDNUM(cField,2,":")

			IF GetValue("select ColumnProperty(object_id('"+cTableName+"'),'"+GETWORDNUM(cField,1,":")+"','IsIdentity')")<>1
				cUpdateFields = cUpdateFields + IIF(EMPTY(cUpdateFields),"",",") + "[" + GETWORDNUM(cField,1,":") + "]=?" +  GETWORDNUM(cField,2,":")
			ELSE
				bHasIdentityField=.t.
			ENDIF
		ENDFOR
		cUpdateSql="update ["+cTableName+"] set "+cUpdateFields+" where "+cKeyFieldsExpr
		cInsertSql = cInsertSql + cInsertFieldsPart + ") values (" + cInsertValuesPart + ")"
		cSql = ""

		IF EMPTY(cKeyFieldsExpr)
			cSql = cSql + CHR(13) + CHR(10) + cInsertSql
		ELSE
			cSql = cSql + CHR(13) + CHR(10) + "if exists(select * from ["+cTableName+"] where "+cKeyFieldsExpr+")"
			cSql = cSql + CHR(13) + CHR(10) + CHR(9) + cUpdateSql
			cSql = cSql + CHR(13) + CHR(10) + "else"
			cSql = cSql + CHR(13) + CHR(10) + CHR(9) + cInsertSql
		ENDIF
		cSql = cSql + CHR(13) + CHR(10) + "if @@error<>0"
		cSql = cSql + CHR(13) + CHR(10) + "begin"
		cSql = cSql + CHR(13) + CHR(10) + "		rollback"
		cSql = cSql + CHR(13) + CHR(10) + "		return"
		cSql = cSql + CHR(13) + CHR(10) + "end"

		*���ô�����
		LOCAL cTriggerSQL,cTriggerCursor,cTriggerName
		cTriggerSQL="select name from sysobjects where ObjectProperty(id,'IsTrigger')=1 and parent_obj=object_id('"+cTableName+"')"
		cTriggerCursor=SYS(2015)
		IF !SelectData(cTriggerSQL,cTriggerCursor)
			LOOP
		ENDIF
		SELECT (cTriggerCursor)
		SCAN
			cTriggerName=ALLTRIM(name)
			LOCAL cStopTriggerSQL
			cStopTriggerSQL="alter table ["+cTableName+"] disable trigger ["+cTriggerName+"]"
			IF !Execute(cStopTriggerSQL)
				LOOP
			ENDIF
		ENDSCAN
		=CloseAlias(cTriggerCursor)
		*���ļ�
		LOCAL nSQLCount,cBatchSQL
		cBatchSQL=""
		nSQLCount=0
		LOCAL cTempTable
		cTempTable=SYS(2015)
		SELECT 0
		USE (ADDBS(cTempDir)+cTableName+".dbf") ALIAS (cTempTable)
		SELECT (cTempTable)
		SCAN
			nSQLCount = nSQLCount + 1
			cBatchSQL = cBatchSQL + CHR(13) + CHR(10) + ParseSQL(cSQL)
			cBatchSQL=STRTRAN(cBatchSQL,CHR(13)+CHR(10)+"GO","{##}")
			IF nSQLCount>CURSORGETPROP("BatchUpdateCount",0) OR RECNO(cTempTable)=RECCOUNT(cTempTable)
				LOCAL cTempText1,cTempText2
				TEXT TO cTempText1 NOSHOW TEXTMERGE
IF exists(select * from sysobjects where id=object_id('<<cTableName>>') AND ObjectProperty(id,'IsUserTable')=1 AND ObjectProperty(id,'TableHasIdentity')=1)
	SET IDENTITY_INSERT [<<cTableName>>] ON
				ENDTEXT
				TEXT TO cTempText2 NOSHOW TEXTMERGE
IF exists(select * from sysobjects where id=object_id('<<cTableName>>') AND ObjectProperty(id,'IsUserTable')=1 AND ObjectProperty(id,'TableHasIdentity')=1)
	SET IDENTITY_INSERT [<<cTableName>>] OFF
				ENDTEXT
				cBatchSQL = IIF(bHasIdentityField,"SET IDENTITY_INSERT ["+cTableName+"] ON","") + CHR(13) + CHR(10) + "begin transaction" + CHR(13) + CHR(10) + cBatchSQL + CHR(13) + CHR(10) + "commit" + CHR(13) + CHR(10) + IIF(bHasIdentityField,"SET IDENTITY_INSERT ["+cTableName+"] OFF","")
				IF !Execute(cBatchSQL)
					=DeleteFiles(cTempDir)
					RETURN .f.
				ENDIF
				cBatchSQL=""
				nSQLCount=0
			ENDIF
		ENDSCAN
		=CloseAlias(cTempTable)
		*!*���ô�����
		LOCAL cTriggerSQL,cTriggerCursor,cTriggerName
		cTriggerSQL="select name from sysobjects where ObjectProperty(id,'IsTrigger')=1 and parent_obj=object_id('"+cTableName+"')"
		cTriggerCursor=SYS(2015)
		IF !SelectData(cTriggerSQL,cTriggerCursor)
			LOOP
		ENDIF
		SELECT (cTriggerCursor)
		SCAN
			cTriggerName=ALLTRIM(name)
			LOCAL cStopTriggerSQL
			cStopTriggerSQL="alter table ["+cTableName+"] enable trigger ["+cTriggerName+"]"
			IF !Execute(cStopTriggerSQL)
				LOOP
			ENDIF
		ENDSCAN
		=CloseAlias(cTriggerCursor)
	ENDFOR
ENDIF
*!*ִ����ɽű�
*��ȡ���ݿ�ű��ļ�
LOCAL cFinishScriptFile
cFinishScriptFile=STREXTRACT(cSystemInfo,"<FinishScriptFile>","</FinishScriptFile>")
IF !EMPTY(cFinishScriptFile)
	LOCAL cSqlCmd
	cSqlCmd=FILETOSTR(ADDBS(cTempDir)+cFinishScriptFile)
	IF !Execute(cSqlCmd)
		=DeleteFiles(cTempDir)
		RETURN .f.
	ENDIF
ENDIF

=DeleteFiles(cTempDir)

RETURN .t.
