PROCEDURE ImportDataPackage
	LPARAMETERS cDataFile as String,oInfoLabel as Label,oCurrentProcessBar as new_processbar,oTotalProcessBar as new_processbar

	IF VARTYPE(cDataFile)<>"C" OR EMPTY(cDataFile)
		cDataFile=GETFILE(ToEnglish("数据包")+":dat",ToEnglish("请选择数据包文件"))
		IF !FILE(cDataFile)
			RETURN .f.
		ENDIF
		IF MessageBox1("你真的要导入数据包吗？",1+32,"导入数据包")<>1
			RETURN .f.
		ENDIF
	ENDIF

	IF !FILE(cDataFile)
		MessageBox1("数据包文件不存在！",0+64,"系统提示")
		RETURN .f.
	ENDIF

	*测试数据包
	IF !ZipInfo(cDataFile,"System.info")
		MessageBox1("数据包无法被系统识别！",0+64,"系统提示")
		RETURN .f.
	ENDIF

	*!*建立临时目录
	LOCAL cTempDir
	cTempDir=ADDBS(_screen.cFilesPath)+SYS(2015)
	MKDIR (cTempDir)
	*解压数据包
	IF VARTYPE(oInfoLabel)="O"
		oInfoLabel.Caption=ToEnglish("正在解压数据包……")
	ENDIF

	*取得数据包信息
	LOCAL cSystemInfo
	IF !UnZip(cDataFile,cTempDir,"hlh***TXK0921")
		IF !UnZip(cDataFile,cTempDir)
			MessageBox1("解压数据包失败！",0+64,"系统提示")
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
	ENDIF
	cSystemInfo=FILETOSTR(ADDBS(cTempDir)+"System.info")
	IF LEN(cSystemInfo)=0
		IF !UnZip(cDataFile,cTempDir)
			MessageBox1("解压数据包失败！",0+64,"系统提示")
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
		cSystemInfo=FILETOSTR(ADDBS(cTempDir)+"System.info")
		IF LEN(cSystemInfo)=0
			MessageBox1("解压数据包失败！",0+64,"系统提示")
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
	ENDIF
	*!*启用触发器信息
	LOCAL cEnableTriggerInfo
	cEnableTriggerInfo=STREXTRACT(cSystemInfo,"<EnableTrigger>","</EnableTrigger>")
	*!*计算统计信息
	LOCAL nItemCount,nCurItem,cDataFiles
	STORE 0 TO nItemCount,nCurItem
	IF !EMPTY(STREXTRACT(cSystemInfo,"<ScriptFile>","</ScriptFile>"))
		nItemCount = nItemCount + 1
	ENDIF
	IF !EMPTY(STREXTRACT(cSystemInfo,"<FinishScriptFile>","</FinishScriptFile>"))
		nItemCount = nItemCount + 1
	ENDIF
	cDataFiles=STREXTRACT(cSystemInfo,"<DataFiles>","</DataFiles>")
	nItemCount = nItemCount + GETWORDCOUNT(cDataFiles,",")

	IF VARTYPE(oTotalProcessBar)="O"
		oTotalProcessBar.SetPercent(0)
	ENDIF
	*读取数据库脚本文件
	LOCAL cScriptFile
	cScriptFile=STREXTRACT(cSystemInfo,"<ScriptFile>","</ScriptFile>")
	IF !EMPTY(cScriptFile)
		IF VARTYPE(oInfoLabel)="O"
			oInfoLabel.Caption=ToEnglish("正在执行数据库脚本……")
		ENDIF
		IF VARTYPE(oCurrentProcessBar)="O"
			oCurrentProcessBar.SetPercent(0)
		ENDIF
		LOCAL cSqlCmd
		cSqlCmd="GO"+CHR(13)+CHR(10)+FILETOSTR(ADDBS(cTempDir)+cScriptFile)
		IF !Execute(cSqlCmd)
			MessageBox1("执行数据库脚本失败！",0+64,"系统提示")
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
		nCurItem = nCurItem + 1
		IF VARTYPE(oTotalProcessBar)="O"
			oTotalProcessBar.SetPercent(100.00*nCurItem/nItemCount)
		ENDIF
	ENDIF

	*导入数据
	LOCAL cKeyFieldsSql,cKeyFieldsExpr,cSql


	LOCAL cTableName,cFieldsInfo,cInsertFieldsPart,cInsertValuesPart,cInsertSql,cField
	LOCAL cUpdateSql,cUpdateFields,cCheckIdentitySql

	IF !EMPTY(cDataFiles)
		FOR m.i=1 TO GETWORDCOUNT(cDataFiles,",")
			cTableName=GETWORDNUM(cDataFiles,m.i,",")
			*!*检测表存不存在
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
		Select Rtrim(name) as 列名 from syscolumns where id=@objid and colid in (select colid from sysindexkeys where id=@objid and indid=@indid)
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
					IF ALLTRIM(LOWER(GETWORDNUM(cField,1,":")))==ALLTRIM(LOWER(列名))
						cKeyFieldsExpr = cKeyFieldsExpr + IIF(EMPTY(cKeyFieldsExpr),""," and ") + "[" + ALLTRIM(列名) + "]=?" + GETWORDNUM(cField,2,":")
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

			*禁用触发器
			IF OCCURS(","+ALLTRIM(LOWER(cTableName))+",",ALLTRIM(LOWER(cEnableTriggerInfo)))=0
				LOCAL cTriggerSQL,cTriggerCursor,cTriggerName
				cTriggerSQL="select name from sysobjects where ObjectProperty(id,'IsTrigger')=1 and parent_obj=object_id('"+cTableName+"')"
				cTriggerCursor=SYS(2015)
				IF !SelectData(cTriggerSQL,cTriggerCursor)
					IF MessageBox1("查询表【"+cTableName+"】的触发器失败，是否继续还原？",1+32,"系统提示")<>1
						=DeleteFiles(cTempDir)
						RETURN .f.
					ENDIF
					LOOP
				ENDIF
				SELECT (cTriggerCursor)
				SCAN
					cTriggerName=ALLTRIM(name)
					LOCAL cStopTriggerSQL
					cStopTriggerSQL="alter table ["+cTableName+"] disable trigger ["+cTriggerName+"]"
					IF !Execute(cStopTriggerSQL)
						IF MessageBox1("查询表【"+cTableName+"】的触发器失败，是否继续还原？",1+32,"系统提示")<>1
							=DeleteFiles(cTempDir)
							RETURN .f.
						ENDIF
						LOOP
					ENDIF
				ENDSCAN
				=CloseAlias(cTriggerCursor)
			ENDIF 
			*打开文件
			LOCAL nSQLCount,cBatchSQL
			cBatchSQL=""
			nSQLCount=0
			LOCAL cTempTable
			cTempTable=SYS(2015)
			SELECT 0
			USE (ADDBS(cTempDir)+cTableName+".dbf") ALIAS (cTempTable)
			SELECT (cTempTable)
			IF VARTYPE(oInfoLabel)="O"
				oInfoLabel.Caption=ToEnglish("正在导入表【"+cTableName+"】...")
			ENDIF
			IF VARTYPE(oCurrentProcessBar)="O"
				oCurrentProcessBar.SetPercent(0)
			ENDIF
			SCAN
				nSQLCount = nSQLCount + 1
				cBatchSQL = cBatchSQL + CHR(13) + CHR(10) + ParseSQL(cSQL)
				
				cBatchSQL=STRTRAN(cBatchSQL,CHR(13)+CHR(10)+"GO","{##}")
				IF nSQLCount>CURSORGETPROP("BatchUpdateCount",0) OR RECNO(cTempTable)=RECCOUNT(cTempTable)
					cBatchSQL = IIF(bHasIdentityField,"SET IDENTITY_INSERT ["+cTableName+"] ON","") + CHR(13) + CHR(10) + "begin transaction" + CHR(13) + CHR(10) + cBatchSQL + CHR(13) + CHR(10) + "commit" + CHR(13) + CHR(10) + IIF(bHasIdentityField,"SET IDENTITY_INSERT ["+cTableName+"] OFF","")
					IF !Execute(cBatchSQL)
						=DeleteFiles(cTempDir)
						RETURN .f.
					ENDIF
					cBatchSQL=""
					nSQLCount=0
				ENDIF
				IF VARTYPE(oCurrentProcessBar)="O"
					oCurrentProcessBar.SetPercent(100.00*RECNO()/RECCOUNT())
				ENDIF
			ENDSCAN
			IF VARTYPE(oCurrentProcessBar)="O"
				oCurrentProcessBar.SetPercent(100)
			ENDIF
			=CloseAlias(cTempTable)
			*!*启用触发器
			IF OCCURS(","+ALLTRIM(LOWER(cTableName))+",",ALLTRIM(LOWER(cEnableTriggerInfo)))=0
				LOCAL cTriggerSQL,cTriggerCursor,cTriggerName
				cTriggerSQL="select name from sysobjects where ObjectProperty(id,'IsTrigger')=1 and parent_obj=object_id('"+cTableName+"')"
				cTriggerCursor=SYS(2015)
				IF !SelectData(cTriggerSQL,cTriggerCursor)
					IF MessageBox1("查询表【"+cTableName+"】的触发器失败，是否继续还原？",1+32,"系统提示")<>1
						=DeleteFiles(cTempDir)
						RETURN .f.
					ENDIF
					LOOP
				ENDIF
				SELECT (cTriggerCursor)
				SCAN
					cTriggerName=ALLTRIM(name)
					LOCAL cStopTriggerSQL
					cStopTriggerSQL="alter table ["+cTableName+"] enable trigger ["+cTriggerName+"]"
					IF !Execute(cStopTriggerSQL)
						IF MessageBox1("查询表【"+cTableName+"】的触发器失败，是否继续还原？",1+32,"系统提示")<>1
							=CloseAlias(cTriggerCursor)
							=DeleteFiles(cTempDir)
							RETURN .f.
						ENDIF
						LOOP
					ENDIF
				ENDSCAN
				=CloseAlias(cTriggerCursor)
			ENDIF 

			nCurItem = nCurItem + 1
			IF VARTYPE(oTotalProcessBar)="O"
				oTotalProcessBar.SetPercent(100.00*nCurItem/nItemCount)
			ENDIF
		ENDFOR
	ENDIF

	*!*执行完成脚本
	*读取数据库脚本文件
	LOCAL cFinishScriptFile
	cFinishScriptFile=STREXTRACT(cSystemInfo,"<FinishScriptFile>","</FinishScriptFile>")
	IF !EMPTY(cFinishScriptFile)

		IF VARTYPE(oInfoLabel)="O"
			oInfoLabel.Caption=ToEnglish("正在执行完成后的数据库脚本……")
		ENDIF

		LOCAL cSqlCmd
		cSqlCmd=FILETOSTR(ADDBS(cTempDir)+cFinishScriptFile)
		IF !Execute(cSqlCmd)
			MessageBox1("执行完成后数据库脚本失败！",0+64,"系统提示")
			=DeleteFiles(cTempDir)
			RETURN .f.
		ENDIF
		nCurItem = nCurItem + 1
		IF VARTYPE(oTotalProcessBar)="O"
			oTotalProcessBar.SetPercent(100.00*nCurItem/nItemCount)
		ENDIF
	ENDIF
	IF VARTYPE(oTotalProcessBar)="O"
		oTotalProcessBar.SetPercent(100)
	ENDIF

	IF VARTYPE(oInfoLabel)="O"
		oInfoLabel.Caption=ToEnglish("正在清理生成的临时文件......")
	ENDIF

	=DeleteFiles(cTempDir)

	RETURN .t.

ENDPROC

PROCEDURE CreateDataPackage
	LPARAMETERS cPackageName as String,cSaveFile as String,bNoShowMessage as Boolean
	IF VARTYPE(cSaveFile)<>"C"
		cSaveFile=""
	ENDIF
	IF VARTYPE(bNoShowMessage)<>"L"
		bNoShowMessage=.f.
	ENDIF

	LOCAL cPackageSQL,cPackageCursor
	TEXT TO cPackageSQL NOSHOW TEXTMERGE
DECLARE @Name varchar(50)
SET @Name='<<cPackageName>>'
SELECT * FROM WiseMis_DataPackage WHERE Name=@Name
SELECT * FROM WiseMis_DataPackageDetail WHERE Name=@Name ORDER BY OrderId,TableName
SELECT * FROM WiseMis_DataPackageScripts WHERE Name=@Name ORDER BY OrderId
SELECT * FROM WiseMis_DataPackageFinishScripts WHERE Name=@Name ORDER BY OrderId
	ENDTEXT
	cPackageCursor="__package__,__package_detail__,__package_scripts__,__package_finish_scripts__"
	SELECT 0
	IF !SelectData(cPackageSQL,cPackageCursor)
		IF !bNoShowMessage
			MessageBox1("查询数据包信息失败！",0+64,"生成数据包")
		ENDIF
		RETURN .f.
	ENDIF
	SELECT __package__
	IF RECCOUNT()=0
		IF !bNoShowMessage
			MessageBox1("不存在这个数据包的定义！",0+64,"生成数据包")
		ENDIF
		=CloseAlias(cPackageCursor)
		RETURN .f.
	ENDIF

	LOCAL cSQLText,cFinishSQLText
	cSQLText=""
	cFinishSQLText=""
	SELECT __package_scripts__
	SCAN
		cSQLText = cSQLText + CHR(13) + CHR(10) + "----------------------------" + ALLTRIM(ScriptName) + "--------------------------" + CHR(13) + CHR(10) + ALLTRIM(NVL(ScriptText,"")) + CHR(13) + CHR(10) + "GO"
	ENDSCAN
	SELECT __package_finish_scripts__
	SCAN
		cFinishSQLText = cFinishSQLText + CHR(13) + CHR(10) + "----------------------------" + ALLTRIM(ScriptName) + "--------------------------" + CHR(13) + CHR(10) + ALLTRIM(NVL(ScriptText,"")) + CHR(13) + CHR(10) + "GO"
	ENDSCAN
	LOCAL cSQLFile,cFinishSQLFile
	cSQLFile=ADDBS(_screen.cFilesPath)+"SQL.sql"
	cFinishSQLFile=ADDBS(_screen.cFilesPath)+"FinishSQL.sql"
	IF !EMPTY(cSQLText)
		=STRTOFILE(cSQLText,cSQLFile)
	ENDIF
	IF !EMPTY(cFinishSQLText)
		=STRTOFILE(cFinishSQLText,cFinishSQLFile)
	ENDIF

	*生成文件列表
	LOCAL cZipFilesList,cFilesInfo,cEnableTriggerInfo
	cZipFilesList=""
	cEnableTriggerInfo=""
	cFilesInfo="<ScriptFile>"
	*首先把脚本文件赋值到文件目录
	IF FILE(cSQLFile)
		cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + JUSTFNAME(cSQLFile)
		cFilesInfo = cFilesInfo + JUSTFNAME(cSQLFile)
	ENDIF
	cFilesInfo = cFilesInfo + "</ScriptFile>"
	cFilesInfo = cFilesInfo + "<FinishScriptFile>"
	IF FILE(cFinishSQLFile)
		cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + JUSTFNAME(cFinishSQLFile)
		cFilesInfo = cFilesInfo + JUSTFNAME(cFinishSQLFile)
	ENDIF
	cFilesInfo = cFilesInfo + "</FinishScriptFile><DataFiles>"
	*读取数据包内容
	LOCAL cSql,cAliasName,cFieldsList,cCursorSql,cTableName
	SELECT __package_detail__
	SCAN
		cFieldsList=""
		cCursorSql=""
		cTableName=ALLTRIM(TableName)
		*!*启用触发器选项
		IF NVL(Enable_Trigger,.f.)
			cEnableTriggerInfo = cEnableTriggerInfo + "," + cTableName
		ENDIF
		*!*检查字段
		LOCAL cTempFields,cTempFieldsCursor,cNewFields,cTempField
		cTempFields=ALLTRIM(Fields)
		cNewFields=""
		cTempFieldsCursor=SYS(2015)
		IF !SelectData("select name from syscolumns where id=object_id('"+ALLTRIM(TableName)+"') order by colid",cTempFieldsCursor)
			IF !bNoShowMessage
				MessageBox1("查询字段信息失败！",0+64,"系统提示")
			ENDIF
			=CloseAlias(cPackageCursor)
			RETURN .f.
		ENDIF
		SELECT (cTempFieldsCursor)
		FOR i=1 TO GETWORDCOUNT(cTempFields,",")
			cTempField=ALLTRIM(LOWER(GETWORDNUM(cTempFields,i,",")))
			LOCATE FOR (ALLTRIM(LOWER(Name))==cTempField OR "["+ALLTRIM(LOWER(Name))+"]"==cTempField)
			IF FOUND()
				cNewFields = cNewFields + IIF(EMPTY(cNewFields),"",",") + GETWORDNUM(cTempFields,i,",")
			ENDIF
		ENDFOR
		=CloseAlias(cTempFieldsCursor)
		IF EMPTY(cNewFields)
			IF !bNoShowMessage
				MessageBox1("表【"+cTableName+"】字段信息不存在！",0+64,"系统提示")
			ENDIF
			=CloseAlias(cPackageCursor)
			RETURN .f.
		ENDIF

		SELECT __package_detail__
		cSql="select "+cNewFields+" from ["+cTableName+"]"+IIF(EMPTY(NVL(FilterText,"")),""," where "+ALLTRIM(FilterText))
		cAliasName=SYS(2015)

		IF !SelectData(cSQL,cAliasName)
			IF !bNoShowMessage
				MessageBox1("查询数据失败！",0+64,"系统提示")
			ENDIF
			=CloseAlias(cPackageCursor)
			RETURN .f.
		ENDIF
		SELECT (cAliasName)
		FOR i=1 TO FCOUNT(cAliasName)
			cFieldsList = cFieldsList + IIF(EMPTY(cFieldsList),"",",") + FIELD(i) + ":f" + TRANSFORM(i)
			cCursorSql = cCursorSql + IIF(EMPTY(cCursorSql),"",",") + FIELD(i) + " as f" + TRANSFORM(i)
		ENDFOR
		=STRTOFILE(cFieldsList,ADDBS(_screen.cFilesPath)+cTableName+".field")
		cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + cTableName+".field"
		cCursorSql="select "+cCursorSql+" from "+cAliasName+" into table '"+ADDBS(_screen.cFilesPath)+cTableName+"'"
		&cCursorSql
		=CloseAlias(cAliasName+","+cTableName)
		IF FILE(ADDBS(_screen.cFilesPath)+cTableName+".dbf")
			cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + cTableName+".dbf"
			cFilesInfo = cFilesInfo + cTableName + ","
		ENDIF
		IF FILE(ADDBS(_screen.cFilesPath)+cTableName+".fpt")
			cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + cTableName+".fpt"
		ENDIF
		SELECT __package_detail__
	ENDSCAN
	cEnableTriggerInfo = cEnableTriggerInfo + ","
	=CloseAlias(cPackageCursor)
	cFilesInfo=SUBSTR(cFilesInfo,1,LEN(cFilesInfo)-1)+"</DataFiles>"
	cFilesInfo = cFilesInfo + "<EnableTrigger>"+cEnableTriggerInfo + "</EnableTrigger>"
	=STRTOFILE(cFilesInfo,ADDBS(_screen.cFilesPath)+"System.info")
	cZipFilesList = cZipFilesList + IIF(EMPTY(cZipFilesList),"","|") + "System.info"

	LOCAL cDefaultPath,cPath
	cDefaultPath=_screen.cRootPath
	cPath=SET("Path")

	SET DEFAULT TO (ADDBS(_screen.cFilespath))
	LOCAL cOutputFile
	IF !EMPTY(cSaveFile)
		cOutputFile=cSaveFile
	ELSE
		cOutputFile=PUTFILE(ToEnglish("保存文件"),cPackageName,"dat")
	ENDIF
	IF Zip(cZipFilesList,cOutputFile,"hlh***TXK0921")
		IF !bNoShowMessage
			MessageBox1("生成文件成功！",0+64,"系统提示")
		ENDIF
		FOR i=1 TO GETWORDCOUNT(cZipFilesList,"|")
			ERASE (ADDBS(_screen.cFilespath)+GETWORDNUM(cZipFilesList,i,"|"))
		ENDFOR
	ELSE
		IF !bNoShowMessage
			MessageBox1("生成文件失败！",0+64,"系统提示")
		ENDIF
		FOR i=1 TO GETWORDCOUNT(cZipFilesList,"|")
			ERASE (ADDBS(_screen.cFilespath)+GETWORDNUM(cZipFilesList,i,"|"))
		ENDFOR
		SET DEFAULT TO (cDefaultPath)
		SET PATH to (cPath)
		RETURN .f.
	ENDIF
	SET DEFAULT TO (cDefaultPath)
	SET PATH TO (cPath)
	RETURN .t.
ENDPROC