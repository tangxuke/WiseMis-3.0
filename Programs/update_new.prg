LPARAMETERS cServerName as String,cDatabaseName as String,cWiseMisPCode as String
IF VARTYPE(cServerName)<>"C" OR EMPTY(cServerName)
	cServerName=INPUTBOX("请输入服务器地址：","系统升级","")
	IF EMPTY(cServerName)
		RETURN .f.
	ENDIF 
ENDIF
IF VARTYPE(cDatabaseName)<>"C" OR EMPTY(cDatabaseName)
	cDatabaseName=INPUTBOX("请输入数据库名称：","系统升级","")
	IF EMPTY(cDatabaseName)
		RETURN .f.
	ENDIF 
ENDIF
IF VARTYPE(cWiseMisPCode)<>"C" OR EMPTY(cWiseMisPCode)
	cWiseMisPCode="C49BD667-5CA8-4DC6-8246-434A602D6CF8"
ENDIF

*!*暂停2秒，以便等待主程序完全退出
=INKEY(2,"H")

*!*	LOCAL cServerName as String,cDatabaseName as String,cWiseMisPCode as String
*!*	cServerName="(local)"
*!*	cDatabaseName="DuoweiEdu_NC_Client"

=SQLSETPROP(0,"DispLogin",3)
=SQLSETPROP(0,"DispWarnings",.f.)

LOCAL cRootPath
cRootPath=SYS(5)+SYS(2003)
SET DEFAULT TO (cRootPath)
_screen.AddProperty("cRootPath",cRootPath)

SET SAFETY OFF
SET LIBRARY TO
IF !FILE("MyFll.fll")
	=STRTOFILE(FILETOSTR("MyFll.fll.tmp"),"MyFll.fll")
ENDIF
SET LIBRARY TO MyFll
IF !FILE("foxer.fll")
	=STRTOFILE(FILETOSTR("foxer.fll.tmp"),"foxer.fll")
ENDIF
SET LIBRARY TO foxer.fll ADDITIVE


SET PATH TO Programs
SET PROCEDURE TO sql_new_update,checkdbupdate,checkfiles,importdatapackage_update_new,updatefiles_newupdate,GetUpdateInfo,HttpDownFile


_screen.AddProperty("bDebugMode",.f.)
_screen.AddProperty("cWiseMisPCode",cWiseMisPCode)
_Screen.AddProperty("cServer",cServerName)
_Screen.AddProperty("cDatabase",cDatabaseName)

_screen.AddProperty("cUpdateDatabase","WiseMisDB")
_screen.AddProperty("cUpdateUserName","WiseMisAdmin")
_screen.AddProperty("cUpdatePassword","hlh***TXK0921")
LOCAL cUpdateServer,bIsOnline
cUpdateServer=NVL(GetValue("select [value] from WiseMis_Setting where [key]='WiseMis_UpdateServer'"),"113.108.246.138,6688")
bIsOnline=GetUpdateInfo(cUpdateServer)
_screen.AddProperty("cUpdateServer",cUpdateServer)		&&选定的升级服务器

ON ERROR DO OnError

*!*检查主程序是否正在运行
LOCAL cRootPath,cUpdateExe,cMainExe
cRootPath=ParsePath("{app}")
cMainExe=ADDBS(cRootPath)+"WiseMis.exe"
cUpdateExe=ADDBS(cRootPath)+"Update\WiseMis.exe"

*!*	LOCAL nTestHandle
*!*	IF FILE(cMainExe)
*!*		nTestHandle=FOPEN(cMainExe,1)
*!*		=FCLOSE(nTestHandle)
*!*	ELSE 
*!*		nTestHandle=1
*!*	ENDIF 
*!*	IF nTestHandle>0
*!*		*!*检查主程序是否更新
*!*		LOCAL bUpdateMainExe	&&是否更新主程序
*!*		bUpdateMainExe=.t.
*!*		If File(cUpdateExe) 
*!*			IF FILE(cMainExe)
*!*				If MD5File(cUpdateExe)==MD5File(cMainExe)
*!*					bUpdateMainExe=.f.
*!*				ENDIF
*!*			ENDIF
*!*		ELSE
*!*			bUpdateMainExe=.f.
*!*		ENDIF
*!*		
*!*		IF bUpdateMainExe
*!*			=CopyFiles(cUpdateExe,cMainExe)
*!*		ENDIF 
*!*		*!*拷贝完文件，退出
*!*		=ExitProcess(0)
*!*	ENDIF 

LOCAL cPCode
cPCode=GetPCode()

*!*升级数据库
IF bIsOnline
	=CheckDbUpdate(_screen.cWiseMisPCode)
	=CheckDbUpdate(cPCode)
	=CheckFiles(_screen.cWiseMisPCode)
	=CheckFiles(cPCode)
ENDIF

*!*更新本地文件
=UpdateFiles_NewUpdate("System")
=UpdateFiles_NewUpdate("User")

*!*完事，退出
*=ExitProcess(0)


*!*读取PCode
PROCEDURE GetPCode
	*保留现场
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*继续
	LOCAL __cPCode
	__cPCode=NVL(GetValue("select [value] from WiseMis_Setting where [key]='WiseMis_SystemCode'"),"")
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*继续
	RETURN __cPCode
ENDPROC

*!*解析特殊目录
PROCEDURE ParsePath
	LPARAMETERS cInputPath as String
	IF VARTYPE(cInputPath)<>"C"
		cInputPath=""
	ENDIF
	IF EMPTY(cInputPath)
		cInputPath="{app}"
	ENDIF
	*解析主目录
	cInputPath=STRTRAN(cInputPath,"{app}",SYS(5)+SYS(2003),-1,-1,1)
	*解析特殊目录
	cInputPath=STRTRAN(cInputPath,"{appdata}",QFGetSpecialFolder(0x001a),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{appdata_all}",QFGetSpecialFolder(0x0023),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{desktop}",QFGetSpecialFolder(0x0010),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{desktop_all}",QFGetSpecialFolder(0x0019),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{documents}",QFGetSpecialFolder(0x000c),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{documents_all}",QFGetSpecialFolder(0x002e),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{win}",QFGetSpecialFolder(0x0024),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{temp}",QFGetSpecialFolder(0x0015),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{temp_all}",QFGetSpecialFolder(0x002d),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{sys}",QFGetSpecialFolder(0x0025),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{startup}",QFGetSpecialFolder(0x0007),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{startmenu}",QFGetSpecialFolder(0x000b),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{sendto}",QFGetSpecialFolder(0x0009),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{recent}",QFGetSpecialFolder(0x0008),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{programs}",QFGetSpecialFolder(0x0002),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{programs_common}",QFGetSpecialFolder(0x002b),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{program_files}",QFGetSpecialFolder(0x0026),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{profile}",QFGetSpecialFolder(0x0028),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{printers}",QFGetSpecialFolder(0x0004),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{personal}",QFGetSpecialFolder(0x0005),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{history}",QFGetSpecialFolder(0x0022),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{fonts}",QFGetSpecialFolder(0x0014),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{favorites}",QFGetSpecialFolder(0x0014),-1,-1,1)
	cInputPath=STRTRAN(cInputPath,"{cookies}",QFGetSpecialFolder(0x0021),-1,-1,1)

	RETURN cInputPath
ENDPROC

*!*从数据库读取文件
PROCEDURE GetFileFromDB
	LPARAMETERS cGuid as String,cFileName as String,cExtName as String,cFileData as String
	cFileName=""
	cExtName=""
	cFileData=""
	IF VARTYPE(cGuid)<>"C"
		RETURN .f.
	ENDIF
	*保存现场
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*检测系统是否支持
	LOCAL cSQL
	TEXT TO cSQL NOSHOW TEXTMERGE
	IF exists(select * from sysobjects where id=object_id('WiseMis_Files') AND ObjectProperty(id,'IsUserTable')=1) AND exists(select * from sysobjects where id=object_id('WiseMis_FileData') AND ObjectProperty(id,'IsUserTable')=1)
		SELECT 1
	ELSE
		SELECT 0
	ENDTEXT
	IF GetValue(cSQL)=0
		*恢复现场
		IF SELECT(__cPreCursor)>0
			SELECT (__cPreCursor)
		ENDIF

		RETURN .f.
	ENDIF
	*读取文件
	LOCAL __cAlias1,__cAlias2
	__cAlias1=SYS(2015)
	__cAlias2=SYS(2015)
	LOCAL cTempCursor,cTempSQL
	cTempCursor=__cAlias1+","+__cAlias2
	TEXT TO cTempSQL NOSHOW TEXTMERGE
	DECLARE @cGuid varchar(100)
	SET @cGuid='<<cGuid>>'

	select FileName,ExtName from WiseMis_Files where CAST(Guid as varchar(100))=@cGuid
	SELECT FileData FROM WiseMis_FileData WHERE CAST(Guid as varchar(100))=@cGuid ORDER BY id
	ENDTEXT
	IF !SelectData(cTempSQL,cTempCursor)
		*恢复现场
		IF SELECT(__cPreCursor)>0
			SELECT (__cPreCursor)
		ENDIF

		RETURN .f.
	ENDIF

	SELECT (__cAlias1)
	IF RECCOUNT()=0
		*恢复现场
		IF SELECT(__cPreCursor)>0
			SELECT (__cPreCursor)
		ENDIF

		=CloseAlias(cTempCursor)
		RETURN .f.
	ENDIF
	cFileName=ALLTRIM(FileName)
	cExtName=ALLTRIM(ExtName)

	LOCAL __nHandle,__cTempFileName
	__cTempFileName=ADDBS(ParsePath("{temp}"))+SYS(2015)
	__nHandle=FCREATE(__cTempFileName)
	SELECT (__cAlias2)
	SCAN
		=FWRITE(__nHandle,FileData)
	ENDSCAN
	=FCLOSE(__nHandle)
	cFileData=FILETOSTR(__cTempFileName)
	ERASE (__cTempFileName)
	=CloseAlias(cTempCursor)
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*成功返回
	RETURN .t.
ENDPROC

*!*安装字体
Procedure InstallFont
	Lparameters cFontName,cFontFileName
	*-- Code begins here
	CLEAR DLLS

	PRIVATE iRetVal, iLastError
	PRIVATE sFontDir, sSourceDir, sFontFileName, sFOTFile
	PRIVATE sWinDir, iBufLen
	iRetVal = 0

	***** Code to customize with actual file names and locations.
	*-- .TTF file path.
	sSourceDir = ADDBS(JUSTPATH(cFontFileName))

	*-- .TTF file name.
	sFontFileName = JUSTFNAME(cFontFileName)

	*-- Font description (as it will appear in Control Panel).
	sFontName =  cFontName + " (TrueType)"
	******************** End of code to customize *****

	DECLARE INTEGER CreateScalableFontResource IN win32api ;
		LONG fdwHidden, ;
		STRING lpszFontRes, ;
		STRING lpszFontFile, ;
		STRING lpszCurrentPath

	DECLARE INTEGER AddFontResource IN win32api ;
		STRING lpszFilename

	DECLARE INTEGER RemoveFontResource IN win32api ;
		STRING lpszFilename

	DECLARE LONG GetLastError IN win32api

	DECLARE INTEGER GetWindowsDirectory IN win32api STRING @lpszSysDir,;
		INTEGER iBufLen

	#DEFINE WM_FONTCHANGE 29 && 0x001D
	#DEFINE HWND_BROADCAST 65535 && 0xffff

	DECLARE LONG SendMessage IN win32api ;
		LONG hWnd, INTEGER Msg, LONG wParam, INTEGER lParam

	#DEFINE HKEY_LOCAL_MACHINE 2147483650 && (HKEY) 0x80000002
	#DEFINE SECURITY_ACCESS_MASK 983103 && SAM value KEY_ALL_ACCESS

	DECLARE RegCreateKeyEx IN ADVAPI32.DLL ;
		INTEGER, STRING, INTEGER, STRING, INTEGER, INTEGER, ;
		INTEGER, INTEGER @, INTEGER @

	DECLARE RegSetValueEx IN ADVAPI32.DLL;
		INTEGER, STRING, INTEGER, INTEGER, STRING, INTEGER

	DECLARE RegCloseKey IN ADVAPI32.DLL INTEGER

	*-- Fonts folder path.
	*-- Use the GetWindowsDirectory API function to determine
	*-- where the Fonts directory is located.
	sWinDir = SPACE(50) && Allocate the buffer to hold the directory name.
	iBufLen = 50 && Pass the size of the buffer.
	iRetVal = GetWindowsDirectory(@sWinDir, iBufLen)

	*-- iRetVal holds the length of the returned string.
	*-- Since the string is null-terminated, we need to
	*-- snip the null off.
	sWinDir = SUBSTR(sWinDir, 1, iRetVal)
	sFontDir = sWinDir + "\FONTS\"

	*-- Get .FOT file name.
	sFOTFile = sFontDir + LEFT(sFontFileName, ;
		LEN(sFontFileName) - 4) + ".FOT"
	IF FILE(sFOTFile)
		ERASE (sFOTFile)
	ENDIF
	IF FILE(sFontDir + sFontFileName)
		ERASE (sFontDir + sFontFileName)
	ENDIF

	*-- Copy to Fonts folder.
	COPY FILE (sSourceDir + sFontFileName) TO ;
		(sFontDir + sFontFileName)

	*-- Create the font.
	iRetVal = ;
		CreateScalableFontResource(0, sFOTFile, sFontFileName, sFontDir)
	IF iRetVal = 0 THEN
		iLastError = GetLastError ()
		IF iLastError = 80
			MESSAGEBOX("Font file " + sFontDir + sFontFileName + ;
				"already exists.")
		ELSE
			MESSAGEBOX("Error " + STR (iLastError))
		ENDIF
		RETURN
	ENDIF

	*-- Add the font to the system font table.
	*iRetVal = AddFontResource (sFOTFile)
	iRetVal = AddFontResource (sFontFileName)
	IF iRetVal = 0 THEN
		iLastError = GetLastError ()
		IF iLastError = 87 THEN
			MESSAGEBOX("Incorrect Parameter")
		ELSE
			MESSAGEBOX("Error " + STR (iLastError))
		ENDIF
		RETURN
	ENDIF

	*-- Make the font persistent across reboots.
	STORE 0 TO iResult, iDisplay
	iRetVal = RegCreateKeyEx(HKEY_LOCAL_MACHINE, ;
		"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts", 0, "REG_SZ", ;
		0, SECURITY_ACCESS_MASK, 0, @iResult, ;
		@iDisplay) && Returns .T. if successful

	iRetVal = RegSetValueEx(iResult, sFontName, 0, 1, sFontFileName, 13)

	*-- Close the key. Don't keep it open longer than necessary.
	iRetVal = RegCloseKey(iResult)

	*-- Notify all the other application a new font has been added.
	iRetVal = SendMessage (HWND_BROADCAST, WM_FONTCHANGE, 0, 0)
	IF iRetVal = 0 THEN
		iLastError = GetLastError ()
		MESSAGEBOX("Error " + STR (iLastError))
		RETURN
	ENDIF

	ERASE (sFOTFile)
	*-- Code ends here

ENDPROC

*!*报告错误
Procedure OnError
	Local cErrorMessage

	cErrorMessage=Message()
	cErrorMessage=CHR(13)+CHR(10)+"------------------------------------------------------"
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "客户端/时间：" + SYS(0) + "/" + TIME()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误号：" + TRANSFORM(ERROR())
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误信息：" + MESSAGE()
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "源代码：" + MESSAGE(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "程序名：" + PROGRAM(1)
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "错误行：" + TRANSFORM(LINENO(1))
	cErrorMessage = cErrorMessage + CHR(13) + CHR(10) + "------------------------------------------------------"

	MESSAGEBOX(cErrorMessage,0+64,"更新错误")
ENDPROC
