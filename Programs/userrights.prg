PROCEDURE GetAppRight
	LPARAMETERS cAppName as String
	IF _screen.IsSysAdmin
		RETURN 255
	ENDIF 
	WITH _screen.oAppRights as Collection
		IF .GetKey(ALLTRIM(LOWER(cAppName)))=0
			RETURN 0
		ELSE
			RETURN .Item(ALLTRIM(LOWER(cAppName)))
		ENDIF 
	ENDWITH 
ENDPROC 

PROCEDURE GetAppRule
	LPARAMETERS cAppName as String
	IF _screen.IsSysAdmin
		RETURN ""
	ENDIF 
	WITH _screen.oAppRules as Collection
		IF .GetKey(ALLTRIM(LOWER(cAppName)))=0
			RETURN ""
		ELSE
			RETURN .Item(ALLTRIM(LOWER(cAppName)))
		ENDIF 
	ENDWITH 
ENDPROC 

PROCEDURE GetAppFieldRight
	LPARAMETERS cAppName as String,cFieldName as String
	IF _screen.IsSysAdmin
		RETURN 3
	ENDIF 
	LOCAL nAppRight,nFieldRight
	nAppRight=GetAppRight(cAppName)
	nFieldRight=0
	IF BITTEST(nAppRight,1)
		nFieldRight=BITSET(nFieldRight,0)
	ENDIF 
	IF BITTEST(nAppRight,3)
		nFieldRight=BITSET(nFieldRight,1)
	ENDIF 
	WITH _screen.oAppFieldRights as Collection
		IF .GetKey(ALLTRIM(LOWER(cAppName))+"_"+ALLTRIM(LOWER(cFieldName)))=0
			RETURN nFieldRight
		ELSE
			RETURN .Item(ALLTRIM(LOWER(cAppName))+"_"+ALLTRIM(LOWER(cFieldName)))
		ENDIF 
	ENDWITH 
ENDPROC 

PROCEDURE GetAppTaskRight
	LPARAMETERS nTaskId as Integer
	IF _screen.IsSysAdmin
		RETURN 1
	ENDIF  
	WITH _screen.oAppTaskRights as Collection
		IF .GetKey(TRANSFORM(nTaskId))=0
			RETURN 0
		ELSE
			RETURN .Item(TRANSFORM(nTaskId))
		ENDIF 
	ENDWITH 
ENDPROC 