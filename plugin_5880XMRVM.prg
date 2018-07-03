***********************************************************
*!*应用表单退出时
PROCEDURE __appform__exit__
LPARAMETERS oForm as Form
*-----------------------------------------------
*请不要更改参数栏
*以下是用户代码
ENDPROC

***********************************************************
*!*应用表单启动时
PROCEDURE __appform__start__
LPARAMETERS oForm as Form
*-----------------------------------------------
*请不要更改参数栏
*以下是用户代码


=AddProperty(oForm,"_cAppName",oForm.oAppObject.cAppName)
=AddProperty(oForm,"_cBaseTable",oForm.oAppObject.cBaseTable)
=AddProperty(oForm,"_cMAppName",oForm.oAppObject.cDataCursor)
=AddProperty(oForm,"_cTempCursor",sys(2015))
ENDPROC

***********************************************************
*!*应用方案退出时
PROCEDURE __appobject__exit__
LPARAMETERS oAppObject as AppObject
*-----------------------------------------------
*请不要更改参数栏
*以下是用户代码

*示例代码
*alert("appobject exit!")

ENDPROC

***********************************************************
*!*应用方案启动时
PROCEDURE __appobject__start__
LPARAMETERS oAppObject as AppObject
*-----------------------------------------------
*请不要更改参数栏
*以下是用户代码

*示例代码
*alert("appobject started!")

ENDPROC

***********************************************************
*!*转换脚本代码
PROCEDURE __script__translate__
LPARAMETERS cMethodCode
*--------------------------------------------------
*以下是用户代码

cMethodCode=strtran(cMethodCode,"this.select_value","GetValue",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.select_data","SelectData",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.exec_sql","Execute",-1,-1,1)
cMethodCode=strtran(cMethodCode,"this.closecursor","=CloseAlias",-1,-1,1)
*--------------------------------------------------
*messagebox(cmethodCode)
*返回转换后的代码
return cMethodCode
ENDPROC

***********************************************************
*!*系统退出时执行的方法
PROCEDURE __system__exit__
*示例代码
*alert("system exited!")
ENDPROC

***********************************************************
*!*系统启动时执行的方法
PROCEDURE __system__start__
*示例代码
*alert("system started!")
=AddProperty(_screen,"_SysServer",_screen.cServer)
=AddProperty(_screen,"_SysDatabase",_screen.cDatabase)
=AddProperty(_screen,"_SysPwd",_screen.cPwd)
=AddProperty(_screen,"_SysUser",_screen.cUser)
ENDPROC

***********************************************************
*!*测试用
PROCEDURE alert
LPARAMETERS strMessage as String
MessageBox1(strMessage)
ENDPROC

***********************************************************
*!*启动一个程式
PROCEDURE CreateApplication
LPARAMETERS cAppName,cAppCaption,cRelationExp,isMasterDetail

*示例：CreateAppLication("客户字典","客户字典","",0)

messagebox("未设置代码【CreateApplication】",0+64,"系统提示")
ENDPROC

***********************************************************
*!*计算一个数据的sql语句表达式
PROCEDURE GetSqlValue
LPARAMETERS oValue

*示例：GetSqlValue(ovalue)

if vartype(oValue)="C"
	return "'"+oValue+"'"
endif

if inlist(vartype(oValue),"D","T")
	return "'"+transform(oValue)+"'"
endif

if vartype(oValue)="L"
	return iif(oValue,"1","0")
endif

return transform(oValue)
ENDPROC

***********************************************************
*!*启动一个字符帮助表单
PROCEDURE OpenCharForm
LPARAMETERS cChar

*示例：OpenCharForm("张三")

messagebox("未设置功能代码【"+OpenCharForm+"】 !",0+64,"系统提示")
ENDPROC

***********************************************************
*!*启动一个数据选择表单
PROCEDURE OpenFormWithResult
LPARAMETERS cCommandText  ,cReturnField  

*示例：OpenFormWithResult("select xx from table","xx")

local oBaseMethod as Base_Method
oBaseMethod=CREATEOBJECT("Base_Method")

return oBaseMethod.open_form_with_result("frm_f7",null,cCommandText,cReturnField)
ENDPROC

***********************************************************
*!*发送邮件
PROCEDURE ToMail
LPARAMETERS cSendAccount,cSendName,cSendPwd,cRecipientList,cSubJect,cBody,cAttachmentList,cSmtpServer

*示例：TOMail("123456789@qq.com","发件人张三","张三的邮件密码"
*				,"aa@qq.com:李四,bb@qq.com:王五","邮件主题","邮件内容"
*,"c:\附件.xls","SMTP.QQ.COM")

messagebox("未设置代码【ToMail】！",0+64,"系统提示")
ENDPROC

***********************************************************
*!*导出pdf
PROCEDURE ToPDF
LPARAMETERS cPrintName,cReportFileName,cPDFFileName,cCursorName

示例：TOPDF("pdf打印机名","报表名称","c:\123.pdf",this._ctempcursor)

messagebox("未设置代码【"+ToPDF+"】！",0+64,"系统提示")
ENDPROC

***********************************************************
*!*打印报表
PROCEDURE ToPrint
LPARAMETERS lcFrx,cCursorName
IF EMPTY(lcFrx) OR EMPTY(cCursorName)
	RETURN 
ENDIF
IF !FILE(lcFrx)
	RETURN 
ENDIF 
IF !USED(cCursorName)
	MESSAGEBOX("打印数据错误！",0+64,"系统提示")
	RETURN
ENDIF 
lcFrt=JUSTPATH(lcFrx)+"\"+JUSTSTEM(lcFrx)+".Frt"

cTargeFrx="C:\"+JUSTSTEM(lcFrx)+".frx"
cTargeFrt="C:\"+JUSTSTEM(lcFrt)+".frt"
IF FILE(cTargeFrx)
	DELETE FILE (cTargeFrx)
ENDIF 
IF FILE(cTargeFrt)
	DELETE FILE (cTargeFrt)
ENDIF 
COPY FILE (lcFrx) TO (cTargeFrx)
COPY FILE (lcFrt) TO (cTargeFrt)
Select 0
Use (cTargeFrx) IN 0 ALIAS mFrx Exclusive Again
Replace expr With ''	,tag With '',tag2 With '' For objtype = 1 And objcode = 53
Go Top
Use
SELECT (cCursorName)
keyboard "{CTRL+F10}"
SET PRINTER TO NAME GETPRINTER( )
=SYS(1037)
report form (cTargeFrx) TO PRINTER PROMPT PREVIEW 
IF FILE(cTargeFrx)
	DELETE FILE (cTargeFrx)
ENDIF 
IF FILE(cTargeFrt)
	DELETE FILE (cTargeFrt)
ENDIF
ENDPROC

