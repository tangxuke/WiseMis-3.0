PROCEDURE ToEnglish
	LPARAMETERS cStrings,m.fromDB as Boolean
	IF _screen.nLanguage=1
		RETURN cStrings
	ENDIF 
	IF EMPTY(cStrings) OR VARTYPE(cStrings)<>"C"
		RETURN ""
	ENDIF 
	
	LOCAL s,s1,s2
	STORE "" TO s,s1,s2
	s=ALLTRIM(cStrings)
	s1=STRTRAN(RTRIM(cStrings),s,"")
	s2=STRTRAN(LTRIM(cStrings),s,"")
	cStrings=s
	
	IF OCCURS("\<",cStrings)=1
		LOCAL c1,c2,c3
		c1=GETWORDNUM(cStrings,1,"\<")
		c2=GETWORDNUM(cStrings,2,"\<")
		c3=ToEnglish(c1,m.fromDB)+"\<"+c2
		RETURN c3
	ENDIF 
		
	cStrings=STRTRAN(cStrings,"��",":")
	cStrings=STRTRAN(cStrings,"��","(")
	cStrings=STRTRAN(cStrings,"��",")")
	cStrings=STRTRAN(cStrings,"����","...")
	cStrings=STRTRAN(cStrings,"��",",")
	cStrings=STRTRAN(cStrings,"��",".")
	cStrings=STRTRAN(cStrings,"��","[")
	cStrings=STRTRAN(cStrings,"��","]")
	
	cStrings=ALLTRIM(cStrings)
	
	LOCAL cReturns,cWord
	cReturns=""
	cWord=""
	DO WHILE LENC(cStrings)>0
		IF !INLIST(SUBSTRC(cStrings,1,1),"0","1","2","3","4","5","6","7","8","9") AND !INLIST(SUBSTRC(cStrings,1,1),".",",","(",")","[","]",":","%","+","-","*","/","!","&","#","@","$","^","\","<",">","{","}")
			cWord = cWord + SUBSTRC(cStrings,1,1)
		ELSE 
			IF !EMPTY(cWord)
*!*					IF !EMPTY(cReturns)
*!*						cReturns = cReturns + " "
*!*					ENDIF 
				cReturns = cReturns + ToEnglish2(cWord,m.fromDB)
				IF LEN(cStrings)>1 AND INLIST(SUBSTRC(cStrings,1,1),"0","1","2","3","4","5","6","7","8","9")
					cReturns = cReturns + " "
				ENDIF 
				cWord=""
			ENDIF 
			cReturns = cReturns + SUBSTRC(cStrings,1,1)
		ENDIF 
		cStrings=SUBSTRC(cStrings,2)
	ENDDO
	IF !EMPTY(cWord)
		IF !EMPTY(cReturns)
			cReturns = cReturns + " "
		ENDIF 
		cReturns = cReturns + ToEnglish2(cWord,m.fromDB)
	ENDIF 
	
	cReturns=s1+cReturns+s2
	
	RETURN cReturns 
ENDPROC 



PROCEDURE ToEnglish2
	LPARAMETERS m.cChineseString,m.fromDB as Boolean
		
	LOCAL m.cPreAlias
	m.cPreAlias=ALIAS()
		
	LOCAL m.cReturnString
	IF m.fromDB
		SELECT (_screen.cAlias_Language)
	ELSE
		LOCAL cLanguageFile
		cLanguageFile=ADDBS(ParsePath("{app}"))+"Language1.dbf"
		IF !FILE(cLanguageFile)
			SELECT 0
			CREATE TABLE (cLanguageFile)(zh C(250),en C(250),jp C(250))
			USE 
		ENDIF 
		IF !USED("Language")
			SELECT 0
			USE (cLanguageFile) ALIAS Language SHARED
		ENDIF 
		SELECT Language
	ENDIF 
	
	
	GOTO TOP 
	LOCAL cLanguageCode
	DO CASE
	CASE _screen.nLanguage=2
		cLanguageCode="en"	&&Ӣ��
	CASE _screen.nLanguage=3
		cLanguageCode="jp"	&&����
	OTHERWISE
		cLanguageCode="zh"	&&����
	ENDCASE		
	LOCATE FOR (ALLTRIM(LOWER(zh))==ALLTRIM(LOWER(m.cChineseString)) OR ALLTRIM(LOWER(en))==ALLTRIM(LOWER(m.cChineseString)) OR ALLTRIM(LOWER(jp))==ALLTRIM(LOWER(m.cChineseString)))
	LOCAL bFound1,bFound2
	IF FOUND()
		bFound1=.t.
		IF !EMPTY(NVL(&cLanguageCode,""))
			bFound2=.t.
			m.cReturnString=ALLTRIM(&cLanguageCode)
		ENDIF 
	ENDIF 
	IF !bFound2
		IF _screen.nLanguage<>1
			LOCAL m.cUrl,m.cInput,m.cResult
			m.cUrl="http://api.fanyi.baidu.com/api/trans/vip/translate"
			LOCAL m.Q,m.cAppId,m.cSalt,m.cKey,m.cSign
			m.cSalt=TRANSFORM(INT(10000*RAND()))
			m.cAppId="20170214000039084"
			m.Q=STRCONV(m.cChineseString,9)
			m.cKey="8sCv5gYH4ZtXE0Es61hL"
			m.cSign=LOWER(MD5String(m.cAppId+m.Q+m.cSalt+m.cKey))
			m.cInput="q="+URLEncode(m.Q)+"&from=auto&to="+cLanguageCode+"&appid="+m.cAppId+"&salt="+m.cSalt+"&sign="+m.cSign
			
			m.cResult=GetHttpServiceString(m.cUrl,m.cInput)
			TRY 
			LOCAL oJson
			oJson=foxJson_Parse(m.cResult)
			m.cReturnString=oJson("trans_result").item(1).item("dst")
			CATCH 
				
			ENDTRY 
			IF EMPTY(m.cReturnString)
				IF SELECT(m.cPreAlias)>0
					SELECT (m.cPreAlias)
				ENDIF 
				RETURN m.cChineseString
			ENDIF 
			
			IF m.fromDB
				LOCAL m.cSQL
				TEXT TO m.cSQL NOSHOW TEXTMERGE 
				IF NOT exists(select * from WiseMis_Language where zh='<<STRTRAN(m.cChineseString,"'","''")>>')
					INSERT INTO WiseMis_Language(zh,<<cLanguageCode>>) VALUES ('<<STRTRAN(m.cChineseString,"'","''")>>','<<STRTRAN(m.cReturnString,"'","''")>>')
				ELSE
					UPDATE WiseMis_Language SET [<<cLanguageCode>>]='<<STRTRAN(m.cReturnString,"'","''") where [zh]='<<STRTRAN(m.cChineseString,"'","''")>>'
				ENDTEXT 
				=Execute(m.cSQL)
				SELECT (_screen.cAlias_Language)
			ELSE
				SELECT Language
			ENDIF
			IF !bFound1 
				APPEND BLANK
				REPLACE zh WITH m.cChineseString,&cLanguageCode WITH cReturnString
			ELSE
				REPLACE &cLanguageCode WITH cReturnString
			ENDIF 
		ELSE
			m.cReturnString=m.cChineseString
		ENDIF 
	ENDIF 
	
	IF SELECT(m.cPreAlias)>0
		SELECT (m.cPreAlias)
	ENDIF 
	
	IF _screen.nLanguage=2
		m.cReturnString=UPPER(SUBSTR(m.cReturnString,1,1))+SUBSTR(m.cReturnString,2)
	ENDIF 
	
	
	RETURN m.cReturnString
ENDPROC