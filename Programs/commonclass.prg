*!*替换MessageBox
PROCEDURE MessageBox1
	LPARAMETERS eMessageText, nDialogBoxType, cTitleBarText, nTimeout
	IF VARTYPE(eMessageText)="C"
		eMessageText=ToEnglish(eMessageText)
	ENDIF 
	IF VARTYPE(cTitleBarText)<>"C"
		cTitleBarText="系统提示"
	ENDIF 
	cTitleBarText=ToEnglish(cTitleBarText)
	IF VARTYPE(nDialogBoxType)<>"N"
		nDialogBoxType=0
	ENDIF 
	RETURN MESSAGEBOX(eMessageText, nDialogBoxType, cTitleBarText)
ENDPROC 
*!*替换Inputbox
PROCEDURE InputBox1
	LPARAMETERS  cDialogCaption ,cInputPrompt,cDefaultValue , nTimeout ,cTimeoutValue,cCancelValue
	LOCAL cInputValue
	IF VARTYPE(cDialogCaption)="C"
		cDialogCaption=ToEnglish(cDialogCaption)
	ENDIF 
	IF VARTYPE(cInputPrompt)="C"
		cInputPrompt=ToEnglish(cInputPrompt)
	ENDIF 
	DO FORM frm_tool_inputbox WITH cInputPrompt , cDialogCaption , cDefaultValue TO cInputValue
	RETURN cInputValue
ENDPROC 

*!*返回配置值(系统)
PROCEDURE GetSystemSettingValue
	LPARAMETERS cSetting as String
	WITH _screen.oSettingObject as WiseMisSettingObject
		RETURN .GetSystemValue(cSetting)
	ENDWITH
ENDPROC
*!*设置配置值（系统）
PROCEDURE SetSystemSettingValue
	LPARAMETERS cSetting as String,cNewValue as String
	WITH _screen.oSettingObject as WiseMisSettingObject
		=.SetSystemValue(cSetting,cNewValue)
	ENDWITH
ENDPROC

*!*返回配置值
PROCEDURE GetSettingValue
	LPARAMETERS cSetting as String
	WITH _screen.oSettingObject as WiseMisSettingObject
		RETURN .GetValue(cSetting)
	ENDWITH
ENDPROC
*!*设置配置值
PROCEDURE SetSettingValue
	LPARAMETERS cSetting as String,cNewValue as String
	WITH _screen.oSettingObject as WiseMisSettingObject
		=.SetValue(cSetting,cNewValue)
	ENDWITH
ENDPROC

*!*获得更新信息
PROCEDURE GetUpdateInfo
	LPARAMETERS cUpdateServer
	
	LOCAL cUpdateFile,cUpdateServers
	cUpdateFile=ADDBS(_screen.cRootPath)+"update.txt"
	IF FILE(cUpdateFile)
		cUpdateServers=FILETOSTR(cUpdateFile)
	ENDIF
	
	IF EMPTY(cUpdateServers)
		cUpdateServers="113.108.246.138,6688"
	ENDIF 
	
	LOCAL nLines,nLine,cLine
	nLines=ALINES(arr,cUpdateServers)
	FOR nLine=1 TO nLines
		cLine=arr[nLine]
		IF LEFTC(ALLTRIM(cLine),1)=="#"
			LOOP 
		ENDIF 
		LOCAL nHandle
		nHandle=SQLSTRINGCONNECT("Driver={SQL Server};Server="+cLine+";Uid=WiseMisAdmin;Pwd=hlh***TXK0921")
		IF nHandle>0
			=cLine
			=SQLDISCONNECT(nHandle)
			EXIT 
		ENDIF 
	ENDFOR 
	
	IF EMPTY(cUpdateServer)
		cUpdateServer="113.108.246.138,6688"
	ENDIF 
ENDPROC

*!*从数据库中删除文件
PROCEDURE DeleteFileFromDB
	LPARAMETERS cFileGuid as String
	LOCAL cSQL
	TEXT TO cSQL NOSHOW TEXTMERGE
BEGIN TRANSACTION
DELETE FROM WiseMis_Files WHERE CAST(Guid as varchar(250))='<<cFileGuid>>'
IF @@error<>0
BEGIN
	ROLLBACK
	RETURN
END
DELETE FROM WiseMis_FileData WHERE CAST(Guid as varchar(250))='<<cFileGuid>>'
IF @@error<>0
BEGIN
	ROLLBACK
	RETURN
END
commit
	ENDTEXT
	IF !Execute(cSQL)
		RETURN .f.
	ENDIF
	LOCAL cTempFile
	cTempFile=ADDBS(_screen.cFilesPath)+cFileGuid
	IF FILE(cTempFile)
		=DeleteFiles(cTempFile)
	ENDIF

	RETURN .t.
ENDPROC

*!*获取编码规则
PROCEDURE GetCodeRule
	LPARAMETERS cRuleName as String

	LOCAL cPreCursor
	cPreCursor=ALIAS()

	LOCAL cRuleCode
	cRuleCode=GetValue("select RuleCode from WiseMis_CodeRule where RuleName='"+cRuleName+"'")
	
	IF SELECT(cPreCursor)>0
		SELECT (cPreCursor)
	ENDIF
	
	IF EMPTY(NVL(cRuleCode,""))
		MESSAGEBOX("编码规则["+cRuleName+"]不存在！",0+64,"系统提示")
		RETURN ""
	ENDIF 

	RETURN cRuleCode
ENDPROC

*!*获取基础数据对象
PROCEDURE GetBaseDataObject
	LPARAMETERS cBaseData as String

	LOCAL cPreCursor
	cPreCursor=ALIAS()

	LOCAL oBaseData as WiseMisBaseDataObject
	oBaseData=CREATEOBJECT("WiseMisBaseDataObject")
	LOCAL cSQL,cCursor
	cSQL="select * from WiseMis_BaseData where Name='"+cBaseData+"'"
	cCursor=SYS(2015)
	IF !SelectData(cSQL,cCursor)
		MESSAGEBOX1("基础数据对象["+cBaseData+"]不存在！",0+64,"系统提示")
		RETURN oBaseData
	ENDIF 
	SELECT (cCursor)
	oBaseData.LoadFromCursor()
	=CloseAlias(cCursor)
	
	IF SELECT(cPreCursor)>0
		SELECT (cPreCursor)
	ENDIF

	RETURN oBaseData
ENDPROC

*!*获取辅助资料对象
PROCEDURE GetItemData
	LPARAMETERS cItemName as String

	LOCAL cPreCursor,cItemData
	cPreCursor=ALIAS()
	cItemData=""
	
	LOCAL cSQL,cCursor
	cSQL="select * from WiseMis_ItemDataDetail where Name='"+cItemName+"' order by orderid,code"
	cCursor=SYS(2015)
	IF !SelectData(cSQL,cCursor)
		MESSAGEBOX("查询辅助资料["+cItemName+"]失败！",0+64,"系统提示")
		RETURN ""
	ENDIF 
	
	SELECT (cCursor)
	SCAN 
		cItemData = cItemData + IIF(EMPTY(cItemName),"",",") + RTRIM(ItemValue)
	ENDSCAN 
	=CloseAlias(cCursor)

	IF SELECT(cPreCursor)>0
		SELECT (cPreCursor)
	ENDIF

	RETURN cItemData
ENDPROC

*!*生成2维条码
PROCEDURE To2dBarCode
	LPARAMETERS cText,cFile,nSize,nType
	RETURN _screen.oBarCodeQR.QRBarcodeImage(cText,cFile,nSize,nType)
ENDPROC

*!*生成一维条码
PROCEDURE ToBarCode
	LPARAMETERS cText,cFile,nBarCodeType,nImageHeight
	IF VARTYPE(nBarCodeType)<>"N"
		nBarCodeType=120		&&默认39码
	ENDIF
	IF VARTYPE(nImageHeight)<>"N"
		nImageHeight=90
	ENDIF
	WITH _screen.oBarCode
		.nBarcodeType=nBarCodeType
		.nImageHeight=nImageHeight
		RETURN .BarcodeImage(cText,cFile)
	ENDWITH
ENDPROC

*!*获取树节点的长文本
PROCEDURE GetTreeNodeLongText
	LPARAMETERS cAppName,vFieldValue
	IF EMPTY(NVL(cAppName,""))
		RETURN ALLTRIM(TRANSFORM(vFieldValue))
	ENDIF
	IF EMPTY(NVL(vFieldValue,""))
		RETURN ALLTRIM(TRANSFORM(vFieldValue))
	ENDIF
	WITH _screen.oTreeNodeTexts as Collection
		IF .GetKey(ALLTRIM(LOWER(cAppName))+"_"+ALLTRIM(LOWER(TRANSFORM(vFieldValue))))>0
			RETURN .Item(ALLTRIM(LOWER(cAppName))+"_"+ALLTRIM(LOWER(TRANSFORM(vFieldValue))))
		ELSE
			RETURN ALLTRIM(TRANSFORM(vFieldValue))
		ENDIF
	ENDWITH
ENDPROC
*!*采集指纹
PROCEDURE GetFinger()
	LOCAL cFingerInfo
	DO FORM frm_finger TO cFingerInfo
	RETURN cFingerInfo
ENDPROC

PROCEDURE IsInnerVersion
	RETURN .f.
ENDPROC




*!*保存用户配置
PROCEDURE SaveUserSchame
	LOCAL cSQL,c
	cSQL=""

	IF !EMPTY(cSQL)
		cSQL="declare @UserName varchar(50)"+CHR(13)+CHR(10)+"set @UserName='"+_screen.cUserName+"'"+CHR(13)+CHR(10)+cSQL

		=Execute(cSQL)
	ENDIF
ENDPROC

*!*改编MessageBox
PROCEDURE MsgBox2
	LPARAMETERS eMessageText,nDialogBoxType,cTitleBarText,nTimeout
	IF !BITTEST(nDialogBoxType,0)
		*!*确定，无需返回值
		=SetStatusText(TRANSFORM(eMessageText))
		RETURN 1
	ELSE
		RETURN MessageBox1(eMessageText,nDialogBoxType,cTitleBarText,nTimeout)
	ENDIF
ENDPROC
*!*从数据库读取文件并返回文件名
PROCEDURE GetFileFromDB2
	LPARAMETERS cGuid as String,cDefaultFile as String
	IF VARTYPE(cDefaultFile)<>"C"
		cDefaultFile=""
	ENDIF 
	LOCAL cFileName as String,cExtName as String,cFileData as String
	STORE "" TO cFileName,cExtName,cFileData
	IF !GetFileFromDB(cGuid,@cFileName,@cExtName,@cFileData)
		RETURN cDefaultFile
	ENDIF 
	LOCAL cTempFile
	cTempFile=ADDBS(_screen.cFilesPath)+cFileName+"."+cExtName
	=STRTOFILE(cFileData,cTempFile)
	RETURN cTempFile
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
	cGuid=ALLTRIM(cGuid)
	IF FILE(ADDBS(_screen.cFilesPath)+cGuid)
		LOCAL cGuidFileData
		cGuidFileData=FILETOSTR(ADDBS(_screen.cFilesPath)+cGuid)
		IF EMPTY(cGuidFileData)
			RETURN .f.
		ENDIF
		cFileName=STREXTRACT(cGuidFileData,"<FileName>","</FileName>")
		cExtName=STREXTRACT(cGuidFileData,"<ExtName>","</ExtName>")
		cFileData=STREXTRACT(cGuidFileData,"<FileData>","</FileData>")
		cFileData=STRCONV(cFileData,16)
		RETURN .t.
	ENDIF
	*保存现场
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*!*		*检测系统是否支持
	*!*		LOCAL cSQL
	*!*		TEXT TO cSQL NOSHOW TEXTMERGE
	*!*		IF exists(select * from sysobjects where id=object_id('WiseMis_Files') AND ObjectProperty(id,'IsUserTable')=1) AND exists(select * from sysobjects where id=object_id('WiseMis_FileData') AND ObjectProperty(id,'IsUserTable')=1)
	*!*			SELECT 1
	*!*		ELSE
	*!*			SELECT 0
	*!*		ENDTEXT
	*!*		IF GetValue(cSQL)=0
	*!*			*恢复现场
	*!*			IF SELECT(__cPreCursor)>0
	*!*				SELECT (__cPreCursor)
	*!*			ENDIF

	*!*			RETURN .f.
	*!*		ENDIF
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
		=STRTOFILE("",ADDBS(_screen.cFilesPath)+cGuid)
		RETURN .f.
	ENDIF

	SELECT (__cAlias1)
	IF RECCOUNT()=0
		=CloseAlias(cTempCursor)
		*恢复现场
		IF SELECT(__cPreCursor)>0
			SELECT (__cPreCursor)
		ENDIF
		=DeleteFiles(ADDBS(_screen.cFilesPath)+cGuid)
		RETURN .f.
	ENDIF
	cFileName=ALLTRIM(FileName)
	cExtName=ALLTRIM(ExtName)

	LOCAL __nHandle,__cTempFileName
	__cTempFileName=ADDBS(_screen.cFilesPath)+SYS(2015)
	__nHandle=FCREATE(__cTempFileName)
	=SetStatusText(ToEnglish("正在读取文件")+"【"+cFileName+"."+cExtName+"】...")
	SELECT (__cAlias2)
	SCAN
		=FWRITE(__nHandle,FileData)
	ENDSCAN
	=SetStatusText("")
	=FCLOSE(__nHandle)
	cFileData=FILETOSTR(__cTempFileName)
	LOCAL cGuidFileData
	cGuidFileData="<FileName>"+cFileName+"</FileName><ExtName>"+cExtName+"</ExtName><FileData>"+STRCONV(cFileData,15)+"</FileData>"
	=STRTOFILE(cGuidFileData,ADDBS(_screen.cFilesPath)+cGuid)
	ERASE (__cTempFileName)
	=CloseAlias(cTempCursor)
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*成功返回
	RETURN .t.
ENDPROC

*!*保存文件到数据库
PROCEDURE SaveFileToDB
	LPARAMETERS cFileName as String,cReturnGuid as String

	cReturnGuid=""
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*检测文件是否存在
	IF VARTYPE(cFileName)<>"C"
		ERROR "文件不存在！"
		RETURN .f.
	ENDIF
	IF !FILE(cFileName)
		ERROR "文件不存在！"
		RETURN .f.
	ENDIF
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

		ERROR "系统不支持！"
		RETURN .f.
	ENDIF
	*保存文件头信息
	LOCAL cGuid
	cGuid=GetGUID(3)
	cSQL="insert into WiseMis_Files(Guid,FileName,ExtName) values ('"+cGuid+"','"+JUSTSTEM(cFileName)+"','"+JUSTEXT(cFileName)+"')"
	IF !Execute(cSQL)
		*恢复现场
		IF SELECT(__cPreCursor)>0
			SELECT (__cPreCursor)
		ENDIF

		ERROR "保存文件头信息失败！"
		RETURN .f.
	ENDIF
	*保存文件内容
	LOCAL __cFileStream
	__cFileStream=FILETOSTR(cFileName)
	DO WHILE LEN(__cFileStream)>0
		LOCAL __s
		__s=LEFT(__cFileStream,1024*1024)
		__cFileStream=SUBSTR(__cFileStream,1024*1024+1)
		__s=STRCONV(__s,15)
		cSQL="insert into WiseMis_FileData(Guid,FileData) values ('"+cGuid+"',0x"+__s+")"
		IF !Execute(cSQL)
			=Execute("delete from WiseMis_Files where CAST(Guid as varchar(100))='"+cGuid+"'")
			*恢复现场
			IF SELECT(__cPreCursor)>0
				SELECT (__cPreCursor)
			ENDIF

			ERROR "保存文件内容失败！"
			RETURN .f.
		ENDIF
	ENDDO
	LOCAL cGuidFileData
	cGuidFileData="<FileName>"+JUSTSTEM(cFileName)+"</FileName><ExtName>"+JUSTEXT(cFileName)+"</ExtName><FileData>"+STRCONV(__cFileStream,15)+"</FileData>"
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*保存成功
	cReturnGuid=cGuid
	RETURN .t.
ENDPROC

PROCEDURE Register_Dlls
	LOCAL cDlls
	cDlls=FILETOSTR("dlls.lst")
	LOCAL nLines,cLine
	nLines=ALINES(arr,cDlls)
	FOR nLine=1 TO nLines
		cLine=arr[nLine]
		=RegisterFile(cLine)
	ENDFOR
ENDPROC

PROCEDURE Decl_UKey_Dlls
	*!*释放Syunew3D.dll
	LOCAL bCheckDLL,cDllPath
	cDllPath=ADDBS(_screen.cRootPath)+"Syunew3D.Dll"
	bCheckDLL=.f.
	IF FILE(cDllPath,0)
		IF MD5File(cDllPath)=="C552D45CC37D8228549A018A68E5B990"
			bCheckDLL=.t.
		ENDIF
	ENDIF
	IF !bCheckDLL
		=STRTOFILE(FILETOSTR("Syunew3D.Dll.tmp"),cDllPath)
	ENDIF
	*!*声明函数库
	Declare Integer FindPort In Syunew3D.Dll Integer,String @
	Declare Integer FindPort_2  In Syunew3D.Dll Integer,Integer,Integer,String @
	Declare Integer YRead In Syunew3D.Dll String@,Integer,String,String,String
	Declare Integer YReadString In Syunew3D.Dll String@,Integer,Integer,String,String,String
	Declare Integer YWrite In Syunew3D.Dll Integer,Integer,String,String,String
	Declare Integer YWriteString In Syunew3D.Dll String,Integer,String,String,String
	Declare Integer sWrite_2 In Syunew3D.Dll Long,String
	Declare Integer sWrite In Syunew3D.Dll Long,String
	Declare Integer sRead In Syunew3D.Dll Long@,String
	Declare Integer sWriteEx In Syunew3D.Dll Long,Long@,String
	Declare Integer sWrite_2Ex In Syunew3D.Dll Long,Long@,String
	Declare Integer ReSet In Syunew3D.Dll As DogReset String
	Declare Integer SetCal In Syunew3D.Dll String,String,String,String,String
	Declare Integer SetCal_2 In Syunew3D.Dll String,String
	Declare Integer SetWritePassword In Syunew3D.Dll String,String,String,String,String
	Declare Integer SetReadPassword In Syunew3D.Dll String,String,String,String,String
	Declare Integer YReadEx In Syunew3D.Dll String@,Integer,Integer,String,String,String
	Declare Integer YWriteEx In Syunew3D.Dll String,Integer,Integer,String,String,String
	Declare Integer Cal In Syunew3D.Dll String,String@,String
	Declare Integer EncString In Syunew3D.Dll String,String@,String
ENDPROC

*!*创建系统快捷方式
PROCEDURE CreateWiseMisShortCut
	LPARAMETERS oLoginObject as WiseMisLoginObject
	IF VARTYPE(oLoginObject)<>"O"
		RETURN
	ENDIF
	Declare INTEGER GetModuleFileName IN kernel32 INTEGER hModule,STRING @ lpFilename,INTEGER  nSize
	lpFilename = SPACE(250)
	lnLen = GetModuleFileName (0, @lpFilename, Len(lpFilename))
	*!*创建快捷方式
	=CreateShortcut(lpFilename,oLoginObject.cSystemName,1,.f.,CHR(34)+oLoginObject.cSystemName+CHR(34),"快速启用WiseMis平台应用系统")
ENDPROC

*!*返回默认账号的密码
PROCEDURE GetWiseMisDefaultOperatorPassword
	LOCAL cN,cD,cM,cUpdateOperatorPassword
	cN="AC0E9585FD84BB7B64467EDBE000D74DA4F6D89AD491BB7A127DA61BD4CB09EAC6693ECE731C89A998EB58A94C0D13602FF4DC0F9763DA4330137BF2EBBE1F9D"
	cD="6F3F06C299C6A68A03ADE8FC357B95BA283D4A93E17950A47F2C2AA8B80F879AE87DC28B383D96957E665589445D78847451ADE7F34220040C41D29F22A979E9"
	cM="A3E97E342234E5CE8B22380269028B80B9E83CEE68781036E2AF9FDAF624A52144F3B206984F70F8C2CD3F6709CC39C2FDEECFF523107208E430EA3B692B29CF"
	cUpdateOperatorPassword=STRCONV(RSACalc(cN,cD,cM),16)
	RETURN cUpdateOperatorPassword
ENDPROC

*!*判断是否64位操作系统（这个函数预留在这里）
PROCEDURE Is64OS
	*!*现在没有能力去调用API函数，那就简单从目录结构去判断吧
	*!*64位操作系统的程序目录会含有一个如C:\Program Files (x86)，就根据这个判断吧
	IF LIKE("*(x86)",ALLTRIM(LOWER(ParsePath("{program_files}"))))
		RETURN .t.
	ELSE
		RETURN .f.
	ENDIF
ENDIF

*!*取编码规则生成的新编码
PROCEDURE GetNewID
	LPARAMETERS cRuleCode as String
	IF VARTYPE(cRuleCode)<>"C" OR EMPTY(cRuleCode)
		RETURN ""
	ENDIF
	LOCAL cSQL
	TEXT TO cSQL NOSHOW TEXTMERGE 
DECLARE @NewId varchar(50)
SET @NewId=dbo.WiseMis_GetNewId('<<cRuleCode>>',getdate())
SELECT @NewId
	ENDTEXT 
	
	LOCAL cNewId
	cNewId=GetValue(cSQL)
	RETURN NVL(cNewID,"")
ENDPROC

*!*保存编码规则生成的编码
PROCEDURE SaveNewId
	LPARAMETERS cRuleCode as String,cNewId as String
	LOCAL cSQL
	TEXT TO cSQL NOSHOW TEXTMERGE
IF NOT exists(select * from WiseMis_CodeRuleDetail where RuleName='<<cRuleCode>>' AND Id='<<cNewId>>')
	INSERT INTO WiseMis_CodeRuleDetail(RuleName,Id) VALUES ('<<cRuleCode>>','<<cNewId>>')
	ENDTEXT
	RETURN Execute(cSQL)
ENDPROC

*!*发送短信
PROCEDURE SendSMS
	LPARAMETERS cMobile,cText,tSendTime as Datetime
	*!*不再支持短信功能
	RETURN .f.
ENDPROC

*!*清除提醒信息
PROCEDURE ClearUserNotify
	=SendMessage(_screen.nMainWndHandle,8000)
	=SendMessage(_screen.nNavWndHandle,8000)
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

*!*下载文件，在主界面显示进度
PROCEDURE DownloadFile
	LPARAMETERS cFileURL,cLocalFile,cShowName
	*!*检测网络是否连通
	IF !NetTest()
		RETURN .f.
	ENDIF
	IF VARTYPE(cShowName)<>"C"
		cShowName=""
	ENDIF
	IF EMPTY(cShowName)
		cShowName=JUSTFNAME(cLocalFile)
	ENDIF
	=SetStatusText(ToEnglish("正在下载文件")+"【"+cShowName+"】,"+ToEnglish("请稍侯")+"......")
	_screen.bDownloadFinish=.f.
	_screen.bDownloadFailed=.f.
	_screen.nDownloadReceivedSecond=SECONDS()
	=DownFileX(cFileURL,cLocalFile,_screen.nMainWndHandle,9000)
	Do While !_screen.bDownloadFinish And !_screen.bDownloadFailed
		If Seconds()-_screen.nDownloadReceivedSecond>20
			=SetStatusText(ToEnglish("下载失败！"))
			_screen.bDownloadFailed=.t.
			Exit
		Endif
		=Inkey(0.1,"H")
	ENDDO
	=SetStatusText("")
	RETURN (_screen.bDownloadFinish AND !_screen.bDownloadFailed)
ENDPROC

*!*锁定系统
PROCEDURE LockSystem
	DO FORM frm_lock
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
			MessageBox1("Font file " + sFontDir + sFontFileName + ;
				"already exists.")
		ELSE
			MessageBox1("Error " + STR (iLastError))
		ENDIF
		RETURN
	ENDIF

	*-- Add the font to the system font table.
	*iRetVal = AddFontResource (sFOTFile)
	iRetVal = AddFontResource (sFontFileName)
	IF iRetVal = 0 THEN
		iLastError = GetLastError ()
		IF iLastError = 87 THEN
			MessageBox1("Incorrect Parameter")
		ELSE
			MessageBox1("Error " + STR (iLastError))
		ENDIF
		RETURN
	ENDIF

	*-- Make the font persistent across reboots.
	STORE 0 TO iResult, iDisplay
	iRetVal = RegCreateKeyEx(HKEY_LOCAL_MACHINE, ;
		"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts", 0, "REG_SZ", ;
		0, SECURITY_ACCESS_MASK, 0, @iResult, ;
		@iDisplay) && Returns .T. if successful

	*-- Uncomment the following lines to display information
	*!* *-- about the results of the function call.
	*!* WAIT WINDOW STR(iResult) && Returns the key handle
	*!* WAIT WINDOW STR(iDisplay) && Returns one of 2 values:
	*!* && REG_CREATE_NEW_KEY = 1
	*!* && REG_OPENED_EXISTING_KEY = 2

	iRetVal = RegSetValueEx(iResult, sFontName, 0, 1, sFontFileName, 13)

	*-- Close the key. Don't keep it open longer than necessary.
	iRetVal = RegCloseKey(iResult)

	*-- Notify all the other application a new font has been added.
	iRetVal = SendMessage (HWND_BROADCAST, WM_FONTCHANGE, 0, 0)
	IF iRetVal = 0 THEN
		iLastError = GetLastError ()
		MessageBox1("Error " + STR (iLastError))
		RETURN
	ENDIF

	ERASE (sFOTFile)
	*-- Code ends here



Endproc

*!*重新设置表格
Procedure ResetGrid
	Lparameters oGrid As Grid
	oGrid.ColumnCount=Fcount(oGrid.RecordSource)
	oGrid.HeaderHeight=26
	oGrid.RowHeight=24
	For i=1 To oGrid.ColumnCount
		With oGrid.Columns[i] As Column
			.ControlSource=Field(i,oGrid.RecordSource)
			With .Header1 As Header
				.Caption=ToEnglish(Field(i,oGrid.RecordSource),.t.)
				.Alignment= 2
				.FontBold= .T.
				.ForeColor= RGB(0,0,128)
				.FontName="微软雅黑"
				.FontSize=10
			ENDWITH
			.FontName="微软雅黑"
			.FontSize=9
			If Type(.ControlSource)="L"
				Local oColumn As Column
				oColumn=oGrid.Columns[i]
				With oColumn.Controls[2] As Control
					oColumn.RemoveObject(.Name)
				Endwith
				Local cTempName
				cTempName=Sys(2015)
				.Newobject (cTempName,"Checkbox")
				With .Controls[2] As Checkbox
					.BackStyle= 0
					.Caption=""
					.AutoSize= .F.
					.Alignment= 2
					.Centered= .T.
					.Visible= .T.
				Endwith
				.CurrentControl=cTempName
				.Alignment= 2
				.Width=40
				.Sparse=.F.
			Endif
			If Mod(i,2)=0
				.BackColor=Rgb(236,233,216)
			Else
				.BackColor=Rgb(255,255,255)
			Endif
		Endwith
	Endfor
	oGrid.AutoFit
	For Each oColumn As Column In oGrid.Columns
		oColumn.Width = oColumn.Width + 5
	Endfor
Endproc

*!*取得系统目录
Procedure GetSystemPath
	Local lpBuffer,nSize,nResult
	Declare Long GetSystemDirectory In Kernel32 String @lpBuffer,Long nSize
	lpBuffer=Space(200)
	nSize=200
	nResult=GetSystemDirectory(@lpBuffer,nSize)
	If nResult=0 Or nResult>nSize
		Return Getenv("SystemRoot")
	Else
		Return lpBuffer
	Endif
Endproc
*!*注册软件
Procedure Register
	Lparameters cRegisterCode As String,nRegType as Integer		&&注册码，注册类型：1 客户端，2 服务器端
	If Vartype(cRegisterCode)<>"C" Or Empty(cRegisterCode)
		MessageBox1(Strconv("D7A2B2E1C2EBCEAABFD5A3A1",16),0+64,Strconv("CFB5CDB3CCE1CABE",16))
		Return .F.
	ENDIF

	Local dExpireDate,nClientCount,nClientRegType
	dExpireDate=Date()
	nClientCount=0
	nClientRegType=0
	Local nRegisterResult

	nRegisterResult=ValidRegister(cRegisterCode,@dExpireDate,@nClientRegType,@nClientCount)
	If !Bittest(nRegisterResult,0)
		MessageBox1(Strconv("B4CBD7A2B2E1C2EBCEDED0A7BBF2D5DFD2D1B9FDC6DAA3A1",16),0+64,Strconv("CFB5CDB3CCE1CABE",16))
		Return .F.
	ENDIF
	IF nRegType=1
		Local cKeyFile
		cKeyFile=Addbs(GetSystemPath())+"WiseMisKey.ini"
		If iniWrite(Strconv(GetMCode(),15),cRegisterCode,"Register Code",cKeyFile)
			MessageBox1(Strconv("D7A2B2E1B3C9B9A6A3ACB0E6B1BEC0E0D0CDA3BAB1EAD7BCB0E6",16)+Strconv("A3ACB5BDC6DAC8D5CAC7A3BA",16)+Transform(dExpireDate),0+64,Strconv("CFB5CDB3CCE1CABE",16))
			Return .T.
		Else
			MessageBox1(Strconv("D7A2B2E1CAA7B0DCA3ACC7EBBCECB2E9CEC4BCFED0B4C8EBC8A8CFDEA3A1",16),0+64,Strconv("CFB5CDB3CCE1CABE",16))
			Return .F.
		ENDIF
	ELSE
		WITH _screen.oSettingObject as WiseMisSettingObject
			RETURN .SetSystemValue("WiseMis_RegisterCode",cRegisterCode)
		ENDWITH
	ENDIF
ENDPROC

PROCEDURE GetPCode
	WITH _screen.oSettingObject as WiseMisSettingObject
		RETURN .GetSystemValue("WiseMis_SystemCode")
	ENDWITH
ENDPROC


*!*验证注册码
Procedure ValidRegister
	Lparameters cRegisterCode,dExpireDate As Date,nClientRegType as Integer,nClientCount as Integer		&&客户端注册模式：0 单机注册  1 服务器注册，客户端同时在线数
	_screen.cUKeyId="（无）"
	nClientRegType=0
	nClientCount=0
	LOCAL cPCode
	cPCode=""
	LOCAL nValidCode
	nValidCode=0
	*!*检测加密狗
	TRY
		Local cDevicePath
		cDevicePath=Space(260)
		Local nFindPortResult
		nFindPortResult=FindPort_2(0,19800910,-289008035,@cDevicePath)
		If nFindPortResult<>0
			EXIT
		ENDIF
		LOCAL cRHKey,cRLKey
		cRHKey="8D346A81"
		cRLKey="6C2863CF"
		*!*检测产品密钥
		LOCAL cUKeyPCode
		cPCode=SPACE(200)
		IF YReadString(@cPCode,1,200,cRHKey,cRLKey,cDevicePath)<>0
			EXIT
		ENDIF
		cPCode=ALLTRIM(STRTRAN(cPCode,CHR(0),""))
		IF !INLIST(ALLTRIM(LOWER(cPCode)),ALLTRIM(LOWER(GetPCode())),ALLTRIM(LOWER(_screen.cWiseMisPCode)))
			EXIT
		ENDIF
		*!*读取UKey当前日期
		LOCAL cCurrentDate,dCurrentDate
		cCurrentDate=SPACE(10)
		=YReadString(@cCurrentDate,361,10,cRHKey,cRLKey,cDevicePath)
		cCurrentDate=ALLTRIM(STRTRAN(cCurrentDate,CHR(0),""))
		*!*写入UKey当前日期
		LOCAL cWHKey,cWLKey
		cWHKey="A0BD510E"
		cWLKey="43A18A9D"
		IF EMPTY(cCurrentDate)
			cCurrentDate=DTOS(DATE())
			IF YWriteString(cCurrentDate,361,cWHKey,cWLKey,cDevicePath)<>0
				EXIT
			ENDIF
		ELSE
			IF cCurrentDate<DTOS(DATE())
				cCurrentDate=DTOS(DATE())
				IF YWriteString(cCurrentDate,361,cWHKey,cWLKey,cDevicePath)<>0
					EXIT
				ENDIF
			ENDIF
		ENDIF
		dCurrentDate=CTOD(SUBSTR(cCurrentDate,1,4)+"-"+SUBSTR(cCurrentDate,5,2)+"-"+SUBSTR(cCurrentDate,7,2))
		*!*检测失效日期
		LOCAL cUKeyExpireDate
		cUKeyExpireDate=SPACE(10)
		IF YReadString(@cUKeyExpireDate,251,10,cRHKey,cRLKey,cDevicePath)<>0
			EXIT
		ENDIF
		cUKeyExpireDate=ALLTRIM(STRTRAN(cUKeyExpireDate,CHR(0),""))
		IF EMPTY(cUKeyExpireDate)
			*!*检测有效期限
			LOCAL cUKeyValidMonths
			cUKeyValidMonths=SPACE(10)
			IF YReadString(@cUKeyValidMonths,201,10,cRHKey,cRLKey,cDevicePath)<>0
				EXIT
			ENDIF
			cUKeyValidMonths=ALLTRIM(STRTRAN(cUKeyValidMonths,CHR(0),""))
			IF !ISDIGIT(cUKeyValidMonths)
				EXIT
			ENDIF
			LOCAL nUKeyValidMonths
			nUKeyValidMonths=VAL(cUKeyValidMonths)
			*!*激活加密狗
			IF MessageBox1(STRCONV("B4CBBCD3C3DCB9B7C9D0CEB4BCA4BBEEA3ACD6BBD3D0BCA4BBEEBAF3B2C5C4DCD5FDB3A3CAB9D3C3A3A1",16)+CHR(13)+CHR(10)+STRCONV("B4CBBCD3C3DCB9B7B5C4D3D0D0A7CAB9D3C3C6DACFDECEAA",16)+TRANSFORM(nUKeyValidMonths)+STRCONV("B8F6D4C2A1A3",16)+REPLICATE(CHR(13)+CHR(10),2)+STRCONV("CAC7B7F1CFD6D4DABCA4BBEEB4CBBCD3C3DCB9B7A3BF",16),1+32,STRCONV("BCA4BBEEBCD3C3DCB9B7",16))<>1
				EXIT
			ENDIF

			cUKeyExpireDate=DTOS(GOMONTH(dCurrentDate,nUKeyValidMonths))
			IF YWriteString(cUKeyExpireDate,251,cWHKey,cWLKey,cDevicePath)<>0
				MessageBox1(STRCONV("BCA4BBEEBCD3C3DCB9B7CAA7B0DCA3A1",16),0+64,STRCONV("BCA4BBEEBCD3C3DCB9B7",16))
				EXIT
			ENDIF
		ENDIF

		*!*检测是否已经失效
		IF ALLTRIM(LOWER(cUKeyExpireDate))<ALLTRIM(LOWER(cCurrentDate))
			EXIT
		ENDIF
		*!*检测加密狗是否已经被禁用
		LOCAL cUKeyId
		cUKeyId=SPACE(20)
		IF YReadString(@cUKeyId,310,20,cRHKey,cRLKey,cDevicePath)<>0
			EXIT
		ENDIF
		cUKeyId=ALLTRIM(LOWER(STRTRAN(cUKeyId,CHR(0),"")))
		_screen.cUKeyId=cUKeyId
		LOCAL __cCheckFile
		__cCheckFile=ADDBS(ParsePath("{sys}"))+"wm_k2.dat"
		IF FILE(__cCheckFile)
			LOCAL __cDisableKeys,__cDisableKey
			__cDisableKeys=FILETOSTR(__cCheckFile)
			FOR __i=1 TO GETWORDCOUNT(__cDisableKeys,",")
				__cDisableKey=GETWORDNUM(__cDisableKeys,__i,",")
				IF ALLTRIM(LOWER(__cDisableKey))==ALLTRIM(LOWER(cUKeyId))
					nValidCode=BITSET(nValidCode,1)
					EXIT
				ENDIF
			ENDFOR
		ENDIF
		nValidCode=BITSET(nValidCode,0)

		*!*加密狗合法
		dExpireDate=DATE(VAL(LEFT(cUKeyExpireDate,4)),VAL(SUBSTR(cUKeyExpireDate,5,2)),VAL(SUBSTR(cUKeyExpireDate,7,2)))
	CATCH TO oErr
		WITH oErr as Exception
			IF _screen.IsDebug
				MessageBox1(.Message,0+64,"加密狗异常")
			ENDIF
		ENDWITH
	ENDTRY
	*!*加密狗验证成功
	*!*设置
	IF BITTEST(nValidCode,0) AND !BITTEST(nValidCode,1)
		RETURN nValidCode
	ENDIF
	*!*加密狗验证失败，尝试检测单机注册码
	LOCAL bIsA001
	bIsA001=.f.
	If Vartype(cRegisterCode)<>"C" Or Empty(cRegisterCode)
		Local cKeyFile
		cKeyFile=Addbs(GetSystemPath())+"WiseMisKey.ini"
		cRegisterCode=iniRead(Strconv(GetMCode(bIsA001),15),"","Register Code",cKeyFile)
		IF EMPTY(cRegisterCode)
			bIsA001=.t.
			cRegisterCode=iniRead(Strconv(GetMCode(bIsA001),15),"","Register Code",cKeyFile)
		ENDIF
	Endif
	If Empty(cRegisterCode)
		RETURN ValidSysRegister(cRegisterCode,@dExpireDate,@nClientRegType,@nClientCount)
	ENDIF

	LOCAL cRegisterCode1
	cRegisterCode1=cRegisterCode
	Local cN,cD1
	cN="14A11FCF1093A8DBB6191DA24FB63A52B741589778AD96BB5A565CA367DF911922631DE3C51EB0C417F11E4AA97118AE27431E05C8040C78D9A27CE3E7DE1331"
	cD1="12192966E80C23605E69BA6DE3B0E38A1DEBDE65452245D328760BDFF0095BAA18449511AC0DA01D49E9753CE3D7756D838BF41F7AC7994D2D2B4BB3546184E1"
	cRegisterCode=RSACalc(cN,cD1,cRegisterCode)
	cRegisterCode=Strconv(cRegisterCode,16)
	Local cMCode,cDate,cClientCount
	cMCode=Getwordnum(cRegisterCode,1,":")
	cPCode=Getwordnum(cRegisterCode,2,":")
	cDate=Getwordnum(cRegisterCode,3,":")
	cClientCount=Getwordnum(cRegisterCode,4,":")
	If Empty(cMCode) Or Empty(cPCode) Or Empty(cDate) OR EMPTY(cClientCount)
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	Endif
	*!*验证MCode和PCode
	Local cResult,cP1,cP2,cP3,cP4,cP5,cP6,cP7,cP8,cM1,cM2,cM3,cM4,cM5,cM6,cM7,cM8
	cP1=Substr(cPCode,1,1)
	cP2=Substr(cPCode,2,1)
	cP3=Substr(cPCode,3,1)
	cP4=Substr(cPCode,4,1)
	cP5=Substr(cPCode,5,1)
	cP6=Substr(cPCode,6,1)
	cP7=Substr(cPCode,7,1)
	cP8=Substr(cPCode,8,1)
	cM1=Substr(cMCode,1,1)
	cM2=Substr(cMCode,2,1)
	cM3=Substr(cMCode,3,1)
	cM4=Substr(cMCode,4,1)
	cM5=Substr(cMCode,5,1)
	cM6=Substr(cMCode,6,1)
	cM7=Substr(cMCode,7,1)
	cM8=Substr(cMCode,8,1)
	cResult=cP1+cP5+cM7+cP4+cM2+cM6+cP8+cP3+"-"+cM8+cM5+cP7+cM3+cP2+cM4+cP6+cM1
	If cResult<>GetMCode(bIsA001)
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	Endif
	*!*验证过期日期
	If Len(cDate)<>8
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	Endif
	If !Between(Val(Substr(cDate,5,2)),1,12) Or !Between(Val(Substr(cDate,7,2)),1,31) Or !Between(Val(Substr(cDate,1,4)),2011,9999)
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	Endif
	dExpireDate=Date(Val(Substr(cDate,1,4)),Val(Substr(cDate,5,2)),Val(Substr(cDate,7,2)))
	Local dTestDate
	*保留现场
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*继续
	dTestDate=Cast(Nvl(GetValue("select getdate()"),Date()) As D)
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*继续
	If dTestDate>dExpireDate
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	ENDIF
	*清除加密狗禁用标志
	nValidCode=BITCLEAR(nValidCode,1)
	*!*检测注册码是否在禁用名单之中
	LOCAL __cCheckFile
	__cCheckFile=ADDBS(ParsePath("{sys}"))+"wm_k1.dat"
	IF FILE(__cCheckFile)
		LOCAL __cDisableKeys,__cDisableKey
		__cDisableKeys=FILETOSTR(__cCheckFile)
		FOR __i=1 TO GETWORDCOUNT(__cDisableKeys,",")
			__cDisableKey=GETWORDNUM(__cDisableKeys,__i,",")
			IF ALLTRIM(LOWER(__cDisableKey))==ALLTRIM(LOWER(MD5String(cRegisterCode1)))
				nValidCode=BITSET(nValidCode,1)
				EXIT
			ENDIF
		ENDFOR
	ENDIF

	nValidCode=BITSET(nValidCode,0)
	IF !BITTEST(nValidCode,0) OR BITTEST(nValidCode,1)
		RETURN ValidSysRegister(cRegisterCode1,@dExpireDate,@nClientRegType,@nClientCount)
	ENDIF

	*!*最终结果
	RETURN nValidCode
ENDPROC

PROCEDURE ValidSysRegister
	Lparameters cRegisterCode,dExpireDate As Date,nClientRegType as Integer,nClientCount as Integer
	dExpireDate=DATE()
	nClientRegType=1
	nClientCount=0
	IF VARTYPE(cRegisterCode)<>"C" OR EMPTY(cRegisterCode)
		WITH _screen.oSettingObject as WiseMisSettingObject
			cRegisterCode=.GetSystemValue("WiseMis_RegisterCode")
		ENDWITH
	ENDIF
	IF EMPTY(cRegisterCode)
		RETURN 0
	ENDIF

	LOCAL nValidCode
	nValidCode=0

	LOCAL cRegisterCode1
	cRegisterCode1=cRegisterCode
	Local cN,cD1
	cN="14A11FCF1093A8DBB6191DA24FB63A52B741589778AD96BB5A565CA367DF911922631DE3C51EB0C417F11E4AA97118AE27431E05C8040C78D9A27CE3E7DE1331"
	cD1="12192966E80C23605E69BA6DE3B0E38A1DEBDE65452245D328760BDFF0095BAA18449511AC0DA01D49E9753CE3D7756D838BF41F7AC7994D2D2B4BB3546184E1"
	cRegisterCode=RSACalc(cN,cD1,cRegisterCode)
	cRegisterCode=Strconv(cRegisterCode,16)
	Local cMCode,cDate,cClientCount
	cMCode=Getwordnum(cRegisterCode,1,":")
	cPCode=Getwordnum(cRegisterCode,2,":")
	cDate=Getwordnum(cRegisterCode,3,":")
	cClientCount=Getwordnum(cRegisterCode,4,":")
	nClientCount=VAL(cClientCount)
	If Empty(cMCode) Or Empty(cPCode) Or Empty(cDate) OR EMPTY(cClientCount)
		RETURN 0
	Endif
	*!*验证MCode和PCode
	Local cResult,cP1,cP2,cP3,cP4,cP5,cP6,cP7,cP8,cM1,cM2,cM3,cM4,cM5,cM6,cM7,cM8
	cP1=Substr(cPCode,1,1)
	cP2=Substr(cPCode,2,1)
	cP3=Substr(cPCode,3,1)
	cP4=Substr(cPCode,4,1)
	cP5=Substr(cPCode,5,1)
	cP6=Substr(cPCode,6,1)
	cP7=Substr(cPCode,7,1)
	cP8=Substr(cPCode,8,1)
	cM1=Substr(cMCode,1,1)
	cM2=Substr(cMCode,2,1)
	cM3=Substr(cMCode,3,1)
	cM4=Substr(cMCode,4,1)
	cM5=Substr(cMCode,5,1)
	cM6=Substr(cMCode,6,1)
	cM7=Substr(cMCode,7,1)
	cM8=Substr(cMCode,8,1)
	cResult=cP1+cP5+cM7+cP4+cM2+cM6+cP8+cP3+"-"+cM8+cM5+cP7+cM3+cP2+cM4+cP6+cM1
	If cResult<>GetSysMCode()
		RETURN 0
	Endif
	*!*验证过期日期
	If Len(cDate)<>8
		RETURN 0
	Endif
	If !Between(Val(Substr(cDate,5,2)),1,12) Or !Between(Val(Substr(cDate,7,2)),1,31) Or !Between(Val(Substr(cDate,1,4)),2011,9999)
		RETURN 0
	Endif
	dExpireDate=Date(Val(Substr(cDate,1,4)),Val(Substr(cDate,5,2)),Val(Substr(cDate,7,2)))
	Local dTestDate
	*保留现场
	LOCAL __cPreCursor
	__cPreCursor=ALIAS()
	*继续
	dTestDate=Cast(Nvl(GetValue("select getdate()"),Date()) As D)
	*恢复现场
	IF SELECT(__cPreCursor)>0
		SELECT (__cPreCursor)
	ENDIF
	*继续
	If dTestDate>dExpireDate
		RETURN 0
	ENDIF
	*清除加密狗禁用标志
	nValidCode=BITCLEAR(nValidCode,1)
	*!*检测注册码是否在禁用名单之中
	LOCAL __cCheckFile
	__cCheckFile=ADDBS(ParsePath("{sys}"))+"wm_k1.dat"
	IF FILE(__cCheckFile)
		LOCAL __cDisableKeys,__cDisableKey
		__cDisableKeys=FILETOSTR(__cCheckFile)
		FOR __i=1 TO GETWORDCOUNT(__cDisableKeys,",")
			__cDisableKey=GETWORDNUM(__cDisableKeys,__i,",")
			IF ALLTRIM(LOWER(__cDisableKey))==ALLTRIM(LOWER(MD5String(cRegisterCode1)))
				nValidCode=BITSET(nValidCode,1)
				EXIT
			ENDIF
		ENDFOR
	ENDIF

	nValidCode=BITSET(nValidCode,0)
	IF !BITTEST(nValidCode,0) OR BITTEST(nValidCode,1)
		RETURN 0
	ENDIF

	*!*最终结果
	RETURN nValidCode
ENDPROC

*!*查询系统机器码
Procedure GetSysMCode

	Local cCPUId
	cCPUId=GetCpuId()
	Local cDiskId
	cDiskId=GetDiskSerial()

	Local cMCode
	cMCode=GetValue("select sid from master..syslogins where name='WiseMisAdmin'")
	cMCode=Encrypt(cMCode,"WiseMis")
	cMCode=CRC32String(cMCode)

	Local cPCode
	cPCode=GetPCode()

	If Empty(Nvl(cPCode,""))
		Return Strconv("C8EDBCFED2D1B1BBC6C6BBB5A3ACB2BBC4DCD7A2B2E1",16)
	Endif
	cPCode=CRC32String(cPCode)

	Local cResult,cP1,cP2,cP3,cP4,cP5,cP6,cP7,cP8,cM1,cM2,cM3,cM4,cM5,cM6,cM7,cM8
	cP1=Substr(cPCode,1,1)
	cP2=Substr(cPCode,2,1)
	cP3=Substr(cPCode,3,1)
	cP4=Substr(cPCode,4,1)
	cP5=Substr(cPCode,5,1)
	cP6=Substr(cPCode,6,1)
	cP7=Substr(cPCode,7,1)
	cP8=Substr(cPCode,8,1)
	cM1=Substr(cMCode,1,1)
	cM2=Substr(cMCode,2,1)
	cM3=Substr(cMCode,3,1)
	cM4=Substr(cMCode,4,1)
	cM5=Substr(cMCode,5,1)
	cM6=Substr(cMCode,6,1)
	cM7=Substr(cMCode,7,1)
	cM8=Substr(cMCode,8,1)

	cResult=cP1+cP5+cM7+cP4+cM2+cM6+cP8+cP3+"-"+cM8+cM5+cP7+cM3+cP2+cM4+cP6+cM1
	Return cResult
ENDPROC

*!*查询机器码
Procedure GetMCode
	LPARAMETERS bIsA001 as Boolean
	IF VARTYPE(bIsA001)<>"L"
		bIsA001=.f.
	ENDIF

	Local cCPUId
	cCPUId=GetCpuId()
	Local cDiskId
	cDiskId=GetDiskSerial()

	Local cMCode
	cMCode="<C>"+cCPUId+"</C><D>"+cDiskId+"</D>"
	cMCode=Encrypt(cMCode,"WiseMis")
	cMCode=CRC32String(cMCode)

	Local cPCode
	IF bIsA001
		cPCode="8D6030B2-0F15-43C0-9459-FBB61D4D0391"
	ELSE
		cPCode=GetPCode()
	ENDIF

	If Empty(Nvl(cPCode,""))
		Return Strconv("C8EDBCFED2D1B1BBC6C6BBB5A3ACB2BBC4DCD7A2B2E1",16)
	Endif
	cPCode=CRC32String(cPCode)

	Local cResult,cP1,cP2,cP3,cP4,cP5,cP6,cP7,cP8,cM1,cM2,cM3,cM4,cM5,cM6,cM7,cM8
	cP1=Substr(cPCode,1,1)
	cP2=Substr(cPCode,2,1)
	cP3=Substr(cPCode,3,1)
	cP4=Substr(cPCode,4,1)
	cP5=Substr(cPCode,5,1)
	cP6=Substr(cPCode,6,1)
	cP7=Substr(cPCode,7,1)
	cP8=Substr(cPCode,8,1)
	cM1=Substr(cMCode,1,1)
	cM2=Substr(cMCode,2,1)
	cM3=Substr(cMCode,3,1)
	cM4=Substr(cMCode,4,1)
	cM5=Substr(cMCode,5,1)
	cM6=Substr(cMCode,6,1)
	cM7=Substr(cMCode,7,1)
	cM8=Substr(cMCode,8,1)

	cResult=cP1+cP5+cM7+cP4+cM2+cM6+cP8+cP3+"-"+cM8+cM5+cP7+cM3+cP2+cM4+cP6+cM1
	Return cResult
Endproc


*!*设置状态栏信息
Procedure SetStatusText
	Lparameters cStatusText As String
	If Vartype(_Screen.oStatusBar)<>"O"
		Return
	ENDIF
	IF VARTYPE(cStatusText)<>"C" OR EMPTY(cStatusText)
		cStatusText="准备就绪"
	ENDIF
	cStatusText=ToEnglish(cStatusText)
	With _Screen.oStatusBar As Label
		.Caption=cStatusText
	Endwith
ENDPROC


*!*刷新用户提醒对象
Procedure RefreshUserNotifys
	IF VARTYPE(_Screen.oUserNotifyObjects)<>"O"
		RETURN
	ENDIF
	With _Screen.oUserNotifyObjects As Collection
		.Remove(-1)
	ENDWITH
	LOCAL cPreCursor
	cPreCursor=ALIAS()
	Select 0
	Local cSQL,cTempCursor
	IF _screen.bWiseMisLoginMode
		cSQL="select * from WiseMis_UserNotify where (UserID='"+_screen.cUserName+"' or dbo.WiseMis_IsMember(UserID,'"+_screen.cUserName+"',getdate())=1) and Visible=1 order by OrderId,id"
	ELSE
		cSQL="select * from WiseMis_UserNotify where (UserID='"+_screen.cUserName+"' or Is_Member(UserID)=1) and Visible=1 order by OrderId,id"
	ENDIF
	cTempCursor=Sys(2015)
	If !SelectData(cSQL,cTempCursor)
		MessageBox1("读取用户提醒数据失败！",0+64,"系统提示")
		Return
	Endif
	Select (cTempCursor)
	Scan
		Local oUserNotifyObject As UserNotifyObject
		oUserNotifyObject=Createobject("UserNotifyObject")
		oUserNotifyObject.LoadFromCursor(cTempCursor)
		oUserNotifyObject.DoInit()
	Endscan
	=CloseAlias(cTempCursor)
	IF SELECT(cPreCursor)>0
		SELECT (cPreCursor)
	ENDIF
Endproc

*!*刷新提醒数据
Procedure RefreshUserNotifyData
	Local nNotifyDataCount
	nNotifyDataCount=0
	For Each oUserNotifyObject As UserNotifyObject In _Screen.oUserNotifyObjects
		If !oUserNotifyObject.bRunning
			Loop
		Endif
		oUserNotifyObject.RefreshData
		If Select(oUserNotifyObject.cNotifyCursor)>0
			nNotifyDataCount = nNotifyDataCount + Reccount(oUserNotifyObject.cNotifyCursor)
		Endif
	Endfor
	Return nNotifyDataCount
Endproc

*!*注册窗体到主界面
Procedure RegisterForm
	Lparameters oForm As Form,cIconImage as String
	With _Screen.oPageFrameManager As PageFrameManager
		.AddPage(oForm,cIconImage)
	Endwith
Endproc

*!*从主主界面注销窗体
Procedure UnRegisterForm
	Lparameters oForm As Form
	With _Screen.oPageFrameManager As PageFrameManager
		.RemovePage(oForm)
	Endwith
Endproc


Procedure OnShutdown
	IF BITTEST(_screen.nRegisterResult,0) AND !BITTEST(_screen.nRegisterResult,1) AND _screen.nClientRegType=1
		=Execute("delete from WiseMis_Client where CAST(SessionID as varchar(50))='"+cSessionID+"'")
	ENDIF

	With _Screen.oSettingObject As WiseMisSettingObject
		.Save()
	ENDWITH
	
	

	***************************************
	*!*检查是否更新了升级程序
	Local cUpdateExeFile,cUpdateExeFile1
	cUpdateExeFile=Addbs(ParsePath("{app}"))+"Update\WiseMisNewUpdate.exe"
	cUpdateExeFile1=Addbs(ParsePath("{app}"))+"WiseMisNewUpdate.exe"
	IF FILE(cUpdateExeFile)
		LOCAL bUpdateMainExe	&&是否更新升级程序
		bUpdateMainExe=.t.
		IF FILE(cUpdateExeFile1)
			If MD5File(cUpdateExeFile)==MD5File(cUpdateExeFile1)
				bUpdateMainExe=.f.
			ENDIF 
		ENDIF 
		
		IF bUpdateMainExe
			=KillProcessByName("WiseMisNewUpdate.exe")
			=INKEY(0.1,"H")
			*!*复制文件
			=CopyFiles(cUpdateExeFile,cUpdateExeFile1)
		ENDIF 
	ENDIF
	
	*!*检查更新

	IF FILE(cUpdateExeFile1) AND !bDebugMode
		*!*正常更新
		=ShellExecute(0,"open",cUpdateExeFile1,_screen.cServer+" "+_screen.cDatabase+" "+_screen.cWiseMisPCode,SYS(5)+SYS(2003),0)
	ENDIF

	_Screen.oSettingObject=Null
	_Screen.oLoginObjects=Null
	_Screen.oUserNotifyObjects=Null
	_Screen.oStatusBar=Null
	
		*!*清除外接程序
	LOCAL cCodeFile1,cCodeFile2
	cCodeFile1=ParsePath("{app}\plugin"+cPluginFile+".prg")
	cCodeFile2=ParsePath("{app}\plugin"+cPluginFile+".fxp")
	SET PROCEDURE TO
	IF FILE(cCodeFile1)
		ERASE (cCodeFile1)
	ENDIF 
	IF FILE(cCodeFile2)
		ERASE (cCodeFile2)
	ENDIF 
	
	Clear Events

	IF !bDebugMode
		=ExitProcess(0)
		SET LIBRARY TO
	ENDIF
	


Endproc

*!*声明公共用的DLL
Procedure Common_Declare_Dlls
	Declare Integer SHGetFileInfo In shell32;
		STRING pszPath,;
		LONG dwFileAttributes,;
		STRING @psfi,;
		LONG cbFileInfo,;
		LONG uFlags
	Declare Integer GdipCreateBitmapFromHICON In GDIPlus;
		INTEGER hicon,;
		INTEGER @hbitmap
	Declare Integer GdipGetImageHeight In GDIPlus;
		INTEGER   img,;
		INTEGER @ imgheight
	Declare Integer GdipGetImageWidth In GDIPlus;
		INTEGER   img,;
		INTEGER @ imgwidth
	Declare Long GdipSaveImageToFile In GDIPlus Long nativeImage, String cFile, ;
		STRING EncoderClsID,;
		STRING EncoderParameters
	Declare Long GdipDisposeImage In GDIPlus Long nativeImage
	Declare Long GdipBitmapGetPixel In GDIPlus Long hBitmap,Long x,Long Y,Long @ argb
	Declare Long GdipBitmapSetPixel In GDIPlus Long hBitmap,Long x,Long Y,Long argb

Endproc

**定义函数
Function SaveIco2Jpg(cFilename As String,lcOutputFile As String,utype As Long)
	**cFilename 参数：文件类型，如.xls .mdb 等等
	**lcOutputFile参数：保存到本地的文件名称，如 dbf.jpg
	**utype参数：图标类型，0为大图标，1为小图标
	*******************************************
	*算法制作:行者孙(QQ:310727570)
	*******************************************
	*VFP应用程式算法群:12787940
	*******************************************
	Local cBuffer,nResult,hIcon,hbitmap,argb,imgwidth,imgheigh,ClsID_JPG
	ClsID_JPG=0h01F47C55041AD3119A730000F81EF32E
	Store 0 To hbitmap,argb,imgwidth,imgheight
	cBuffer=Replicate(Chr(0),1024)
	nResult=SHGetFileInfo(cFilename,utype,@cBuffer,1024,272)
	hIcon=CToBin(Substr(cBuffer,1,4),'4rs')
	GdipCreateBitmapFromHICON(hIcon,@hbitmap)
	GdipGetImageHeight(hbitmap,@imgheight)
	GdipGetImageWidth(hbitmap,@imgwidth)
	For i=0 To imgwidth-1
		For ii=0 To imgheight-1
			GdipBitmapGetPixel(hbitmap,i,ii,@argb)
			If argb=0
				GdipBitmapSetPixel(hbitmap,i,ii,0xFFFFFF)
			Endi
		Endf
	Endf
	GdipSaveImageToFile(hbitmap,Strconv(lcOutputFile+Chr(0),5),ClsID_JPG, Null)
	GdipDisposeImage(hbitmap)
Endfunc





*!*截屏
Procedure SnapScreen
	Local __cTempFileStream
	__cTempFileStream=""
	Local cTempImageFile,cTempPngFile
	cTempImageFile=Addbs(Getenv("TEMP"))+Sys(2015)+".bmp"
	cTempPngFile=Addbs(Getenv("TEMP"))+Sys(2015)+".png"
	If RectToBmp(0,0,Sysmetric(1),Sysmetric(2),cTempImageFile)
		If ImageConver(cTempImageFile,cTempPngFile,6)
			__cTempFileStream=Filetostr(cTempPngFile)
			Erase (cTempPngFile)
		Endif
		Erase (cTempImageFile)
	Endif
	Return __cTempFileStream
Endproc










*!*调用外部程序运行文件
Procedure RunFile
	Lparameters cFileName
	If Vartype(cFileName)<>"C" Or Empty(cFileName)
		Return
	Endif
	If !File(cFileName) AND !DIRECTORY(cFileName)
		Return
	Endif
	=ShellExecute(0,"open",cFileName,"","",5)
ENDPROC

PROCEDURE TextToStream
	Lparameters cTextData,cOutputStream,cOutputFileName
	IF VARTYPE(cTextData)<>"C" OR EMPTY(cTextData)
		cOutputStream=""
		cOutputFileName=""
		RETURN
	ENDIF
	Local cNameData, cStreamData
	Store "" To cNameData, cStreamData
	Local __cTempBlobData, __nTempExtPos
	__cTempBlobData = ""
	LOCAL nPos1
	nPos1=AT("]",cTextData)
	IF nPos1>2
		cNameData=SUBSTR(cTextData,2,nPos1-2)
		IF GETWORDCOUNT(cNameData,":")=1
			cOutputFileName=SYS(2015)+"."+cNameData
		ELSE
			cOutputFileName=Strtran(cNameData,":",".")
		ENDIF
		cOutputStream=STRCONV(SUBSTR(cTextData,nPos1+1),14)
	ELSE
		cOutputFileName=""
		cOutputStream=""
	ENDIF
ENDPROC

PROCEDURE TextToFile
	Lparameter cTextData As String, cSaveFileName As String
	If Vartype(cSaveFileName)<>"C"
		cSaveFileName=""
	Endif

	Local cOutputStream,cOutputFileName
	Store "" To cOutputStream,cOutputFileName
	=TextToStream(cTextData,@cOutputStream,@cOutputFileName)
	If Empty(cSaveFileName)
		cSaveFileName=Addbs(_Screen.cFilesPath)+cOutputFileName
	ENDIF
	IF !EMPTY(cOutputStream)
		= Strtofile(cOutputStream,cSaveFileName)
	ENDIF
ENDPROC

Procedure ImageToStream
	Lparameters cImageData,cOutputStream,cOutputFileName
	IF ISNULL(cImageData) OR EMPTY(cImageData)
		cOutputStream=""
		cOutputFileName=""
		RETURN
	ENDIF
	Local cNameData, cStreamData
	Store "" To cNameData, cStreamData
	Local __cTempBlobData, __nTempExtPos
	__cTempBlobData = ""
	If Vartype(cImageData) = "Q"
		__cTempBlobData = cImageData
	Else
		Do While Len(cImageData) > 0
			__cTempBlobData = __cTempBlobData + Strconv(Left(cImageData,512000),16)
			cImageData = Substr(cImageData,512001)
		Enddo
	Endif
	__nTempExtPos = At("&" + "e" + "x" + "t" + ";",__cTempBlobData)
	cNameData = Left(__cTempBlobData,__nTempExtPos - 1)
	cStreamData = Substr(__cTempBlobData,__nTempExtPos + 5)
	cNameData = Cast(cNameData As M)

	cOutputStream=cStreamData
	cOutputFileName=Strtran(cNameData,":",".")
Endproc

Procedure ImageToFile
	Lparameter cImageData As String, cSaveFileName As String
	If Vartype(cSaveFileName)<>"C"
		cSaveFileName=""
	Endif

	Local cOutputStream,cOutputFileName
	Store "" To cOutputStream,cOutputFileName
	=ImageToStream(cImageData,@cOutputStream,@cOutputFileName)
	If Empty(cSaveFileName)
		cSaveFileName=Addbs(_Screen.cFilesPath)+cOutputFileName
	ENDIF
	IF !EMPTY(cOutputStream)
		= Strtofile(cOutputStream,cSaveFileName)
	ENDIF
Endproc

Procedure InputPassword
	Lparameters cTitle,cText
	If Vartype(cTitle)<>"C" Or Empty(cTitle)
		cTitle="密码输入框"
	Endif
	If Vartype(cText)<>"C" Or Empty(cText)
		cText="输入密码"
	Endif
	Local cReturnPass
	cReturnPass=""
	Do Form frm_tool_password With cTitle,cText To cReturnPass
	Return cReturnPass
Endproc

Procedure GetInternetTime
	Local today
	Try
		Local oXmlHttpObject As MSXML2.XMLHTTP
		oXmlHttpObject=Createobject("MSXML2.XMLHTTP")
		oXmlHttpObject.Open("get","http://www.time.ac.cn/timeflash.asp?user=flash",.F.)
		oXmlHttpObject.Send()
		Local cReturnXml
		cReturnXml=oXmlHttpObject.responseText

		Local oReturnXml As MSXML2.DOMDocument
		oReturnXml=Createobject("MSXML2.DOMDocument")
		oReturnXml.LoadXML(cReturnXml)
		Local nYear,nMonth,nDay,nHour,nMinite,nSecond
		nYear=Val(oReturnXml.getElementsByTagName("year").Item(0).Text)
		nMonth=Val(oReturnXml.getElementsByTagName("month").Item(0).Text)
		nDay=Val(oReturnXml.getElementsByTagName("day").Item(0).Text)
		nHour=Val(oReturnXml.getElementsByTagName("hour").Item(0).Text)
		nMinite=Val(oReturnXml.getElementsByTagName("minite").Item(0).Text)
		nSecond=Val(oReturnXml.getElementsByTagName("second").Item(0).Text)
		today=Datetime(nYear,nMonth,nDay,nHour,nMinite,nSecond)
	Catch To oErr
		today=Datetime()
	Endtry
	Return today
Endproc

*!*网速表述
PROCEDURE ToNetSpeedString
	LPARAMETERS nSpeedByBytePerSecond as Integer
	IF VARTYPE(nSpeedByBytePerSecond)<>"N"
		nSpeedByBytePerSecond=0
	ENDIF
	nSpeedByBytePerSecond=INT(nSpeedByBytePerSecond)
	LOCAL cSpeedText
	IF nSpeedByBytePerSecond<1024
		cSpeedText=TRANSFORM(nSpeedByBytePerSecond)+"b/s"
	ELSE
		IF nSpeedByBytePerSecond<1024*1024
			cSpeedText=ALLTRIM(STR(nSpeedByBytePerSecond/1024,11,1))+"kb/s"
		ELSE
			cSpeedText=ALLTRIM(STR(nSpeedByBytePerSecond/1024/1024,11,1))+"mb/s"
		ENDIF
	ENDIF
	RETURN cSpeedText
ENDPROC
*!* 时间表述
Procedure ToTimeString
	Lparameters nSeconds As Integer
	IF VARTYPE(nSeconds)<>"N"
		nSeconds=0
	ENDIF
	nSeconds=INT(nSeconds)

	Local cTimeString
	cTimeString=""

	Local nHour,nMinute,nSec
	nHour=Int(nSeconds/60/60)
	nMinute=Int((nSeconds-nHour*60*60)/60)
	nSec=nSeconds-nHour*60*60-nMinute*60
	If nHour>0
		cTimeString = cTimeString + Transform(nHour)+"小时"
	Endif
	If nMinute>0
		cTimeString = cTimeString + Transform(nMinute)+"分"
	Endif
	If nSec>0
		cTimeString = cTimeString + Transform(nSec)+"秒"
	Endif

	Return cTimeString
Endproc


*!*取XmlHTTP返回信息
Procedure GetHttpServiceString
	Lparameters m.cUrl,m.cInputStr
	If Vartype(m.cInputStr)<>"C"
		m.cInputStr=""
	Endif
*!*		Local cReturnString,oErr As Exception
*!*		Try
*!*			Local oXml As MSXML2.ServerXMLHTTP
*!*			oXml=Createobject("MSXML2.ServerXMLHTTP")
*!*			oXml.Open("Post",cUrl,.F.)
*!*			oXml.setRequestHeader("content-length",Len(cInputStr))
*!*			oXml.setRequestHeader("CONTENT-TYPE","application/x-www-form-urlencoded")
*!*			oXml.setTimeouts(60*1000,60*1000,5*60*1000,30*60*1000)
*!*			oXml.setRequestHeader("User-Agent","Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)")
*!*			oXml.Send(cInputStr)
*!*			cReturnString=oXml.responseText
*!*		Catch To oErr
*!*			cReturnString="ERROR:"+Strconv(oErr.Message,15)
*!*		ENDTRY
	LOCAL cReturnString
	cReturnString=HttpPostData(m.cUrl,m.cInputStr)
	Return m.cReturnString
ENDPROC

