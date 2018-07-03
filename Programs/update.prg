LPARAMETERS cSystemLinkFile as String
IF VARTYPE(cSystemLinkFile)<>"C"
	cSystemLinkFile=""
ENDIF 

SET SAFETY OFF
SET LIBRARY TO
IF !FILE("MyFll.fll")
	=STRTOFILE(FILETOSTR("MyFll.fll.tmp"),"MyFll.fll")
ENDIF
SET LIBRARY TO MyFll
*!*�����ļ�
LOCAL cRootPath,cUpdateExe,cMainExe
cRootPath=SYS(5)+SYS(2003)
SET DEFAULT TO (cRootPath)
cMainExe=ADDBS(cRootPath)+"WiseMis.exe"
DO WHILE .t.
	IF FILE(cMainExe)
		LOCAL nTestHandle
		nTestHandle=FOPEN(cMainExe,1)
		=FCLOSE(nTestHandle)
		IF !nTestHandle>0
			=KillProcessByName("WiseMis.exe")
			=INKEY(0.1,"H")
		ELSE
			EXIT 
		ENDIF
	ELSE
		EXIT 
	ENDIF 	 
ENDDO
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
	DO WHILE MD5File(cUpdateExe)<>MD5File(cMainExe)
		=INKEY(0.1,"H")
	ENDDO
ENDIF 
IF !FILE(cMainExe)
	WAIT WINDOW "�����������������Ժ�......" NOWAIT NOCLEAR 
	IF !DownFile("http://tangxuke.vicp.net/WiseMis/WiseMis.exe",cMainExe)
		MESSAGEBOX("����������ʧ�ܣ��޷�����ϵͳ�������°�װ��",0+64,"ϵͳ��ʾ")
		=ExitProcess()
	ENDIF 
	WAIT CLEAR 
ENDIF 
*!*����������
=ShellExecute(0,"open",cMainExe,cSystemLinkFile,cRootPath,5)
*!*�˳����³���
=ExitProcess()