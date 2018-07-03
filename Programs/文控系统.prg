PROCEDURE WK_GetFile
	LPARAMETERS cFileCode,cEdition,cFileName
	LOCAL cFileStream
	cFileStream=""
	IF !GetValue("select dbo.WiseMis_File_TestViewRight('"+cFileCode+"','"+cEdition+"')")
		MESSAGEBOX("����Ȩ�鿴���ļ���",0+64,"ϵͳ��ʾ")
		RETURN .f.
	ENDIF 
	LOCAL cExtName
	cExtName=GetValue("select ExtName from WiseMis_File_Library where FileCode='"+cFileCode+"' and Edition='"+cEdition+"'")
	IF VARTYPE(cExtName)<>"C" OR EMPTY(cExtName)
		MESSAGEBOX("�ļ������ڣ�",0+64,"ϵͳ��ʾ")
		RETURN .f.
	ENDIF 
	IF VARTYPE(cFileName)<>"C" OR EMPTY(cFileName)
		cFileName=PUTFILE("�����ļ�",cFileCode+"_"+STRTRAN(cEdition,".","_"),cExtName)
	ENDIF 
	IF EMPTY(cFileName)
		RETURN .f.
	ENDIF 
	LOCAL cSql,cTempCursor
	cSql="select * from dbo.WiseMis_File_GetFile('"+cFileCode+"','"+cEdition+"')"
	cTempCursor=SYS(2015)
	IF !SelectData(cSql,cTempCursor)
		MESSAGEBOX("��ѯ�ļ�ʧ�ܣ�",0+64,"ϵͳ��ʾ")
		RETURN .f.
	ELSE
		LOCAL nHandle
		nHandle=FCREATE(cFileName)
		SELECT (cTempCursor)
		SCAN 
			cFileStream=FileData
			DO WHILE LEN(cFileStream)>0
				IF FWRITE(nHandle,cFileStream,1024*1024)=0
					MESSAGEBOX("�����ļ�ʧ�ܣ�",0+64,"ϵͳ��ʾ")
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