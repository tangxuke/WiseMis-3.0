LPARAMETERS cUpdateType as String
IF VARTYPE(cUpdateType)<>"C"
	cUpdateType=""
ENDIF
IF cUpdateType<>"User"
	cUpdateType="System"
ENDIF

*!*检查字体
Local bCheckFont
bCheckFont=.T.
Local Array arrFonts(1)
If !Afont(arrFonts)
	bCheckFont=.F.
Endif

*!*同步局域网更新文件为最新状态
Local cFileName,cPathName,cMD5Code,bRegServer,bIsFont,cFontName,cGuid,cFileGuid
LOCAL cSyncUpdateSQL,cTempCursor
cSyncUpdateSQL="select Guid,FileName,PathName,FileGuid,Md5Code,IsRegisterFile,IsFont,FontName from WiseMis_Update where UpdateType='"+cUpdateType+"' order by SystemCode,(case when ISNULL(FileName,'')='' then 1 else 0 end) desc,OrderId"	&&优先创建目录
cTempCursor=SYS(2015)
IF !SelectData(cSyncUpdateSQL,cTempCursor)
	RETURN .f.
ENDIF

SELECT (cTempCursor)
SCAN
	cGuid=ALLTRIM(NVL(Guid,""))
	cFileName=Alltrim(Nvl(FileName,""))
	cPathName=ParsePath(Alltrim(Nvl(PathName,"")))
	cFileGuid=ALLTRIM(NVL(FileGuid,""))
	cMD5Code=Alltrim(Nvl(Md5Code,""))
	bRegServer=Nvl(IsRegisterFile,.F.)
	bIsFont=Nvl(IsFont,.F.)
	cFontName=Alltrim(Nvl(FontName,""))

	*!*检查并创建目录
	If !Directory(cPathName,1)
		=APICreateDirectory(cPathName)
	ENDIF
	IF DIRECTORY(cPathName,1)
		SET PATH TO (cPathName) ADDITIVE
	ENDIF
	*!*检查并创建文件
	IF EMPTY(cFileName)
		LOOP
	ENDIF
	cFileName=ADDBS(cPathName)+cFileName
	LOCAL bIsNewFile
	bIsNewFile=.t.
	IF FILE(cFileName)
		LOCAL cFileMd5Code
		cFileMd5Code=MD5File(cFileName)
		IF LOWER(cFileMd5Code)==LOWER(cMD5Code)
			bIsNewFile=.f.
		ENDIF
	ENDIF
	*!*下载并创建文件
	IF bIsNewFile
		LOCAL __cFileName,__cExtName,__cFileStream
		IF !GetFileFromDB(cFileGuid,@__cFileName,@__cExtName,@__cFileStream)
			*=CloseAlias(cTempCursor)
			*RETURN .f.
			LOOP
		ENDIF

		*恢复游标指针
		SELECT (cTempCursor)
		=STRTOFILE(__cFileStream,cFileName)
		IF !FILE(cFileName)
			*=CloseAlias(cTempCursor)
			*RETURN .f.
			LOOP
		ENDIF
	ENDIF
	*!*注册文件
	IF bRegServer
		=RegisterFile(cFileName)
	ENDIF
	*!*安装字体
	LOCAL bIsNewFont
	bIsNewFont=.t.
	If bIsFont And !Empty(cFontName)
		FOR iFont=1 TO GETWORDCOUNT(cFontName,",")
			IF ASCAN(arrFonts,GETWORDNUM(cFontName,iFont,","),-1,-1,-1,1)>0
				bIsNewFont=.F.
			ENDIF
		ENDFOR
	ENDIF
	If bIsFont AND bIsNewFont
		=InstallFont(cFontName,cFileName)
	Endif
ENDSCAN
*!*关闭游标
=CloseAlias(cTempCursor)

*!*检查是否更新了主程序
Local cMainExeFile
cMainExeFile=Addbs(ParsePath("{app}"))+"Update\WiseMis.exe"
LOCAL bUpdateMainExe	&&是否更新主程序
bUpdateMainExe=.t.
If File(cMainExeFile)
	IF FILE(Addbs(ParsePath("{app}"))+"WiseMis.exe")
		If MD5File(cMainExeFile)==MD5File(Addbs(ParsePath("{app}"))+"WiseMis.exe")
			bUpdateMainExe=.f.
		ENDIF
	ENDIF
ELSE
	bUpdateMainExe=.f.
ENDIF

IF !bUpdateMainExe
	RETURN .t.
ENDIF

*!*复制文件
LOCAL cRootPath,cUpdateExe,cMainExe
cRootPath=ParsePath("{app}")
SET DEFAULT TO (cRootPath)
cMainExe=ADDBS(cRootPath)+"WiseMis.exe"

IF FILE(cMainExe)
	LOCAL nTestHandle
	nTestHandle=FOPEN(cMainExe,1)
	=FCLOSE(nTestHandle)
	IF !(nTestHandle>0)
		RETURN .t.
	ENDIF
ENDIF

cUpdateExe=ADDBS(cRootPath)+"Update\WiseMis.exe"
IF FILE(cUpdateExe)
	LOCAL bNewVersion
	bNewVersion=.t.
	IF FILE(cMainExe)
		IF MD5File(cUpdateExe)==MD5File(cMainExe)
			bNewVersion=.f.
		ENDIF
	ENDIF
	IF bNewVersion
		IF FILE(cMainExe)
			ERASE (cMainExe)
		ENDIF
		=CopyFiles(cUpdateExe,cMainExe)
	ENDIF
ENDIF

RETURN .t.
