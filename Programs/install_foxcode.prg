set path to other
set library to MyFll
=FllAddFoxCode()
SELECT 0
IF SELECT("foxcode")=0
	USE (_FOXCODE) SHARED ALIAS foxcode
ENDIF 
SELECT foxcode

SELECT 0
USE my_foxcode
SELECT my_foxcode
SCAN
	LOCAL cAbbrev,cExpanded,cTip
	cAbbrev=ALLTRIM(��д)
	cExpanded=ALLTRIM(ȫ��)
	cTip=ALLTRIM(��ʾ)
	SELECT foxcode
	LOCATE FOR Type="F" AND ALLTRIM(LOWER(Expanded))=LOWER(cExpanded)
	IF !FOUND()
		APPEND BLANK
	ENDIF 
	REPLACE Type WITH "F",Abbrev WITH cAbbrev,Expanded WITH cExpanded,Tip WITH cTip
	SELECT my_foxcode
ENDSCAN 
SELECT my_foxcode
USE 
SELECT foxcode
USE 


QUIT 