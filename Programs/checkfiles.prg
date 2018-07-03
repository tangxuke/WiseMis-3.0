LPARAMETERS cSystemName as String
IF VARTYPE(cSystemName)<>"C" OR EMPTY(cSystemName)
	RETURN .f.
ENDIF
Local cUnZipPath
cUnZipPath=GETENV("TEMP")

*!*构造传入参数
LOCAL cTempUpdateCursor,cInputString
cTempUpdateCursor=SYS(2015)
cInputString=""
IF !SelectData("select CAST(Guid as varchar(100)) as Guid,(case when FileGuid is null then '' else Md5Code end) as Md5Code from WiseMis_Update where CAST(SystemCode as varchar(100))='"+cSystemName+"'",cTempUpdateCursor)
	RETURN .f.
ENDIF
SELECT (cTempUpdateCursor)
SCAN
	cInputString = cInputString + "," + ALLTRIM(NVL(Guid,"")) + ":" + ALLTRIM(NVL(Md5Code,""))
ENDSCAN
=CloseAlias(cTempUpdateCursor)

LOCAL cSQL,cTempCursor
TEXT TO cSQL NOSHOW TEXTMERGE
exec CheckFiles '<<cSystemName>>','<<cInputString>>'
ENDTEXT
cTempCursor=SYS(2015)+","+SYS(2015)
IF !SelectData(cSQL,cTempCursor,_screen.cUpdateServer,_screen.cUpdateDatabase,_screen.cUpdateUserName,_screen.cUpdatePassword)
	RETURN .f.
ENDIF
*!*升级新文件
SELECT (GETWORDNUM(cTempCursor,1,","))
SCAN
	Local cFileName,cPathName,cMD5Code,bRegServer,bZip,bNewFile,bIsFont,cFontName,nId,cOldPathName,cGuid,cDownloadUrl,cDownloadUrl2,nOrderId,bIsTestVersion
	cFileName=Alltrim(Nvl(F030,""))
	cPathName=Alltrim(Nvl(F040,""))
	cMD5Code=Alltrim(Nvl(F060,""))
	bRegServer=Nvl(F080,.F.)
	bZip=Nvl(F090,.F.)
	bIsFont=Nvl(F100,.F.)
	cFontName=Alltrim(Nvl(F110,""))
	cGuid=ALLTRIM(NVL(F130,""))
	nOrderId=NVL(F070,0)
	cDownloadUrl=ALLTRIM(NVL(F140,""))
	cDownloadUrl2=ALLTRIM(NVL(F145,""))
	bIsTestVersion=NVL(F150,.f.)

	*!*下载服务器文件并解压
	LOCAL cUpdateSQL
	cUpdateSQL ="delete from WiseMis_Files where exists(select * from WiseMis_Update where FileGuid=WiseMis_Files.Guid and CAST(Guid as varchar(100))='"+cGuid+"')"
	cUpdateSQL = cUpdateSQL + CHR(13) + CHR(10)
	cUpdateSQL = cUpdateSQL + "delete from WiseMis_Update where CAST(Guid as varchar(100))='"+cGuid+"'"
	cUpdateSQL = cUpdateSQL + CHR(13) + CHR(10)
	IF !bIsTestVersion
		cUpdateSQL = cUpdateSQL + "insert into WiseMis_Update(Guid, SystemCode, UpdateType, OrderId, PathName, FileName, Md5Code, FileGuid, IsRegisterFile, IsFont, FontName) values ("
		cUpdateSQL = cUpdateSQL + "'" + cGuid + "'"
		cUpdateSQL = cUpdateSQL + ",'" + cSystemName + "'"
		cUpdateSQL = cUpdateSQL + ",'System'"
		cUpdateSQL = cUpdateSQL + "," + TRANSFORM(nOrderId)
		cUpdateSQL = cUpdateSQL + ",'" + cPathName + "'"
		cUpdateSQL = cUpdateSQL + ",'" + cFileName + "'"
		cUpdateSQL = cUpdateSQL + ",'" + cMd5Code + "'"
		
		LOCAL cFileGuid
		cFileGuid=GetGUID(3)
		IF !EMPTY(cFileName)
			Local cTempFile,cFileStream
			cTempFile=Addbs(Getenv("TEMP"))+Sys(2015)
			IF !HttpDownFile(cDownloadUrl,cTempFile)
				IF !HttpDownFile(cDownloadUrl2,cTempFile)
					LOOP 
				ENDIF 
			ENDIF
			IF !FILE(cTempFile)
				LOOP 
			ENDIF
			*检查下载后的文件Md5Code是否正确
			If bZip
				If UnZip(cTempFile,cUnZipPath)
					IF FILE(Addbs(cUnZipPath)+cFileName)
						IF ALLTRIM(LOWER(MD5File(Addbs(cUnZipPath)+cFileName)))<>ALLTRIM(LOWER(cMd5Code))
							LOOP 
						ENDIF 
					ELSE
						LOOP 
					ENDIF 
					cFileStream=FILETOSTR(Addbs(cUnZipPath)+cFileName)
					Erase (Addbs(cUnZipPath)+cFileName)
				ELSE
					LOOP 
				Endif
			ELSE
				LOCAL cMd5File
				cMd5File=MD5File(cTempFile)
				IF ALLTRIM(LOWER(cMd5File))<>ALLTRIM(LOWER(cMd5Code))
					LOOP 
				ENDIF 
				cFileStream=FILETOSTR(cTempFile)
			ENDIF
			cFileStream=STRCONV(cFileStream,15)
			ERASE (cTempFile)
			
			IF !Execute("insert into WiseMis_Files(Guid,FileName,ExtName) values ('"+cFileGuid+"','"+JUSTSTEM(cFileName)+"','"+JUSTEXT(cFileName)+"')")
				LOOP 
			ENDIF 
			DO WHILE LEN(cFileStream)>0
				IF !Execute("insert into WiseMis_FileData(Guid,FileData) values ('"+cFileGuid+"',0x"+LEFT(cFileStream,1024*1024)+")")
					=Execute("delete from WiseMis_Files where CAST(Guid as varchar(100))='"+cFileGuid+"'")
					LOOP 
				ENDIF 
				cFileStream=SUBSTR(cFileStream,1024*1024+1)
			ENDDO
			
			cUpdateSQL = cUpdateSQL + ",'"+cFileGuid+"'"
			
		ELSE
			cUpdateSQL = cUpdateSQL + ",null"
		ENDIF
		cUpdateSQL = cUpdateSQL + "," + IIF(bRegServer,"1","0")
		cUpdateSQL = cUpdateSQL + "," + IIF(bIsFont,"1","0")
		cUpdateSQL = cUpdateSQL + ",'" + cFontName + "'"
		cUpdateSQL = cUpdateSQL + ")"
	ENDIF 
	*!*更新
	IF !Execute(cUpdateSQL)
		=Execute("delete from WiseMis_Files where CAST(Guid as varchar(100))='"+cFileGuid+"'")
		LOOP 
	ENDIF

	SELECT (GETWORDNUM(cTempCursor,1,","))
ENDSCAN
*!*删除已失效的文件
SELECT (GETWORDNUM(cTempCursor,2,","))
SCAN
	Local cGuid
	cGuid=ALLTRIM(NVL(Guid,""))

	*!*下载服务器文件并解压
	LOCAL cUpdateSQL
	cUpdateSQL="delete from WiseMis_Files where exists(select * from WiseMis_Update where FileGuid=WiseMis_Files.Guid and CAST(Guid as varchar(100))='"+cGuid+"')"
	cUpdateSQL = cUpdateSQL + CHR(13) + CHR(10)
	cUpdateSQL = cUpdateSQL + "delete from WiseMis_Update where CAST(Guid as varchar(100))='"+cGuid+"'"
	*!*更新
	IF !Execute(cUpdateSQL)
		LOOP 
	ENDIF

	SELECT (GETWORDNUM(cTempCursor,2,","))
ENDSCAN
*!*关闭临时游标
=CloseAlias(cTempCursor)
*!*删除解压文件夹

RETURN .t.
