*!*以参数的方式启动，传入参数为系统连接文件（*.wms）
*!*系统连接文件
LPARAMETERS cSystemLinkFile as String
*just for a test
SET EXACT ON
=SQLSETPROP(0,"DispLogin",3)
=SQLSETPROP(0,"DispWarnings",.f.)
SET NULLDISPLAY TO ""

IF VARTYPE(cSystemLinkFile)<>"C"
	cSystemLinkFile=""
ENDIF

LOCAL cDefaultPath
cDefaultPath=SYS(5)+SYS(2003)

SET DEFAULT TO (cDefaultPath)
_screen.AddProperty("cRootPath",cDefaultPath)&&,1,"根目录")


SET PATH TO ClassLibs,Forms,Images,Images\System,Programs,Libs,Files,User,Other,Addons
Set Procedure To ExcelBase,CommonClass,AppGrid,UI,DataPackage,SQL,App,ERROR,UserRights,FoxBarCodeQR,FoxBarCode,gpImage2,HttpDownFile,RefreshSystem,TransFormControl,Language,foxjson,foxjson_parse
Set Classlib To _base.vcx,WiseMisObject,WiseMisForms,WiseMisFields,WiseMisPages,WiseMisNewControls,DatePicker
SET LIBRARY TO
SET LIBRARY TO MyFll.fll
SET LIBRARY TO foxer.fll ADDITIVE
SET LIBRARY TO foxjson.dll ADDITIVE 
*!*注册必须的控件
=Register_Dlls()


*!*会话ID
PUBLIC cSessionID,cPluginFile
cSessionID=GetGUID(3)
cPluginFile=SYS(2015)
*!*系统管理员邮箱地址
PUBLIC cAdminEmailAddress
cAdminEmailAddress=""

*!*WiseMis平台3.0主程序
Application.AutoYield=.t.

_Screen.AddProperty("isDebug",.f.)&&,1,"调试模式")
_Screen.AddProperty("cServer","")&&,1,"服务器")
_Screen.AddProperty("cUser","WiseMisAdmin")&&,1,"登陆账号")
_Screen.AddProperty("cPwd",GetWiseMisDefaultOperatorPassword())&&,1," 登陆密码")
_Screen.AddProperty("cDatabase","")&&,1,"数据库")
_Screen.AddProperty("cDatabase2","")&&,1,"数据库")
_Screen.AddProperty("bLoginSecure",.F.)&&,1,"信任连接")
_screen.AddProperty("cSystemLinkFile",cSystemLinkFile)		&&系统快捷方式
PUBLIC nSQLHandle		&&SQL连接句柄
nSQLHandle=0

_screen.AddProperty("cUpdateServerDatabase","WiseMisDB")	&&更新服务器地址
_screen.AddProperty("cUpdateServerUid","WiseMisAdmin")
_screen.AddProperty("cUpdateServerPwd","hlh***TXK0921")
*!*	LOCAL cUpdateServer
*!*	STORE "" TO cUpdateServer
*!*	=GetUpdateInfo(@cUpdateServer)
_screen.AddProperty("cUpdateServerName","")	&&更新服务器地址

*!*条形码公共对象
_screen.AddProperty("oBarCode",CREATEOBJECT("FoxBarCode"))		&&一维码
_screen.AddProperty("oBarCodeQR",CREATEOBJECT("FoxBarCodeQR"))		&&二维码

_screen.AddProperty("bFullScreenMode",.f.)	&&全屏模式
_screen.AddProperty("cSysMCode","")		&&系统机器码

_screen.AddProperty("bRuntimeMode",.f.)		&&实时模式

*登陆账号及密码（新）
_screen.AddProperty("cUserName","")		&&用户名
_screen.AddProperty("cUserPassword","")	&&用户密码
_screen.AddProperty("cSystemDbVersion","2.001.147")	&&最低的WiseMis平台数据库版本
_screen.AddProperty("cDisplayName","")	&&显示名称
_screen.AddProperty("bWiseMisLoginMode",.t.)		&&登录模式：.t. WiseMis用户体系，.f. SQL用户体系

_screen.AddProperty("System_Main",null)		&&主界面
_screen.AddProperty("LockSystem",.f.)

_screen.AddProperty("cLastSQL","")	&&最近一条SQL语句
_screen.AddProperty("cLastScript","")	&&最近一条脚本语句
_screen.AddProperty("cWiseMisPCode","C49BD667-5CA8-4DC6-8246-434A602D6CF8")		&&WiseMis平台产品密钥
_screen.AddProperty("bIsLocked",.f.)		&&是否正在锁定系统
_screen.AddProperty("bDownloadFinish",.f.)	&&是否下载完成
_screen.AddProperty("bDownloadFailed",.f.)	&&是否下载失败
_screen.AddProperty("nDownloadReceivedSecond",0)	&&最近一次收到数据的秒数
_screen.AddProperty("nMainWndHandle",0)	&&主界面窗口句柄
_screen.AddProperty("nNavWndHandle",0)	&&导航窗口句柄
_screen.AddProperty("bShowError",.t.)		&&是否显示错误
_screen.AddProperty("bReportError",.f.)	&&是否报告错误
_Screen.AddProperty("cMsdeURL","http://121.12.164.74/WiseMis/support/SQL2005.zip")		&&MSDE地址文件
_Screen.AddProperty("cMsdeURL2","http://121.12.164.74/WiseMis/support/SQL2005.zip")		&&备用MSDE地址文件
_screen.AddProperty("cDotNetFX32Url","http://121.12.164.74/WiseMis/support/NetFx32.zip")	&&32位.net框架下载地址
_screen.AddProperty("cDotNetFX32Url2","http://121.12.164.74/WiseMis/support/NetFx32.zip")	&&备用32位.net框架下载地址
_screen.AddProperty("cDotNetFX64Url","http://121.12.164.74/WiseMis/support/NetFx64.zip")	&&64位.net框架下载地址
_screen.AddProperty("cDotNetFX64Url2","http://121.12.164.74/WiseMis/support/NetFx64.zip")	&&备用64位.net框架下载地址

_screen.AddProperty("nIsOnline",0)	&& 0未测试，1 在线，-1 不在线
_screen.AddProperty("bIsWiseMisAdministrator",.f.)	&&是否WiseMis系统管理员（通用）
_screen.AddProperty("cUKeyId","（无）")		&&加密狗编号
_screen.AddProperty("nRegisterResult",0)	&&注册结果
_screen.AddProperty("nClientRegType",0)		&&客户端注册模式：0 单机注册（加密狗或客户端注册码，不计入站点数），1 服务器注册（站点数控制）
_screen.AddProperty("nClientCount",0)	&&客户端同时在线数
_screen.AddProperty("bCheckClient",.f.)	&&检查客户端在线
_screen.AddProperty("bLoginOK",.f.)		&&检查是否已经登录
_screen.AddProperty("nLanguage",1)		&&系统语言，1=中文，2=英文，。。。其他待增加

_screen.AddProperty("cAlias_User",SYS(2015))
_screen.AddProperty("cAlias_UserRole",SYS(2015))
_screen.AddProperty("cAlias_AppType",SYS(2015))	
_screen.AddProperty("cAlias_AppIndex",SYS(2015))
_screen.AddProperty("cAlias_AppIndexes",SYS(2015))		
_screen.AddProperty("cAlias_AppDetail",SYS(2015))	
_screen.AddProperty("cAlias_AppRelation",SYS(2015))	
_screen.AddProperty("cAlias_AppWorkflow",SYS(2015))	
_screen.AddProperty("cAlias_AppFieldScript",SYS(2015))	
_screen.AddProperty("cAlias_AppReport",SYS(2015))	
_screen.AddProperty("cAlias_Query",SYS(2015))
_screen.AddProperty("cAlias_Menu",SYS(2015))
_screen.AddProperty("cAlias_Notify",SYS(2015))
_screen.AddProperty("cAlias_UserClick_App",SYS(2015))
_screen.AddProperty("cAlias_UserClick_AppField",SYS(2015))
_screen.AddProperty("cAlias_UserClick_Query",SYS(2015))
_screen.AddProperty("cAlias_UserClick_Menu",SYS(2015))
_screen.AddProperty("cAlias_AppIndexUserRights",SYS(2015))
_screen.AddProperty("cAlias_AppDetailUserRights",SYS(2015))
_screen.AddProperty("cAlias_AppWorkflowUserRights",SYS(2015))
_screen.AddProperty("cAlias_AppFlow",SYS(2015))
_screen.AddProperty("cAlias_QueryUserRights",SYS(2015))
_screen.AddProperty("cAlias_MenuUserRights",SYS(2015))
_screen.AddProperty("cAlias_Setting",SYS(2015))
_screen.AddProperty("cAlias_ExcelImportIndex",SYS(2015))
_screen.AddProperty("cAlias_ExcelImportDetail",SYS(2015))
_screen.AddProperty("cAlias_SearchSchame",SYS(2015))
_screen.AddProperty("cAlias_AppReport2",SYS(2015))
_screen.AddProperty("cAlias_ItemData",SYS(2015))
_screen.AddProperty("cAlias_BaseData",SYS(2015))
_screen.AddProperty("cAlias_CodeRule",SYS(2015))
_screen.AddProperty("cAlias_Language",SYS(2015))
_screen.AddProperty("cAlias_WorkflowImage",SYS(2015))
_screen.AddProperty("cAlias_FavoriteImage",SYS(2015))


_screen.AddProperty("oAppRights",CREATEOBJECT("Collection"))	&&应用方案权限
_screen.AddProperty("oAppFieldRights",CREATEOBJECT("Collection"))	&&应用方案字段权限
_screen.AddProperty("oAppRules",CREATEOBJECT("Collection"))		&&应用方案规则
_screen.AddProperty("oAppTaskRights",CREATEOBJECT("Collection"))	&&应用方案操作权限
_screen.AddProperty("oExcelModalObjects",CREATEOBJECT("Collection"))	&&Excel模版集合
_screen.AddProperty("oUserRoles",CREATEOBJECT("Collection"))	&&用户角色集合
_screen.AddProperty("oTreeNodeTexts",CREATEOBJECT("Collection"))	&&树节点长文本集合（用于快速检索树节点的长文本）
_screen.AddProperty("oItemData",CREATEOBJECT("Collection"))	&&辅助资料对象集合
_screen.AddProperty("oBaseData",CREATEOBJECT("Collection"))	&&基础数据对象集合
_screen.AddProperty("oCodeRule",CREATEOBJECT("Collection"))	&&编码规则对象集合


*!*检查文件关联是否正确
Declare INTEGER GetModuleFileName IN kernel32 INTEGER hModule,STRING @ lpFilename,INTEGER  nSize
lpFilename = SPACE(250)
lnLen = GetModuleFileName (0, @lpFilename, Len(lpFilename))

PUBLIC bDebugMode
bDebugMode=.f.


IF EMPTY(regRead("","Licenses\12B142A4-BD51-11d1-8C08-0000F8754DA1",2147483648))
	LOCAL cTempRegFile
	cTempRegFile=ADDBS(GETENV("TEMP"))+SYS(2015)+".reg"
	=STRTOFILE(FILETOSTR("Other\System.reg"),cTempRegFile)
	IF FILE(cTempRegFile)
		=ShellExecWait("regedit","/s "+cTempRegFile,0)
	ENDIF
ENDIF

LOCAL o as MSWinsockLib.Winsock,oErr as Exception
TRY
	o=CREATEOBJECT("MSWinsock.Winsock.1")
CATCH TO oErr
ENDTRY
IF VARTYPE(o)<>"O"
	=ShellExecWait("regsvr32","/s "+"mswinsck.ocx",0)
ENDIF


Set Safety Off
LOCAL cWiseMisPath
cWiseMisPath=GetWiseMisDatabasePath()
_screen.AddProperty("cUserPath",_screen.cRootPath)&&,1,"用户目录")
_screen.AddProperty("cFilesPath",ADDBS(_screen.cRootPath)+"Files")&&,1,"文件目录")
_screen.AddProperty("cUpdatePath",ADDBS(_screen.cRootPath)+"Update")&&,1,"更新目录")
_screen.AddProperty("cDatabasePath",ADDBS(_screen.cRootPath)+"Database")&&,1,"数据库目录")

IF !DIRECTORY(_screen.cFilesPath,1)
	MKDIR (_screen.cFilesPath)
ENDIF
IF !DIRECTORY(_screen.cUpdatePath,1)
	MKDIR (_screen.cUpdatePath)
ENDIF
IF !DIRECTORY(_screen.cDatabasePath,1)
	MKDIR (_screen.cDatabasePath)
ENDIF
_screen.AddProperty("cConfigFile",ADDBS(_screen.cUserPath)+"WiseMis.dbf")&&,1,"配置文件地址")
_Screen.AddProperty("cLoginFile",ADDBS(_screen.cUserPath)+"Login.dbf")&&,1,"配置文件地址")
_screen.AddProperty("cRegisterFile",Addbs(Getenv("SystemRoot")) + "system32\_1SL0MDQD6.dbf")&&,1,"注册文件地址")
_screen.AddProperty("cLoginXMLFile",ADDBS(_screen.cUserPath)+"Login.xml")
_screen.AddProperty("cSettingXMLFile",ADDBS(_screen.cUserPath)+"Setting.xml")


_screen.AddProperty("oLoginObjects",CREATEOBJECT("WiseMisLoginObjects"))	&&登录对象列表
_screen.AddProperty("oSettingObject",CREATEOBJECT("WiseMisSettingObject"))	&&系统配置对象
_screen.AddProperty("oPageFrameManager",null)	&&页框管理器
_screen.AddProperty("oUserNotifyObjects",CREATEOBJECT("Collection"))		&&提醒对象集合
_screen.AddProperty("oStatusBar",null)	&&系统状态栏
_screen.AddProperty("oAppTypeObjectCollection",CREATEOBJECT("Collection"))	&&应用类别集合
_screen.AddProperty("oUserObjectCollection",CREATEOBJECT("Collection"))		&&用户列表
_screen.AddProperty("oF7FilterExprCollection",CREATEOBJECT("Collection"))	&&F7过滤表达式集合

_screen.AddProperty("cWiseMisAppClassInApplication","")&&,1,"WiseMis应用方案类所在的APP")
_screen.AddProperty("cWiseMisAppClass","AppForm_New")&&,1,"WiseMis应用方案默认的类名")
_screen.AddProperty("cWiseMisAppClassLibrary","WiseMisForms")&&,1,"WiseMis应用方案默认的类库")
_screen.AddProperty("cWiseMisAppClass2","AppForm_Old")&&,1,"WiseMis应用方案默认的类名（主从模式）")
_screen.AddProperty("cWiseMisAppClassLibrary2","WiseMisForms")&&,1,"WiseMis应用方案默认的类库（主从模式）")

_Screen.AddProperty("isSysAdmin",.F.)&&,1,"是否系统管理员")
_screen.AddProperty("nUseMemoSize",255)&&,1,"备注字段大小，即当字段长度超过这个值时转为备注字段")
_screen.AddProperty("oAppObjects",CREATEOBJECT("Collection"))&&,1,"应用方案列表")

_screen.AddProperty("_MemberData",FILETOSTR("_screen.xml"))

WITH _screen.oSettingObject as WiseMisSettingObject
	.Load()
	IF !EMPTY(.GetValue("Language"))
		_screen.nLanguage=VAL(.GetValue("Language"))
	ENDIF 
ENDWITH 

_screen.AddProperty("cSystemName",ToEnglish("WiseMis平台"))		&&OEM名称
_Screen.AddProperty("cVersion",ToEnglish("调试模式"))&&,1,"版本号")


DO CASE
	CASE ALLTRIM(LOWER(JUSTFNAME(lpFilename)))=="vfp9.exe"
		_screen.IsDebug=.t.
		bDebugMode=.t.
	CASE ALLTRIM(LOWER(JUSTFNAME(lpFilename)))=="wisemis.exe"
		_screen.IsDebug=.f.
		LOCAL ARRAY arrFileInfo(1)
		=AGETFILEVERSION(arrFileInfo,lpFilename)
		_screen.cVersion=arrFileInfo[4]
	OTHERWISE
		IF FILE(Addbs(_Screen.cRootPath)+"WiseMis.exe")
			=ShellExecute(0,"open","WiseMis.exe",cSystemLinkFile,_Screen.cRootPath,5)
		ELSE
			MessageBox1(STRCONV("C8EDBCFED2D4D4E2B5BDC6C6BBB5A3ACC7EBD6D8D7B0CFB5CDB3A3A1",16),0+64,STRCONV("CFB5CDB3CCE1CABE",16))
		ENDIF
		=ExitProcess()
ENDCASE

DO Common_Declare_Dlls

Set Escape Off
Set Resource Off
Set Date SHORT
Set Seconds On
Set Hours To 24
Set Ansi On
Set Exact On
Set Deleted ON
Set Decimals To 0
= CursorSetProp("MapBinary",.T.,0)
= CursorSetProp("MapVarchar",.T.,0)
= Sys(3055,2040)
= Sys(3050,1,Evaluate(Sys(1001)))
= Sys(3050,2,Evaluate(Sys(1001)))
= SQLSetprop(0,"PacketSize",4194304)
=CURSORSETPROP("BatchUpdateCount",30,0)

=SQLSetprop(0,"DispWarnings",.F.)
=SQLSetprop(0,"DispLogin",3)
=SQLSetprop(0,"Transactions",1)
=SQLSetprop(0,"BatchMode",.T.)
=SQLSetprop(0,"PacketSize",1024)

*!*检查是否更新了升级程序
Local cUpdateExeFile
cUpdateExeFile=Addbs(ParsePath("{app}"))+"Update\WiseMisNewUpdate.exe"
IF !FILE(cUpdateExeFile)
	=HttpDownFile("http://121.12.164.74/WiseMis/WiseMisNewUpdate.exe",cUpdateExeFile)
ENDIF 
LOCAL bUpdateMainExe	&&是否更新升级程序
bUpdateMainExe=.t.
If File(cUpdateExeFile)
	IF FILE(Addbs(ParsePath("{app}"))+"WiseMisNewUpdate.exe")
		If MD5File(cUpdateExeFile)==MD5File(Addbs(ParsePath("{app}"))+"WiseMisNewUpdate.exe")
			bUpdateMainExe=.f.
		ENDIF
	ENDIF
ELSE
	bUpdateMainExe=.f.
ENDIF

IF bUpdateMainExe
	=KillProcessByName("WiseMisNewUpdate.exe")
	=INKEY(0.1,"H")
	*!*复制文件
	=CopyFiles(cUpdateExeFile,Addbs(ParsePath("{app}"))+"WiseMisNewUpdate.exe")
ENDIF

*!*声明加密狗函数
DO Decl_UKey_Dlls

DO FORM frm_login WITH cSystemLinkFile

ON ERROR 

IF !_screen.IsDebug
	ON ERROR DO OnError
	ON SHUTDOWN Quit
	READ EVENTS
ENDIF

*!*其他代码