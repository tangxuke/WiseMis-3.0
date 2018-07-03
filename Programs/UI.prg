
*!*����Ӧ�÷���
PROCEDURE HideApplication
	LPARAMETERS cAppName
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_AppSchame where AppName='<<cAppName>>' AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_AppSchame(AppName,UserName,Visible) VALUES ('<<cAppName>>','<<_screen.cUserName>>',0)
	ELSE
		update WiseMis_AppSchame set Visible=0 where AppName='<<cAppName>>' and UserName='<<_screen.cUserName>>'
	ENDTEXT 
	RETURN Execute(m.cSQL)
ENDPROC 

*!*���ز�ѯ����
PROCEDURE HideQuery
	LPARAMETERS cAppName
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_QuerySchame where select_name='<<cAppName>>' AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_QuerySchame(select_name,UserName,Visible) VALUES ('<<cAppName>>','<<_screen.cUserName>>',0)
	ELSE
		update WiseMis_QuerySchame set Visible=0 where select_name='<<cAppName>>' and UserName='<<_screen.cUserName>>'
	ENDTEXT 
	RETURN Execute(m.cSQL)
ENDPROC 

*!*���ز˵���
PROCEDURE HideMenu
	LPARAMETERS nMenuId
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_MenuSchame where id=<<nMenuId>> AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_MenuSchame(id,UserName,Visible) VALUES (<<nMenuId>>,'<<_screen.cUserName>>',0)
	ELSE
		update WiseMis_MenuSchame set Visible=0 where id=<<nMenuId>> and UserName='<<_screen.cUserName>>'
	ENDTEXT 
	RETURN Execute(m.cSQL)
ENDPROC 

*!*��ʾ����Ӧ�÷����������û���
PROCEDURE ShowAllApps
	RETURN Execute("update WiseMis_AppSchame set Visible=1 where UserName='"+_screen.cUserName+"'")
ENDPROC 

*!*��ʾ���в�ѯ�����������û���
PROCEDURE ShowAllQueries
	RETURN Execute("update WiseMis_QuerySchame set Visible=1 where UserName='"+_screen.cUserName+"'")
ENDPROC 

*!*��ʾ���в˵�������û���
PROCEDURE ShowAllMenus
	RETURN Execute("update WiseMis_MenuSchame set Visible=1 where UserName='"+_screen.cUserName+"'")
ENDPROC 

*!*����Ӧ�÷���ͼ�꣨�����û���
PROCEDURE ChangeUserAppIcon
	LPARAMETERS cAppName,cImageFile
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_AppSchame where AppName='<<cAppName>>' AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_AppSchame(AppName,UserName,IconImageGuid) VALUES ('<<cAppName>>','<<_screen.cUserName>>',null)
	ENDTEXT 
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF 
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_AppSchame where AppName='"+cAppName+"' and UserName='"+_screen.cUserName+"')"
	
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_AppSchame set IconImageGuid=null where AppName='"+cAppName+"' and UserName='"+_screen.cUserName+"'"
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_AppSchame set IconImageGuid='"+cFileGuid+"' where AppName='"+cAppName+"' and UserName='"+_screen.cUserName+"'"
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF 
ENDPROC 

*!*���Ĳ�ѯ����ͼ�꣨�����û���
PROCEDURE ChangeUserQueryIcon
	LPARAMETERS cAppName,cImageFile
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_QuerySchame where select_name='<<cAppName>>' AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_QuerySchame(select_name,UserName,IconImageGuid) VALUES ('<<cAppName>>','<<_screen.cUserName>>',null)
	ENDTEXT 
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_QuerySchame where Select_Name='"+cAppName+"' and UserName='"+_screen.cUserName+"')"
	 
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_QuerySchame set IconImageGuid=null where Select_Name='"+cAppName+"' and UserName='"+_screen.cUserName+"'"
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_QuerySchame set IconImageGuid='"+cFileGuid+"' where Select_Name='"+cAppName+"' and UserName='"+_screen.cUserName+"'"
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF
ENDPROC 

*!*���Ĳ˵�ͼ�꣨�����û���
PROCEDURE ChangeUserMenuIcon
	LPARAMETERS nMenuId,cImageFile
	LOCAL cSQL
	TEXT TO m.cSQL NOSHOW TEXTMERGE 
	IF NOT exists(select * from WiseMis_MenuSchame where id=<<nMenuId>> AND UserName='<<_screen.cUserName>>')
		INSERT INTO WiseMis_MenuSchame(id,UserName,IconImageGuid) VALUES (<<nMenuId>>,'<<_screen.cUserName>>',null)
	ENDTEXT 
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_MenuSchame where id="+TRANSFORM(nMenuId)+" and UserName='"+_screen.cUserName+"')"
	
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_MenuSchame set IconImageGuid=null where UserName='"+_screen.cUserName+"' and id="+TRANSFORM(nMenuId)
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_MenuSchame set IconImageGuid='"+cFileGuid+"' where id="+TRANSFORM(nMenuId)+" and UserName='"+_screen.cUserName+"'"
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF
ENDPROC 

*!*����Ӧ�÷���ͼ�꣨����ϵͳ��
PROCEDURE ChangeSysAppIcon
	LPARAMETERS cAppName,cImageFile
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_AppSchame where AppName='"+cAppName+"')"
	m.cSQL="update WiseMis_AppSchame set IconImageGuid=null where AppName='"+cAppName+"'"
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF 
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_AppIndex where AppName='"+cAppName+"')"
	
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_AppIndex set IconImageGuid=null where AppName='"+cAppName+"'"
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_AppIndex set IconImageGuid='"+cFileGuid+"' where AppName='"+cAppName+"'"
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF 
ENDPROC 

*!*���Ĳ�ѯ����ͼ�꣨����ϵͳ��
PROCEDURE ChangeSysQueryIcon
	LPARAMETERS cAppName,cImageFile
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_QuerySchame where Select_Name='"+cAppName+"')"
	m.cSQL="update WiseMis_QuerySchame set IconImageGuid=null where Select_Name='"+cAppName+"'"
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF 
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_Query where Select_Name='"+cAppName+"')"
	
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_Query set IconImageGuid=null where Select_Name='"+cAppName+"'"
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_Query set IconImageGuid='"+cFileGuid+"' where Select_Name='"+cAppName+"'"
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF 
	
ENDPROC 

*!*���Ĳ˵�ͼ�꣨����ϵͳ��
PROCEDURE ChangeSysMenuIcon
	LPARAMETERS nMenuId,cImageFile
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_MenuSchame where id="+TRANSFORM(nMenuId)+")"
	m.cSQL="update WiseMis_MenuSchame set IconImageGuid=null where id="+TRANSFORM(nMenuId)
	IF !Execute(m.cSQL)
		RETURN .f.
	ENDIF 
	
	LOCAL cSQL
	cSQL="delete from WiseMis_Files where Guid in (Select IconImageGuid from WiseMis_Menu where id="+TRANSFORM(nMenuId)+")"
	
	IF !FILE(cImageFile)
		cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_Menu set IconImageGuid=null where id="+TRANSFORM(nMenuId)
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		
		IF SaveFileToDB(cImageFile,@cFileGuid)
			cSQL = cSQL + CHR(13) + CHR(10) + "update WiseMis_Menu set IconImageGuid='"+cFileGuid+"' where id="+TRANSFORM(nMenuId)
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF 
ENDPROC 

*!*����Ӧ�����ͼ��
PROCEDURE ChangeAppTypeIcon
	LPARAMETERS cAppType,cImageFile
	IF !FILE(cImageFile)
		LOCAL cSQL
		TEXT TO cSQL NOSHOW TEXTMERGE 
DECLARE @cAppType varchar(50)
SET @cAppType='<<cAppType>>'

DELETE FROM WiseMis_Files WHERE Guid=(select IconImageGuid FROM WiseMis_AppType WHERE name=@cAppType)
UPDATE WiseMis_AppType SET IconImageGuid=null WHERE name=@cAppType
		ENDTEXT 
		RETURN Execute(cSQL)
	ELSE
		LOCAL cFileGuid
		cFileGuid=""
		IF SaveFileToDB(cImageFile,@cFileGuid)
			LOCAL cSQL
			TEXT TO cSQL NOSHOW TEXTMERGE 
DECLARE @cAppType varchar(50)
SET @cAppType='<<cAppType>>'

DELETE FROM WiseMis_Files WHERE Guid=(select IconImageGuid FROM WiseMis_AppType WHERE name=@cAppType)
UPDATE WiseMis_AppType SET IconImageGuid='<<cFileGuid>>' WHERE name=@cAppType
			ENDTEXT 
			RETURN Execute(cSQL)
		ELSE
			RETURN .f.
		ENDIF 
	ENDIF 
ENDPROC 