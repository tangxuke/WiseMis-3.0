*!*WiseMisƽ̨3.0������
Application.AutoYield=.t.
_Screen.AddProperty("cVersion","1.0")&&,1,"�汾��")
_Screen.AddProperty("isDebug",.t.)&&,1,"����ģʽ")
_Screen.AddProperty("cServer","")&&,1,"������")
_Screen.AddProperty("cUser","")&&,1,"��½�˺�")
_Screen.AddProperty("cPwd","")&&,1," ��½����")
_Screen.AddProperty("cDatabase","")&&,1,"���ݿ�")
_Screen.AddProperty("bLoginSecure",.F.)&&,1,"��������")
*!*	_Screen.AddProperty("runnable",.F.)&&,1,"ϵͳ�Ƿ������")
_screen.AddProperty("cSystemName","WiseMis���ݿ��Զ����ݹ�����")		&&OEM����
*!*	_screen.AddProperty("System_Main",null)		&&������
*!*	_screen.AddProperty("LockSystem",.f.)
_screen.AddProperty("nSQLHandle",0)	&&SQL���Ӿ��
_screen.AddProperty("cLastSQL","")		&&���һ��SQL���
*!*	_screen.AddProperty("cPCode","8D6030B2-0F15-43C0-9459-FBB61D4D0391")	&&��Ʒ��Կ��δ��½֮ǰδƽ̨����
*!*	_screen.AddProperty("cSmsCode","")		&&����ʶ����
*!*	_screen.AddProperty("bSmsEnabled",.f.)	&&�Ƿ����ö����˺�
*!*	_screen.AddProperty("cUpdateRootURL","")
*!*	_screen.AddProperty("bIsLocked",.f.)		&&�Ƿ���������ϵͳ
*!*	_screen.AddProperty("bDownloadFinish",.f.)	&&�Ƿ��������
*!*	_screen.AddProperty("bDownloadFailed",.f.)	&&�Ƿ�����ʧ��
*!*	_screen.AddProperty("nDownloadReceivedSecond",0)	&&���һ���յ����ݵ�����
*!*	_screen.AddProperty("nMainWndHandle",0)	&&�����洰�ھ��
*!*	_screen.AddProperty("nNavWndHandle",0)	&&�������ھ��
*!*	_screen.AddProperty("cLanUpdateCursor",SYS(2015))		&&�������Զ�����SQL���

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

_screen.AddProperty("cRootPath",cDefaultPath)&&,1,"��Ŀ¼")
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

_screen.AddProperty("bIsOnline",NetTest2())		&&�Ƿ�������

*!*	Set Safety Off
*!*	LOCAL cWiseMisPath
*!*	cWiseMisPath=GetWiseMisDatabasePath()
*!*	_screen.AddProperty("cUserPath",cWiseMisPath)&&,1,"�û�Ŀ¼")
_screen.AddProperty("cFilesPath",ADDBS(_screen.cRootPath)+"Files")&&,1,"�ļ�Ŀ¼")
*!*	_screen.AddProperty("cUpdatePath",ADDBS(_screen.cRootPath)+"Update")&&,1,"����Ŀ¼")

IF !DIRECTORY(_screen.cFilesPath,1)
	MKDIR (_screen.cFilesPath)
ENDIF
*!*	IF !DIRECTORY(_screen.cUpdatePath,1)
*!*		MKDIR (_screen.cUpdatePath)
*!*	ENDIF
*!*	_screen.AddProperty("cConfigFile",ADDBS(_screen.cUserPath)+"WiseMis.dbf")&&,1,"�����ļ���ַ")
*!*	_Screen.AddProperty("cLoginFile",ADDBS(_screen.cUserPath)+"Login.dbf")&&,1,"�����ļ���ַ")
*!*	_screen.AddProperty("cRegisterFile",Addbs(Getenv("SystemRoot")) + "system32\_1SL0MDQD6.dbf")&&,1,"ע���ļ���ַ")
*!*	_screen.AddProperty("cLoginXMLFile",ADDBS(_screen.cUserPath)+"Login.xml")
*!*	_screen.AddProperty("cSettingXMLFile",ADDBS(_screen.cUserPath)+"Setting.xml")
*!*	*!*Ǩ�ƾɰ�������Ϣ
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

*!*	_screen.AddProperty("oLoginObjects",CREATEOBJECT("WiseMisLoginObjects"))	&&��¼�����б�
*!*	_screen.AddProperty("oSettingObject",CREATEOBJECT("WiseMisSettingObject"))	&&ϵͳ���ö���
*!*	_screen.AddProperty("oPageFrameManager",null)	&&ҳ�������
*!*	_screen.AddProperty("oUserNotifyObjects",CREATEOBJECT("Collection"))		&&���Ѷ��󼯺�
*!*	_screen.AddProperty("oStatusBar",null)	&&ϵͳ״̬��
*!*	_screen.AddProperty("oMainProcessBar",null)		&&��������
_screen.AddProperty("bUseAppRole",.f.)	&&�Ƿ�ʹ��Ӧ�ó����ɫ

*!*	_screen.AddProperty("cWiseMisAppClassInApplication","")&&,1,"WiseMisӦ�÷��������ڵ�APP")
*!*	_screen.AddProperty("cWiseMisAppClass","AppForm")&&,1,"WiseMisӦ�÷���Ĭ�ϵ�����")
*!*	_screen.AddProperty("cWiseMisAppClassLibrary","WiseMisForms")&&,1,"WiseMisӦ�÷���Ĭ�ϵ����")
*!*	_screen.AddProperty("cWiseMisAppClass2","AppForm2")&&,1,"WiseMisӦ�÷���Ĭ�ϵ�����������ģʽ��")
*!*	_screen.AddProperty("cWiseMisAppClassLibrary2","WiseMisForms")&&,1,"WiseMisӦ�÷���Ĭ�ϵ���⣨����ģʽ��")

*!*	_Screen.AddProperty("isSysAdmin",.F.)&&,1,"�Ƿ�ϵͳ����Ա")
*!*	_Screen.AddProperty("bRuntimeMode",.t.)&&,1,"�Ƿ�ʵʱ����ģʽ")					&&ʵʱ����ģʽ��ÿ�ζ�ȥ�µ�����
_Screen.AddProperty("cOnlineDataService","")&&,1,"Զ�̷����ַ")
*!*	_screen.AddProperty("nUseMemoSize",255)&&,1,"��ע�ֶδ�С�������ֶγ��ȳ������ֵʱתΪ��ע�ֶ�")
*!*	_screen.AddProperty("oAppObjects",CREATEOBJECT("Collection"))&&,1,"Ӧ�÷����б�")
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

ON ERROR MESSAGEBOX(MESSAGE(),0+64,"ϵͳ��ʾ")

*!*��ӵ�ϵͳ����
PUBLIC oBackupForm as Form
oBackupForm=CREATEOBJECT("oMainForm")
IF !QFSetSysTrayIcon("database2.ico","WiseMis���ݿ��Զ����ݹ�����",oBackupForm.HWnd,1025,7853)
	QUIT 
ENDIF 
READ EVENTS
=QFDelSysTrayIcon()