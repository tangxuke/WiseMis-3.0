LPARAMETERS cFormName,nParamCount,vParam1,vParam2,vParam3,vParam4,vParam5
IF VARTYPE(cFormName)<>"C"
	RETURN .f.
ENDIF 
IF VARTYPE(nParamCount)<>"N"
	nParamCount=0
ENDIF 

DO CASE
CASE nParamCount=0
	DO FORM &cFormName
CASE nParamCount=1
	DO FORM &cFormName WITH vParam1
CASE nParamCount=2
	DO FORM &cFormName WITH vParam1,vParam2
CASE nParamCount=3
	DO FORM &cFormName WITH vParam1,vParam2,vParam3
CASE nParamCount=4
	DO FORM &cFormName WITH vParam1,vParam2,vParam3,vParam4
CASE nParamCount=5
	DO FORM &cFormName WITH vParam1,vParam2,vParam3,vParam4,vParam5
OTHERWISE

ENDCASE