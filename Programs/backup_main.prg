*!*WiseMis平台3.0主程序
Application.AutoYield=.t.
_Screen.AddProperty("cVersion","1.0")&&,1,"版本号")
_Screen.AddProperty("isDebug",.t.)&&,1,"调试模式")
_Screen.AddProperty("cServer","")&&,1,"服务器")
_Screen.AddProperty("cUser","")&&,1,"登陆账号")
_Screen.AddProperty("cPwd","")&&,1," 登陆密码")
_Screen.AddProperty("cDatabase","")&&,1,"数据库")
_Screen.AddProperty("bLoginSecure",.F.)&&,1,"信任连接")
*!*	_Screen.AddProperty("runnable",.F.)&&,1,"系统是否可运行")
_screen.AddProperty("cSystemName","WiseMis数据库自动备份管理器")		&&OEM名称
*!*	_screen.AddProperty("System_Main",null)		&&主界面
*!*	_screen.AddProperty("LockSystem",.f.)
_screen.AddProperty("nSQLHandle",0)	&&SQL连接句柄
_screen.AddProperty("cLastSQL","")		&&最近一条SQL语句
*!*	_screen.AddProperty("cPCode","8D6030B2-0F15-43C0-9459-FBB61D4D0391")	&&产品密钥，未登陆之前未平台本身
*!*	_screen.AddProperty("cSmsCode","")		&&短信识别码
*!*	_screen.AddProperty("bSmsEnabled",.f.)	&&是否启用短信账号
*!*	_screen.AddProperty("cUpdateRootURL","")
*!*	_screen.AddProperty("bIsLocked",.f.)		&&是否正在锁定系统
*!*	_screen.AddProperty("bDownloadFinish",.f.)	&&是否下载完成
*!*	_screen.AddProperty("bDownloadFailed",.f.)	&&是否下载失败
*!*	_screen.AddProperty("nDownloadReceivedSecond",0)	&&最近一次收到数据的秒数
*!*	_screen.AddProperty("nMainWndHandle",0)	&&主界面窗口句柄
*!*	_screen.AddProperty("nNavWndHandle",0)	&&导航窗口句柄
*!*	_screen.AddProperty("cLanUpdateCursor",SYS(2015))		&&局域网自动升级SQL语句

*!*	SELECT 0
*!*	CREATE CURSOR (_screen.cLanUpdateCursor) (FileName C(50),PathName C(50),Md5Code C(32),id I,RegServer L,IsFont L,FontName C(50),Class C(250))

LOCAL cDefaultPath
cDefaultPath=SYS(5)+SYS(2003)

SET DEFAULT TO (cDefaultPath)

SET PATH TO ClassLibs,Forms,Images,Images\System,Programs,Libs,Files,User,Other,Addons
SET PROCEDURE TO error,sql
SET CLASSLIB TO Backup
*!*	Set Procedure To ExcelBase,CommonClass,AppGrid,UI,DataPackage,ImportDataPackage,SQL,App
*!*	Set Classlib To _base.vcx,WiseMisObject,WiseMisForms,WiseMisFields,WiseMisPages,WiseMisNewControls

SET LIBRARY TO
IF !FILE("MyFll.fll")
	=STRTOFILE(FILETOSTR("MyFll.fll.txt"),"MyFll.fll")
ENDIF
SET LIBRARY TO MyFll.fll
IF !FILE("foxer.fll")
	=STRTOFILE(FILETOSTR("foxer.fll.txt"),"foxer.fll")
ENDIF
SET LIBRARY TO foxer.fll ADDITIVE 

_screen.AddProperty("cRootPath",cDefaultPath)&&,1,"根目录")
*!*	IF EMPTY(regRead("","Licenses\12B142A4-BD51-11d1-8C08-0000F8754DA1",2147483648))
*!*		LOCAL cTempRegFile
*!*		cTempRegFile=ADDBS(GETENV("TEMP"))+SYS(2015)+".reg"
*!*		=STRTOFILE(FILETOSTR("Other\System.reg"),cTempRegFile)
*!*		IF FILE(cTempRegFile)
*!*			=ShellExecWait("regedit","/s "+cTempRegFile,0)
*!*		ENDIF 
*!*	ENDIF 

*!*	LOCAL o as MSWinsockLib.Winsock,oErr as Exception
*!*	TRY 
*!*		o=CREATEOBJECT("MSWinsock.Winsock.1")
*!*	CATCH TO oErr
*!*	ENDTRY 
*!*	IF VARTYPE(o)<>"O"
*!*		=ShellExecWait("regsvr32","/s "+ADDBS(cDefaultPath)+"Other\mswinsck.ocx",0)
*!*	ENDIF 

_screen.AddProperty("bIsOnline",NetTest2())		&&是否连上网

*!*	Set Safety Off
*!*	LOCAL cWiseMisPath
*!*	cWiseMisPath=GetWiseMisDatabasePath()
*!*	_screen.AddProperty("cUserPath",cWiseMisPath)&&,1,"用户目录")
_screen.AddProperty("cFilesPath",ADDBS(_screen.cRootPath)+"Files")&&,1,"文件目录")
*!*	_screen.AddProperty("cUpdatePath",ADDBS(_screen.cRootPath)+"Update")&&,1,"更新目录")

IF !DIRECTORY(_screen.cFilesPath,1)
	MKDIR (_screen.cFilesPath)
ENDIF
*!*	IF !DIRECTORY(_screen.cUpdatePath,1)
*!*		MKDIR (_screen.cUpdatePath)
*!*	ENDIF
*!*	_screen.AddProperty("cConfigFile",ADDBS(_screen.cUserPath)+"WiseMis.dbf")&&,1,"配置文件地址")
*!*	_Screen.AddProperty("cLoginFile",ADDBS(_screen.cUserPath)+"Login.dbf")&&,1,"配置文件地址")
*!*	_screen.AddProperty("cRegisterFile",Addbs(Getenv("SystemRoot")) + "system32\_1SL0MDQD6.dbf")&&,1,"注册文件地址")
*!*	_screen.AddProperty("cLoginXMLFile",ADDBS(_screen.cUserPath)+"Login.xml")
*!*	_screen.AddProperty("cSettingXMLFile",ADDBS(_screen.cUserPath)+"Setting.xml")
*!*	*!*迁移旧版配置信息
*!*	IF FILE(ADDBS(_screen.cRootPath)+"User\Login.xml")
*!*		=CopyFiles(ADDBS(_screen.cRootPath)+"User\Login.xml",_screen.cUserPath)
*!*	ELSE
*!*		IF FILE(ADDBS(ParsePath("{appdata_all}"))+"WiseMis\Login.xml")
*!*			=CopyFiles(ADDBS(ParsePath("{appdata_all}"))+"WiseMis\Login.xml",_screen.cUserPath)
*!*		ENDIF 
*!*	ENDIF 
*!*	IF FILE(ADDBS(_screen.cRootPath)+"User\Setting.xml")
*!*		=CopyFiles(ADDBS(_screen.cRootPath)+"User\Setting.xml",_screen.cUserPath)
*!*	ELSE
*!*		IF FILE(ADDBS(ParsePath("{appdata_all}"))+"WiseMis\Setting.xml")
*!*			=CopyFiles(ADDBS(ParsePath("{appdata_all}"))+"WiseMis\Setting.xml",_screen.cUserPath)
*!*		ENDIF 
*!*	ENDIF 
*!*	IF DIRECTORY(ADDBS(_screen.cRootPath)+"User",1)
*!*		=DeleteFiles(ADDBS(_screen.cRootPath)+"User")
*!*	ENDIF 
*!*	IF DIRECTORY(ADDBS(ParsePath("{appdata_all}"))+"WiseMis",1)
*!*		=DeleteFiles(ADDBS(ParsePath("{appdata_all}"))+"WiseMis")
*!*	ENDIF 

*!*	_screen.AddProperty("oLoginObjects",CREATEOBJECT("WiseMisLoginObjects"))	&&登录对象列表
*!*	_screen.AddProperty("oSettingObject",CREATEOBJECT("WiseMisSettingObject"))	&&系统配置对象
*!*	_screen.AddProperty("oPageFrameManager",null)	&&页框管理器
*!*	_screen.AddProperty("oUserNotifyObjects",CREATEOBJECT("Collection"))		&&提醒对象集合
*!*	_screen.AddProperty("oStatusBar",null)	&&系统状态栏
*!*	_screen.AddProperty("oMainProcessBar",null)		&&主进度条
_screen.AddProperty("bUseAppRole",.f.)	&&是否使用应用程序角色

*!*	_screen.AddProperty("cWiseMisAppClassInApplication","")&&,1,"WiseMis应用方案类所在的APP")
*!*	_screen.AddProperty("cWiseMisAppClass","AppForm")&&,1,"WiseMis应用方案默认的类名")
*!*	_screen.AddProperty("cWiseMisAppClassLibrary","WiseMisForms")&&,1,"WiseMis应用方案默认的类库")
*!*	_screen.AddProperty("cWiseMisAppClass2","AppForm2")&&,1,"WiseMis应用方案默认的类名（主从模式）")
*!*	_screen.AddProperty("cWiseMisAppClassLibrary2","WiseMisForms")&&,1,"WiseMis应用方案默认的类库（主从模式）")

*!*	_Screen.AddProperty("isSysAdmin",.F.)&&,1,"是否系统管理员")
*!*	_Screen.AddProperty("bRuntimeMode",.t.)&&,1,"是否实时运行模式")					&&实时运行模式，每次都去新的配置
_Screen.AddProperty("cOnlineDataService","")&&,1,"远程服务地址")
*!*	_screen.AddProperty("nUseMemoSize",255)&&,1,"备注字段大小，即当字段长度超过这个值时转为备注字段")
*!*	_screen.AddProperty("oAppObjects",CREATEOBJECT("Collection"))&&,1,"应用方案列表")
_screen.AddProperty("_MemberData",FILETOSTR("_screen.xml"))

*!*	WITH _screen.oSettingObject as WiseMisSettingObject
*!*		.Load(_screen.cSettingXMLFile)
*!*	ENDWITH

*!*	DO Common_Declare_Dlls

Set Escape Off
Set Resource Off
Set Date SHORT
Set Seconds On
Set Hours To 24
Set Ansi On
Set Exact On
Set Deleted On
Set Decimals To 0
= CursorSetProp("MapBinary",.T.,0)
= CursorSetProp("MapVarchar",.T.,0)
= Sys(3055,2040)
= Sys(3050,1,Evaluate(Sys(1001)))
= Sys(3050,2,Evaluate(Sys(1001)))
= SQLSetprop(0,"PacketSize",4194304)
= SQLSetprop(0,"IdleTimeout",300)
=CURSORSETPROP("BatchUpdateCount",30,0)

=SQLSetprop(0,"DispWarnings",.F.)
=SQLSetprop(0,"DispLogin",3)
=SQLSetprop(0,"Transactions",1)
=SQLSetprop(0,"BatchMode",.F.)
=SQLSetprop(0,"PacketSize",1024)

ON ERROR MESSAGEBOX(MESSAGE(),0+64,"系统提示")

*!*添加到系统托盘
PUBLIC oBackupForm as Form
oBackupForm=CREATEOBJECT("oMainForm")
IF !QFSetSysTrayIcon("database2.ico","WiseMis数据库自动备份管理器",oBackupForm.HWnd,1025,7853)
	QUIT 
ENDIF 
READ EVENTS
=QFDelSysTrayIcon()