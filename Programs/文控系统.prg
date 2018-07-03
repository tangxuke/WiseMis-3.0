PROCEDURE WK_GetFile
	LPARAMETERS cFileCode,cEdition,cFileName
	LOCAL cFileStream
	cFileStream=""
	IF !GetValue("select dbo.WiseMis_File_TestViewRight('"+cFileCode+"','"+cEdition+"')")
		MESSAGEBOX("你无权查看此文件！",0+64,"系统提示")
		RETURN .f.
	ENDIF 
	LOCAL cExtName
	cExtName=GetValue("select ExtName from WiseMis_File_Library where FileCode='"+cFileCode+"' and Edition='"+cEdition+"'")
	IF VARTYPE(cExtName)<>"C" OR EMPTY(cExtName)
		MESSAGEBOX("文件不存在！",0+64,"系统提示")
		RETURN .f.
	ENDIF 
	IF VARTYPE(cFileName)<>"C" OR EMPTY(cFileName)
		cFileName=PUTFILE("保存文件",cFileCode+"_"+STRTRAN(cEdition,".","_"),cExtName)
	ENDIF 
	IF EMPTY(cFileName)
		RETURN .f.
	ENDIF 
	LOCAL cSql,cTempCursor
	cSql="select * from dbo.WiseMis_File_GetFile('"+cFileCode+"','"+cEdition+"')"
	cTempCursor=SYS(2015)
	IF !SelectData(cSql,cTempCursor)
		MESSAGEBOX("查询文件失败！",0+64,"系统提示")
		RETURN .f.
	ELSE
		LOCAL nHandle
		nHandle=FCREATE(cFileName)
		SELECT (cTempCursor)
		SCAN 
			cFileStream=FileData
			DO WHILE LEN(cFileStream)>0
				IF FWRITE(nHandle,cFileStream,1024*1024)=0
					MESSAGEBOX("建立文件失败！",0+64,"系统提示")
					=CloseAlias(cTempCursor)
					RETURN .f.
				ELSE
					cFileStream=SUBSTR(cFileStream,1024*1024+1)
				ENDIF 
			ENDDO
		ENDSCAN 
		=CloseAlias(cTempCursor)
		=FCLOSE(nHandle)
		=RunFile(cFileName)
		RETURN .t.
	ENDIF 
ENDPROC 