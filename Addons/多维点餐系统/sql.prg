

*!*连接数据库
Procedure Connect
	Lparameters cServer,cUserID,cPassword,cDatabase,bLoginSecure
	IF ISNULL(_screen.cDatabase)
		_screen.cDatabase=_screen.cDatabase2
	ENDIF


	If Vartype(cServer)<>"C"
		cServer=_Screen.cServer
	Endif
	If Vartype(cUserID)<>"C"
		cUserID=_Screen.cUser
	Endif
	If Vartype(cPassword)<>"C"
		cPassword=_Screen.cPwd
	Endif
	If Vartype(cDatabase)<>"C"
		cDatabase=_Screen.cDatabase
	Endif
	If Parameters()<5
		bLoginSecure=_Screen.bLoginSecure
	Endif
	If Vartype(bLoginSecure)<>"L"
		bLoginSecure=.F.
	ENDIF

	Local strConn,cDBDriver
	cDBDriver=""
	If File(Addbs(_Screen.cRootPath)+cServer+".txt")
		Local cServerText
		cServerText=Filetostr(Addbs(_Screen.cRootPath)+cServer+".txt")
		cDBDriver=Getwordnum(cServerText,1,":")
		If !Empty(Getwordnum(cServerText,2,":"))
			cServer=Getwordnum(cServerText,2,":")
		Endif
	Endif
	If Empty(cDBDriver)
		cDBDriver="{SQL Server}"
	ENDIF

	If !bLoginSecure
		strConn = "Driver="+cDBDriver+";Server=" + cServer + ";database=" + cDatabase + ";uid=" + cUserID + ";pwd=" + cPassword
	Else
		strConn = "Driver="+cDBDriver+";Server=" + cServer + ";database=" + cDatabase + ";uid=" + cUserID + ";pwd=" + cPassword + ";Trusted_Connection=Yes"
	Endif
	strConn = strConn + ";APP="+IIF(_screen.IsDebug,"WiseMis平台(调试模式)",_screen.cSystemName+" Version:" + _Screen.cVersion)
	=Disconnect()
	nSQLHandle= Sqlstringconnect(strConn)
	
	If nSQLHandle<=0
		Local cErrorMessage
		cErrorMessage=Format_Error()
		ERROR cErrorMessage
	ENDIF
	
	*!*设置默认事务锁定行为（不锁定）
	*=SQLEXEC(nSQLHandle,"SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED")

	Return nSQLHandle
Endproc

*!*断开连接
Procedure Disconnect
	If nSQLHandle<=0
		Return
	ENDIF
	=SQLDisconnect(nSQLHandle)
	nSQLHandle=0
ENDPROC


*!*执行命令
Procedure Execute
	Lparameter cSqlCmd,cServer,cUserID,cPassword,cDatabase,bLoginSecure
	If Vartype(cSqlCmd)<>"C" Or Empty(cSqlCmd)
		Return .T.
	ENDIF
	
	LOCAL cAddonSQL,cAddonSQL2
	TEXT TO cAddonSQL NOSHOW TEXTMERGE 
	IF exists(select * from sysobjects where id=object_id('WiseMis_UserOnline') AND ObjectProperty(id,'IsUserTable')=1)
	BEGIN
		DELETE FROM WiseMis_UserOnline where spid=@@spid
		INSERT INTO WiseMis_UserOnline(spid,UserName) VALUES (@@spid,'<<_screen.cUserName>>')
	END
	ENDTEXT 
	TEXT TO cAddonSQL2 NOSHOW TEXTMERGE 
	IF exists(select * from sysobjects where id=object_id('WiseMis_UserOnline') AND ObjectProperty(id,'IsUserTable')=1)
	BEGIN
		DELETE FROM WiseMis_UserOnline where spid=@@spid
	END
	ENDTEXT 
	cSqlCmd=cAddonSQL+CHR(13)+CHR(10)+cSqlCmd+CHR(13)+CHR(10)+cAddonSQL2
	cSqlCmd=ParseSQL(cSqlCmd)
	If Parameters()<6
		bLoginSecure=_Screen.bLoginSecure
	Endif

	If nSQLHandle<=0
		nSQLHandle=Connect(cServer,cUserID,cPassword,cDatabase,bLoginSecure)
		IF nSQLHandle<=0
			RETURN .f.
		ENDIF
	ENDIF

	=SQLSETPROP(nSQLHandle,"BatchMode",.t.)

	LOCAL bPreparedSQL

	If nSQLHandle>0
		Local cPreparedSql , cMySql
		cPreparedSql=cSqlCmd
		cMySql = ""
		Local nGoPos,__cErrorMessage
		Do While Len(cPreparedSql)>0
			nGoPos = At("&" + "e" + "x" + "e" + "c" + "_" + "n" + "o" + "w" + ";",cPreparedSql)
			If nGoPos > 0
				cMySql = Left(cPreparedSql,nGoPos - 1)
				cPreparedSql = Substr(cPreparedSql,nGoPos + 10)
			Else
				cMySql = cPreparedSql
				cPreparedSql = ""
			Endif
			If Empty(cMySql)
				Loop
			Endif

			cMySql=STRTRAN(cMySql,"[@@]","?")
			cMySql=STRTRAN(cMySql,"{##}",CHR(13)+CHR(10)+"GO",-1,-1,1)
			_screen.cLastSQL=cMySql
			DO WHILE SQLMORERESULTS(nSQLHandle)=1
			ENDDO
			IF LEN(cMySql)>1024
				= SQLPrepare(nSQLHandle,cMySql)
				If SQLExec(nSQLHandle) < 1
					IF _screen.IsDebug
						_cliptext=cMySql
					ENDIF
					__cErrorMessage=Format_Error()

					Error __cErrorMessage
					=SQLIdleDisconnect(nSQLHandle)
					Return .F.
				Endif
			ELSE
				If SQLExec(nSQLHandle,cMySql) < 1
					IF _screen.IsDebug
						_cliptext=cMySql
					ENDIF
					__cErrorMessage=Format_Error()
					Error __cErrorMessage
					=SQLIdleDisconnect(nSQLHandle)
					Return .F.
				Endif
			ENDIF
			DO WHILE SQLMORERESULTS(nSQLHandle)=1
			ENDDO
		Enddo
		=SQLIdleDisconnect(nSQLHandle)
		*=Disconnect()
	Else
		Return .F.
	Endif
	Return .T.
Endproc

PROCEDURE ParseSQL
	LPARAMETERS __cSQL as String,bPrepExec as Boolean
	IF EMPTY(__cSQL)
		RETURN ""
	ENDIF
	
	*!*特殊约定，_!39#_表示单引号'
	__cSQL=STRTRAN(__cSQL,"_39_","'",-1,-1,1)

	IF VARTYPE(bPrepExec)<>"L"
		bPrepExec=.f.
	ENDIF
	LOCAL m.a	&&单引号标志
	LOCAL m.b	&&问号标志
	LOCAL m.c	&&括号标志（左+、右-）
	LOCAL m.d	&&问号表达式（当前）
	LOCAL m.e	&&当前字符
	LOCAL cReturnSQL
	cReturnSQL=""
	LOCAL m.c,m.e
	m.a=0
	m.b=.f.
	m.c=0
	m.d=""
	m.e=""
	*!*处理GO语句
	LOCAL cGOSQL
	cGOSQL=""
	DO WHILE LEN(__cSQL)>0
		LOCAL nPos
		nPos=AT("G"+"O",UPPER(__cSQL))
		IF nPos>0
			LOCAL s
			s=LEFT(__cSQL,nPos-1)
			DO WHILE LEN(s)>0
				cGOSQL = cGOSQL + LEFT(s,1024*1024)
				s=SUBSTR(s,1024*1024+1)
			ENDDO

			__cSQL=SUBSTR(__cSQL,nPos)
			*验证是不是合法的GO语句
			LOCAL nChar1,nChar2
			nChar1=ASC(RIGHT(cGOSQL,1))
			nChar2=ASC(SUBSTR(__cSQL,3,1))
			IF INLIST(nChar1,0,13,10,9,32) AND INLIST(nChar2,0,13,10,9,32) AND MOD(OCCURS("'",cGOSQL),2)=0
				cGOSQL = cGOSQL + "&exec_now;"
			ELSE
				*不是合法的GO语句，继续
				cGOSQL = cGOSQL + LEFT(__cSQL,2)
			ENDIF
			__cSQL=SUBSTR(__cSQL,3)
		ELSE
			DO WHILE LEN(__cSQL)>0
				cGOSQL = cGOSQL + LEFT(__cSQL,1024*1024)
				__cSQL=SUBSTR(__cSQL,1024*1024+1)
			ENDDO
		ENDIF
	ENDDO
	__cSQL=cGOSQL
	*!*处理问号表达式
	LOCAL nAtCount,nPos
	nAtCount=1
	nPos=1
	DO WHILE nPos<=LEN(__cSQL)
		LOCAL nPos1
		nPos1=AT("?",__cSQL,nAtCount )
		IF nPos1>0
			nAtCount = nAtCount + 1
			*!*看一下问号是不是在引号内
			LOCAL nQCount
			nQCount=OCCURS("'",LEFT(__cSQL,nPos1-1))
			IF MOD(nQCount,2)=0
				*!*问号在引号外，解析
				*!*记录问号之前的字符串
				cReturnSQL = cReturnSQL + SUBSTR(__cSQL,nPos,nPos1-nPos)
				nPos=nPos1+1
				*!*解析问号
				m.c=0	&&设置括号标记
				m.d=""	&&设置问号表达式
				b=.t.	&&设置问号标记
				DO WHILE nPos<=LEN(__cSQL)
					m.e=SUBSTR(__cSQL,nPos,1)
					IF ISLEADBYTE(m.e)
						m.e=SUBSTR(__cSQL,nPos,2)
						nPos = nPos + 2
					ELSE
						nPos = nPos + 1
					ENDIF
					*看看是不是碰到除了括号之外的分隔符,看看是不是有未完结括号
					If Inlist(m.e,"+","-","*","/"," ",",",">","<","=","~","%",")",Chr(10),Chr(13),Chr(10)+Chr(13),Chr(32),Chr(9),Chr(0)) AND m.c=0 AND SUBSTR(__cSQL,nPos,1)<>"."
						*括号已完结
						*解析表达式
						cReturnSQL = cReturnSQL + ParseExprValue(m.d) + m.e
						*清除问号标志
						m.b=.f.
						m.d=""
						*跳出
						EXIT
					ELSE
						DO CASE
							CASE m.e=="("
								m.c = m.c + 1
							CASE m.e==")" AND m.c>0
								m.c = m.c - 1
							OTHERWISE
								*不作任何处理
						ENDCASE
						m.d = m.d + m.e	&&问号表达式构造中
					ENDIF
				ENDDO
				*如果没有遇到分隔符但是字符串已经结束
				IF m.b AND LEN(m.d)>0
					cReturnSQL = cReturnSQL + ParseExprValue(m.d)
				ENDIF
				*!*记录问号之后的字符串
			ELSE
				*!*问号在引号内，不处理
			ENDIF
		ELSE
			LOCAL s
			s=SUBSTR(__cSQL,nPos)
			DO WHILE LEN(s)>0
				cReturnSQL = cReturnSQL + LEFT(s,1024*1024)
				s=SUBSTR(s,1024*1024+1)
			ENDDO

			nPos=LEN(__cSQL)+1
		ENDIF
	ENDDO
	RETURN cReturnSQL
ENDPROC



Procedure ParseExprValue
	Lparameters m.__cInputExpr
	If Vartype(m.__cInputExpr)<>"C" Or Empty(m.__cInputExpr)
		Return ""
	ENDIF
	IF TYPE("_VFP.ActiveForm")="O"
		m.__cInputExpr=STRTRAN(m.__cInputExpr,"this.","thisform.",-1,-1,1)
		m.__cInputExpr=STRTRAN(m.__cInputExpr,"thisform.","_VFP.ActiveForm.",-1,-1,1)
	ENDIF
	*Local m.__vInputExprValue
	TRY
		m.__vInputExprValue=Evaluate(m.__cInputExpr)
	CATCH TO oErr
	ENDTRY
	If VARTYPE(m.__vInputExprValue)="U"
		Local m.__cUserInputValue
		If Left(m.__cInputExpr,3)="_c_"
			m.__cUserInputValue=InputBox1("请为参数【"+Substr(m.__cInputExpr,4)+"】输入值：","输入参数值","")
			m.__cUserInputValue="'"+m.__cUserInputValue+"'"
			RETURN m.__cUserInputValue
		Else
			m.__cUserInputValue=InputBox1("请为参数【"+m.__cInputExpr+"】输入值：","输入参数值","")
			LOCAL bIsNumeric
			bIsNumeric=.t.
			FOR x=1 TO LEN(m.__cUserInputValue)
				IF !ISDIGIT(SUBSTR(m.__cUserInputValue,x,1))
					bIsNumeric=.f.
					EXIT
				ENDIF
			ENDFOR
			IF bIsNumeric
				RETURN m.__cUserInputValue
			ELSE
				RETURN "'"+m.__cUserInputValue+"'"
			ENDIF
		ENDIF
	Else
		*m.__vInputExprValue=Evaluate(m.__cInputExpr)
		Do Case
			Case Vartype(m.__vInputExprValue)="C" Or Vartype(m.__vInputExprValue)="M"
				m.__vInputExprValue=Strtran(m.__vInputExprValue,"?","[@@]")
				m.__vInputExprValue=Strtran(m.__vInputExprValue,"'","''")
				If Left(m.__vInputExprValue,11)="(%NotChar%)"
					m.__vInputExprValue=Substr(m.__vInputExprValue,12)
				Else
					m.__vInputExprValue="'"+Rtrim(m.__vInputExprValue)+"'"
				ENDIF

				RETURN m.__vInputExprValue
			Case INLIST(Vartype(m.__vInputExprValue),"D","T")
				If m.__vInputExprValue={}
					Return "null"
				ELSE
					LOCAL cDateString
					m.cDateString=TTOC(m.__vInputExprValue,3)
					m.cDateString=GETWORDNUM(m.cDateString,1,"T")+" "+GETWORDNUM(m.cDateString,2,"T")
					Return "cast('"+m.cDateString+"' as datetime)"
				Endif
			Case Vartype(m.__vInputExprValue)="L"
				Return Iif(m.__vInputExprValue,"1","0")
			Case Vartype(m.__vInputExprValue)="N"
				Return Transform(m.__vInputExprValue)
			Case Vartype(m.__vInputExprValue)="Y"
				Return Transform(Mton(m.__vInputExprValue))
			Case Vartype(m.__vInputExprValue)="Q"
				Return "0x"+Strconv(m.__vInputExprValue,15)
			Otherwise
				Return Transform(Nvl(m.__vInputExprValue,"null"))
		Endcase
	Endif

Endproc


*!*查询数据
Procedure SelectData
	Lparameter cSqlCmd,cAliasName,cServer,cUserID,cPassword,cDatabase,bLoginSecure
	If Vartype(cSqlCmd)<>"C" Or Empty(cSqlCmd)
		Return .F.
	Endif
	If Vartype(cSqlCmd)<>"C" Or Empty(cSqlCmd)
		Return .F.
	ENDIF
	
	Select 0
	LOCAL cAddonSQL,cAddonSQL2
	TEXT TO cAddonSQL NOSHOW TEXTMERGE 
	IF exists(select * from sysobjects where id=object_id('WiseMis_UserOnline') AND ObjectProperty(id,'IsUserTable')=1)
	BEGIN
		DELETE FROM WiseMis_UserOnline where spid=@@spid
		INSERT INTO WiseMis_UserOnline(spid,UserName) VALUES (@@spid,'<<_screen.cUserName>>')
	END
	ENDTEXT 
	TEXT TO cAddonSQL2 NOSHOW TEXTMERGE 
	IF exists(select * from sysobjects where id=object_id('WiseMis_UserOnline') AND ObjectProperty(id,'IsUserTable')=1)
	BEGIN
		DELETE FROM WiseMis_UserOnline where spid=@@spid
	END
	ENDTEXT 
	cSqlCmd=cAddonSQL+CHR(13)+CHR(10)+cSqlCmd+CHR(13)+CHR(10)+cAddonSQL2
	cSqlCmd=ParseSQL(cSqlCmd)
	If nSQLHandle<=0
		nSQLHandle=Connect(cServer,cUserID,cPassword,cDatabase,bLoginSecure)
		IF nSQLHandle<=0
			RETURN .f.
		ENDIF
	ENDIF

	=SQLSETPROP(nSQLHandle,"BatchMode",.f.)

	DO WHILE SQLMORERESULTS(nSQLHandle)=1
	ENDDO

	If Vartype(cAliasName)<>"C" Or Empty(cAliasName)
		cAliasName=Sys(2015)
	Endif
	If Parameters()<7
		bLoginSecure=_Screen.bLoginSecure
	ENDIF

	LOCAL nCurrentCursor
	nCurrentCursor=1
	LOCAL cCurrentCursor
	cCurrentCursor=GETWORDNUM(cAliasName,1,",")

	Local cErrorMessage

	LOCAL bPreparedSQL

	If nSQLHandle>0
		Local cSql
		Local cPreparedSql , nGoPos
		cPreparedSql=cSqlCmd
		Do While Len(cPreparedSql) > 0
			nGoPos = At("&" + "e" + "x" + "e" + "c" + "_" + "n" + "o" + "w" + ";",cPreparedSql)
			If nGoPos > 0
				cSql = Left(cPreparedSql,nGoPos - 1)
				cPreparedSql = Substr(cPreparedSql,nGoPos + 10)
			Else
				cSql = cPreparedSql
				cPreparedSql = ""
			Endif

			cSql=STRTRAN(cSql,"[@@]","?")
			cSql=STRTRAN(cSql,"{##}",CHR(13)+CHR(10)+"GO",-1,-1,1)
			_screen.cLastSQL=cSql
			DO WHILE SQLMORERESULTS(nSQLHandle)=1
			ENDDO
			IF LEN(cSql)>1024
				= SQLPrepare(nSQLHandle,cSql,cCurrentCursor)
				nCursorCount = SQLExec(nSQLHandle)
				If nCursorCount < 1
					IF _screen.IsDebug
						_cliptext=cSql
					ENDIF
					cErrorMessage=Format_Error()
					Error cErrorMessage
					=SQLIdleDisconnect(nSQLHandle)
					*=Disconnect()
					Return .F.
				Endif
			ELSE
				nCursorCount = SQLExec(nSQLHandle,cSql,cCurrentCursor)
				If nCursorCount < 1
					IF _screen.IsDebug
						_cliptext=cSql
					ENDIF
					cErrorMessage=Format_Error()
					Error cErrorMessage
					=SQLIdleDisconnect(nSQLHandle)
					*=Disconnect()
					Return .F.
				Endif
			ENDIF
			IF SELECT(cCurrentCursor)>0
				nCurrentCursor = nCurrentCursor + 1
			ENDIF
			DO WHILE .t.
				LOCAL cTempAliasName
				cTempAliasName=GETWORDNUM(cAliasName,nCurrentCursor,",")
				LOCAL nResult
				nResult=SQLMORERESULTS(nSQLHandle,cTempAliasName)
				DO CASE
					CASE nResult<1
						IF _screen.IsDebug
							_cliptext=cSql
						ENDIF
						cErrorMessage=Format_Error()
						Error cErrorMessage
						=SQLIdleDisconnect(nSQLHandle)
						*=Disconnect()
						Return .F.
					CASE nResult=2
						EXIT
					OTHERWISE

				ENDCASE
				IF SELECT(cTempAliasName)>0
					nCurrentCursor = nCurrentCursor + 1
				ENDIF
			ENDDO
		Enddo
		=SQLIdleDisconnect(nSQLHandle)
		*=Disconnect()
	Else
		Return .F.
	ENDIF

	Return .T.
Endproc


*!*返回单个值
Procedure GetValue
	Lparameters cSqlCmd,cServer,cUserID,cPassword,cDatabase,bLoginSecure
	LOCAL cPreCursor
	cPreCursor=ALIAS()

	Local __cTempCursor
	__cTempCursor=Sys(2015)
	IF AT("?",cSqlCmd)>0
		cSqlCmd=ParseSql(cSqlCmd)
	ENDIF

	Local __vReturnValue
	__vReturnValue=null

	If SelectData(cSqlCmd,__cTempCursor,cServer,cUserID,cPassword,cDatabase,bLoginSecure)
		IF SELECT(__cTempCursor)>0
			Select (__cTempCursor)
			If Reccount()>0
				__vReturnValue=Evaluate(Field(1))
			Endif
			=CloseAlias(__cTempCursor)
		ENDIF
	ENDIF

	IF SELECT(cPreCursor)>0
		SELECT (cPreCursor)
	ENDIF

	Return __vReturnValue
Endproc

*!*关闭游标
Procedure CloseAlias
	Lparameter __cAliasList As String
	If Vartype(__cAliasList) <> "C" Or Empty(__cAliasList)
		Return
	Endif
	Local __nAliasCount , __cAlias
	__nAliasCount =  Getwordcount (__cAliasList,",")
	For __nAlias = 1 To __nAliasCount
		__cAlias =  Getwordnum (__cAliasList,__nAlias,",")
		If Select(__cAlias) > 0
			Select (__cAlias)
			Use
		Endif
	Endfor
ENDPROC