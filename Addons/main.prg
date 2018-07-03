LPARAMETERS cFormName as String
IF VARTYPE(cFormName)<>"C"
	cFormName=""
ENDIF 
IF EMPTY(cFormName)
	RETURN .f.
ENDIF 
SET CLASSLIB TO Addons ADDITIVE 
DO FORM (cFormName)