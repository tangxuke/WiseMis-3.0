*!*连接数据库
Procedure Connect
	Lparameters cServer,cDatabase,cUserName,cPassword
	IF VARTYPE(cServer)<>"C" OR EMPTY(cServer)
		cServer=_screen.cServer
	ENDIF 
	IF VARTYPE(cDatabase)<>"C" OR EMPTY(cDatabase)
		cDatabase=_screen.cDatabase
	ENDIF 
	IF VARTYPE(cUserName)<>"C" OR EMPTY(cUserName)
		cUserName="WiseMisAdmin"
	ENDIF 
	IF VARTYPE(cPassword)<>"C" OR EMPTY(cPassword)
		cPassword="hlh***TXK0921"
	ENDIF 

	Local nSqlHandle
	nSqlHandle=0

	Local strConn
	strConn = "Driver={SQL Server};Server=" + cServer + ";database=" + cDatabase + ";uid="+cUserName+";pwd="+cPassword

	strConn = strConn + ";APP=WiseMis New Update"
	=SQLSETPROP(0,"DispLogin",3)
	
	=SQLSETPROP(0,"DispWarnings",_screen.bDebugMode)
	=CURSORSETPROP("MapBinary",.t.,0)
	=CURSORSETPROP("MapVarchar",.t.,0)
	nSqlHandle= Sqlstringconnect(strConn)
	
	Return nSqlHandle
Endproc

*!*执行命令
Procedure Execute
	Lparameter cSqlCmd,cServer,cDatabase,cUserName,cPassword
	If Vartype(cSqlCmd)<>"C" Or Empty(cSqlCmd)
		Return .F.
	ENDIF
	
	cSqlCmd=ParseSQL(cSqlCmd)
	Local nSqlHandle
	nSqlHandle=Connect(cServer,cDatabase,cUserName,cPassword)
	IF nSqlHandle<=0
		RETURN .f.
	ENDIF
	
	=SQLEXEC(nSqlHandle,"delete from WiseMis_UserOnline where spid=@@spid"+CHR(13)+CHR(10)+"insert into WiseMis_UserOnline(spid,UserName) values (@@spid,'WiseMis')")

	=SQLSETPROP(nSqlHandle,"BatchMode",.t.)

	LOCAL bPreparedSQL

	If nSqlHandle>0
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
			DO WHILE SQLMORERESULTS(nSqlHandle)=1
			ENDDO
			IF LEN(cMySql)>1024
				= SQLPrepare(nSqlHandle,cMySql)
				If SQLExec(nSqlHandle) < 1
					=SQLDISCONNECT(nSqlHandle)
					Return .F.
				Endif
			ELSE
				If SQLExec(nSqlHandle,cMySql) < 1
					=SQLDISCONNECT(nSqlHandle)
					Return .F.
				Endif
			ENDIF
			DO WHILE SQLMORERESULTS(nSqlHandle)=1
			ENDDO
		ENDDO
		=SQLDISCONNECT(nSqlHandle)
	Else
		Return .F.
	Endif
	Return .T.
Endproc



*!*查询数据
Procedure SelectData
	Lparameter cSqlCmd,cAliasName,cServer,cDatabase,cUserName,cPassword
	If Vartype(cSqlCmd)<>"C" Or Empty(cSqlCmd)
		Return .F.
	ENDIF
	cSqlCmd=ParseSQL(cSqlCmd)
	Local nSqlHandle
	nSqlHandle=Connect(cServer,cDatabase,cUserName,cPassword)
	IF nSqlHandle<=0
		RETURN .f.
	ENDIF

	=SQLSETPROP(nSqlHandle,"BatchMode",.f.)

	DO WHILE SQLMORERESULTS(nSqlHandle)=1
	ENDDO

	If Vartype(cAliasName)<>"C" Or Empty(cAliasName)
		cAliasName=Sys(2015)
	Endif

	LOCAL nCurrentCursor
	nCurrentCursor=1
	LOCAL cCurrentCursor
	cCurrentCursor=GETWORDNUM(cAliasName,1,",")

	Select 0
	Local cErrorMessage

	LOCAL bPreparedSQL

	If nSqlHandle>0
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
			cSQL="/*exec sp_setapprole '',''*/"+Chr(13)+Chr(10)+cSQL

			DO WHILE SQLMORERESULTS(nSqlHandle)=1
			ENDDO
			IF LEN(cSql)>1024
				= SQLPrepare(nSqlHandle,cSql,cCurrentCursor)
				nCursorCount = SQLExec(nSqlHandle)
				If nCursorCount < 1
					=SQLDISCONNECT(nSqlHandle)
					Return .F.
				Endif
			ELSE
				nCursorCount = SQLExec(nSqlHandle,cSql,cCurrentCursor)
				If nCursorCount < 1
					=SQLDISCONNECT(nSqlHandle)
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
				nResult=SQLMORERESULTS(nSqlHandle,cTempAliasName)
				DO CASE
					CASE nResult<1
						=SQLDISCONNECT(nSqlHandle)
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
		=SQLIdleDisconnect(nSqlHandle)
	Else
		Return .F.
	ENDIF

	Return .T.
Endproc

*!*返回单个值
Procedure GetValue
	Lparameters cSqlCmd,cServer,cDatabase,cUserName,cPassword
	LOCAL cPreCursor
	cPreCursor=ALIAS()

	Local __cTempCursor
	__cTempCursor=Sys(2015)

	Local __vReturnValue
	__vReturnValue=null

	If SelectData(cSqlCmd,__cTempCursor,cServer,cDatabase,cUserName,cPassword)
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



PROCEDURE ParseSQL
	LPARAMETERS __cSQL as String,bPrepExec as Boolean
	IF VARTYPE(bPrepExec)<>"L"
		bPrepExec=.f.
	ENDIF
	LOCAL a	&&单引号标志
	LOCAL b	&&问号标志
	LOCAL c	&&括号标志（左+、右-）
	LOCAL d	&&问号表达式（当前）
	LOCAL e	&&当前字符
	LOCAL cReturnSQL
	cReturnSQL=""
	LOCAL c,e
	a=0
	b=.f.
	c=0
	d=""
	e=""
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
				c=0	&&设置括号标记
				d=""	&&设置问号表达式
				b=.t.	&&设置问号标记
				DO WHILE nPos<=LEN(__cSQL)
					e=SUBSTR(__cSQL,nPos,1)
					IF ISLEADBYTE(e)
						e=SUBSTR(__cSQL,nPos,2)
						nPos = nPos + 2
					ELSE
						nPos = nPos + 1
					ENDIF
					*看看是不是碰到除了括号之外的分隔符,看看是不是有未完结括号
					If Inlist(e,"+","-","*","/"," ",",",">","<","=","~","%",")",Chr(10),Chr(13),Chr(10)+Chr(13),Chr(32),Chr(9),Chr(0)) AND c=0 AND SUBSTR(__cSQL,nPos,1)<>"."
						*括号已完结
						*解析表达式
						cReturnSQL = cReturnSQL + ParseExprValue(d) + e
						*清除问号标志
						b=.f.
						d=""
						*跳出
						EXIT
					ELSE
						DO CASE
							CASE e=="("
								c = c + 1
							CASE e==")" AND c>0
								c = c - 1
							OTHERWISE
								*不作任何处理
						ENDCASE
						d = d + e	&&问号表达式构造中
					ENDIF
				ENDDO
				*如果没有遇到分隔符但是字符串已经结束
				IF b AND LEN(d)>0
					cReturnSQL = cReturnSQL + ParseExprValue(d)
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
		RETURN "null"
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