*!*�Բ����ķ�ʽ�������������Ϊϵͳ�����ļ���*.wms��
*!*ϵͳ�����ļ�
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
_screen.AddProperty("cRootPath",cDefaultPath)&&,1,"��Ŀ¼")


SET PATH TO ClassLibs,Forms,Images,Images\System,Programs,Libs,Files,User,Other,Addons
Set Procedure To ExcelBase,CommonClass,AppGrid,UI,DataPackage,SQL,App,ERROR,UserRights,FoxBarCodeQR,FoxBarCode,gpImage2,HttpDownFile,RefreshSystem,TransFormControl,Language,foxjson,foxjson_parse
Set Classlib To _base.vcx,WiseMisObject,WiseMisForms,WiseMisFields,WiseMisPages,WiseMisNewControls,DatePicker
SET LIBRARY TO
SET LIBRARY TO MyFll.fll
SET LIBRARY TO foxer.fll ADDITIVE
SET LIBRARY TO foxjson.dll ADDITIVE 
*!*ע�����Ŀؼ�
=Register_Dlls()


*!*�ỰID
PUBLIC cSessionID,cPluginFile
cSessionID=GetGUID(3)
cPluginFile=SYS(2015)
*!*ϵͳ����Ա�����ַ
PUBLIC cAdminEmailAddress
cAdminEmailAddress=""

*!*WiseMisƽ̨3.0������
Application.AutoYield=.t.

_Screen.AddProperty("isDebug",.f.)&&,1,"����ģʽ")
_Screen.AddProperty("cServer","")&&,1,"������")
_Screen.AddProperty("cUser","WiseMisAdmin")&&,1,"��½�˺�")
_Screen.AddProperty("cPwd",GetWiseMisDefaultOperatorPassword())&&,1," ��½����")
_Screen.AddProperty("cDatabase","")&&,1,"���ݿ�")
_Screen.AddProperty("cDatabase2","")&&,1,"���ݿ�")
_Screen.AddProperty("bLoginSecure",.F.)&&,1,"��������")
_screen.AddProperty("cSystemLinkFile",cSystemLinkFile)		&&ϵͳ��ݷ�ʽ
PUBLIC nSQLHandle		&&SQL���Ӿ��
nSQLHandle=0

_screen.AddProperty("cUpdateServerDatabase","WiseMisDB")	&&���·�������ַ
_screen.AddProperty("cUpdateServerUid","WiseMisAdmin")
_screen.AddProperty("cUpdateServerPwd","hlh***TXK0921")
*!*	LOCAL cUpdateServer
*!*	STORE "" TO cUpdateServer
*!*	=GetUpdateInfo(@cUpdateServer)
_screen.AddProperty("cUpdateServerName","")	&&���·�������ַ

*!*�����빫������
_screen.AddProperty("oBarCode",CREATEOBJECT("FoxBarCode"))		&&һά��
_screen.AddProperty("oBarCodeQR",CREATEOBJECT("FoxBarCodeQR"))		&&��ά��

_screen.AddProperty("bFullScreenMode",.f.)	&&ȫ��ģʽ
_screen.AddProperty("cSysMCode","")		&&ϵͳ������

_screen.AddProperty("bRuntimeMode",.f.)		&&ʵʱģʽ

*��½�˺ż����루�£�
_screen.AddProperty("cUserName","")		&&�û���
_screen.AddProperty("cUserPassword","")	&&�û�����
_screen.AddProperty("cSystemDbVersion","2.001.147")	&&��͵�WiseMisƽ̨���ݿ�汾
_screen.AddProperty("cDisplayName","")	&&��ʾ����
_screen.AddProperty("bWiseMisLoginMode",.t.)		&&��¼ģʽ��.t. WiseMis�û���ϵ��.f. SQL�û���ϵ

_screen.AddProperty("System_Main",null)		&&������
_screen.AddProperty("LockSystem",.f.)

_screen.AddProperty("cLastSQL","")	&&���һ��SQL���
_screen.AddProperty("cLastScript","")	&&���һ���ű����
_screen.AddProperty("cWiseMisPCode","C49BD667-5CA8-4DC6-8246-434A602D6CF8")		&&WiseMisƽ̨��Ʒ��Կ
_screen.AddProperty("bIsLocked",.f.)		&&�Ƿ���������ϵͳ
_screen.AddProperty("bDownloadFinish",.f.)	&&�Ƿ��������
_screen.AddProperty("bDownloadFailed",.f.)	&&�Ƿ�����ʧ��
_screen.AddProperty("nDownloadReceivedSecond",0)	&&���һ���յ����ݵ�����
_screen.AddProperty("nMainWndHandle",0)	&&�����洰�ھ��
_screen.AddProperty("nNavWndHandle",0)	&&�������ھ��
_screen.AddProperty("bShowError",.t.)		&&�Ƿ���ʾ����
_screen.AddProperty("bReportError",.f.)	&&�Ƿ񱨸����
_Screen.AddProperty("cMsdeURL","http://121.12.164.74/WiseMis/support/SQL2005.zip")		&&MSDE��ַ�ļ�
_Screen.AddProperty("cMsdeURL2","http://121.12.164.74/WiseMis/support/SQL2005.zip")		&&����MSDE��ַ�ļ�
_screen.AddProperty("cDotNetFX32Url","http://121.12.164.74/WiseMis/support/NetFx32.zip")	&&32λ.net������ص�ַ
_screen.AddProperty("cDotNetFX32Url2","http://121.12.164.74/WiseMis/support/NetFx32.zip")	&&����32λ.net������ص�ַ
_screen.AddProperty("cDotNetFX64Url","http://121.12.164.74/WiseMis/support/NetFx64.zip")	&&64λ.net������ص�ַ
_screen.AddProperty("cDotNetFX64Url2","http://121.12.164.74/WiseMis/support/NetFx64.zip")	&&����64λ.net������ص�ַ

_screen.AddProperty("nIsOnline",0)	&& 0δ���ԣ�1 ���ߣ�-1 ������
_screen.AddProperty("bIsWiseMisAdministrator",.f.)	&&�Ƿ�WiseMisϵͳ����Ա��ͨ�ã�
_screen.AddProperty("cUKeyId","���ޣ�")		&&���ܹ����
_screen.AddProperty("nRegisterResult",0)	&&ע����
_screen.AddProperty("nClientRegType",0)		&&�ͻ���ע��ģʽ��0 ����ע�ᣨ���ܹ���ͻ���ע���룬������վ��������1 ������ע�ᣨվ�������ƣ�
_screen.AddProperty("nClientCount",0)	&&�ͻ���ͬʱ������
_screen.AddProperty("bCheckClient",.f.)	&&���ͻ�������
_screen.AddProperty("bLoginOK",.f.)		&&����Ƿ��Ѿ���¼
_screen.AddProperty("nLanguage",1)		&&ϵͳ���ԣ�1=���ģ�2=Ӣ�ģ�����������������

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


_screen.AddProperty("oAppRights",CREATEOBJECT("Collection"))	&&Ӧ�÷���Ȩ��
_screen.AddProperty("oAppFieldRights",CREATEOBJECT("Collection"))	&&Ӧ�÷����ֶ�Ȩ��
_screen.AddProperty("oAppRules",CREATEOBJECT("Collection"))		&&Ӧ�÷�������
_screen.AddProperty("oAppTaskRights",CREATEOBJECT("Collection"))	&&Ӧ�÷�������Ȩ��
_screen.AddProperty("oExcelModalObjects",CREATEOBJECT("Collection"))	&&Excelģ�漯��
_screen.AddProperty("oUserRoles",CREATEOBJECT("Collection"))	&&�û���ɫ����
_screen.AddProperty("oTreeNodeTexts",CREATEOBJECT("Collection"))	&&���ڵ㳤�ı����ϣ����ڿ��ټ������ڵ�ĳ��ı���
_screen.AddProperty("oItemData",CREATEOBJECT("Collection"))	&&�������϶��󼯺�
_screen.AddProperty("oBaseData",CREATEOBJECT("Collection"))	&&�������ݶ��󼯺�
_screen.AddProperty("oCodeRule",CREATEOBJECT("Collection"))	&&���������󼯺�


*!*����ļ������Ƿ���ȷ
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
_screen.AddProperty("cUserPath",_screen.cRootPath)&&,1,"�û�Ŀ¼")
_screen.AddProperty("cFilesPath",ADDBS(_screen.cRootPath)+"Files")&&,1,"�ļ�Ŀ¼")
_screen.AddProperty("cUpdatePath",ADDBS(_screen.cRootPath)+"Update")&&,1,"����Ŀ¼")
_screen.AddProperty("cDatabasePath",ADDBS(_screen.cRootPath)+"Database")&&,1,"���ݿ�Ŀ¼")

IF !DIRECTORY(_screen.cFilesPath,1)
	MKDIR (_screen.cFilesPath)
ENDIF
IF !DIRECTORY(_screen.cUpdatePath,1)
	MKDIR (_screen.cUpdatePath)
ENDIF
IF !DIRECTORY(_screen.cDatabasePath,1)
	MKDIR (_screen.cDatabasePath)
ENDIF
_screen.AddProperty("cConfigFile",ADDBS(_screen.cUserPath)+"WiseMis.dbf")&&,1,"�����ļ���ַ")
_Screen.AddProperty("cLoginFile",ADDBS(_screen.cUserPath)+"Login.dbf")&&,1,"�����ļ���ַ")
_screen.AddProperty("cRegisterFile",Addbs(Getenv("SystemRoot")) + "system32\_1SL0MDQD6.dbf")&&,1,"ע���ļ���ַ")
_screen.AddProperty("cLoginXMLFile",ADDBS(_screen.cUserPath)+"Login.xml")
_screen.AddProperty("cSettingXMLFile",ADDBS(_screen.cUserPath)+"Setting.xml")


_screen.AddProperty("oLoginObjects",CREATEOBJECT("WiseMisLoginObjects"))	&&��¼�����б�
_screen.AddProperty("oSettingObject",CREATEOBJECT("WiseMisSettingObject"))	&&ϵͳ���ö���
_screen.AddProperty("oPageFrameManager",null)	&&ҳ�������
_screen.AddProperty("oUserNotifyObjects",CREATEOBJECT("Collection"))		&&���Ѷ��󼯺�
_screen.AddProperty("oStatusBar",null)	&&ϵͳ״̬��
_screen.AddProperty("oAppTypeObjectCollection",CREATEOBJECT("Collection"))	&&Ӧ����𼯺�
_screen.AddProperty("oUserObjectCollection",CREATEOBJECT("Collection"))		&&�û��б�
_screen.AddProperty("oF7FilterExprCollection",CREATEOBJECT("Collection"))	&&F7���˱���ʽ����

_screen.AddProperty("cWiseMisAppClassInApplication","")&&,1,"WiseMisӦ�÷��������ڵ�APP")
_screen.AddProperty("cWiseMisAppClass","AppForm_New")&&,1,"WiseMisӦ�÷���Ĭ�ϵ�����")
_screen.AddProperty("cWiseMisAppClassLibrary","WiseMisForms")&&,1,"WiseMisӦ�÷���Ĭ�ϵ����")
_screen.AddProperty("cWiseMisAppClass2","AppForm_Old")&&,1,"WiseMisӦ�÷���Ĭ�ϵ�����������ģʽ��")
_screen.AddProperty("cWiseMisAppClassLibrary2","WiseMisForms")&&,1,"WiseMisӦ�÷���Ĭ�ϵ���⣨����ģʽ��")

_Screen.AddProperty("isSysAdmin",.F.)&&,1,"�Ƿ�ϵͳ����Ա")
_screen.AddProperty("nUseMemoSize",255)&&,1,"��ע�ֶδ�С�������ֶγ��ȳ������ֵʱתΪ��ע�ֶ�")
_screen.AddProperty("oAppObjects",CREATEOBJECT("Collection"))&&,1,"Ӧ�÷����б�")

_screen.AddProperty("_MemberData",FILETOSTR("_screen.xml"))

WITH _screen.oSettingObject as WiseMisSettingObject
	.Load()
	IF !EMPTY(.GetValue("Language"))
		_screen.nLanguage=VAL(.GetValue("Language"))
	ENDIF 
ENDWITH 

_screen.AddProperty("cSystemName",ToEnglish("WiseMisƽ̨"))		&&OEM����
_Screen.AddProperty("cVersion",ToEnglish("����ģʽ"))&&,1,"�汾��")


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

*!*����Ƿ��������������
Local cUpdateExeFile
cUpdateExeFile=Addbs(ParsePath("{app}"))+"Update\WiseMisNewUpdate.exe"
IF !FILE(cUpdateExeFile)
	=HttpDownFile("http://121.12.164.74/WiseMis/WiseMisNewUpdate.exe",cUpdateExeFile)
ENDIF 
LOCAL bUpdateMainExe	&&�Ƿ������������
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
	*!*�����ļ�
	=CopyFiles(cUpdateExeFile,Addbs(ParsePath("{app}"))+"WiseMisNewUpdate.exe")
ENDIF

*!*�������ܹ�����
DO Decl_UKey_Dlls

DO FORM frm_login WITH cSystemLinkFile

ON ERROR 

IF !_screen.IsDebug
	ON ERROR DO OnError
	ON SHUTDOWN Quit
	READ EVENTS
ENDIF

*!*��������