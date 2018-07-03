*!*����Ӧ�÷�����־����
PROCEDURE CreateAppLogObject
	LPARAMETERS cAppName as String
	LOCAL oLogAppObject as AppObject
	oLogAppObject=CreateAppObject(cAppName)
	oLogAppObject.cBaseTable = oLogAppObject.cBaseTable + "_Log"
ENDPROC 
*!*����Ӧ�÷�������
Procedure CreateAppObject
	Lparameters cAppName As String
	LOCAL nStartSecond
	nStartSecond=SECONDS()

	LOCAL oAppObject As AppObject
	*!* ����Ӧ�÷�������
	Local oAppObject As AppObject
	m.oAppObject=Createobject("AppObject")

	LOCAL cCursor1,cCursor2,cCursor3,cCursor4,cCursor5,cCursor6,cCursor7,cCursor8,cCursor9,cCursor10
	cCursor1=SYS(2015)
	cCursor2=SYS(2015)
	cCursor3=SYS(2015)
	cCursor4=SYS(2015)
	cCursor5=SYS(2015)
	cCursor6=SYS(2015)
	cCursor7=SYS(2015)
	cCursor8=SYS(2015)
	cCursor9=SYS(2015)
	cCursor10=SYS(2015)
	LOCAL cCursorList
	cCursorList=cCursor1+","+cCursor2+","+cCursor3+","+cCursor4+","+cCursor5+","+cCursor6+","+cCursor7+","+cCursor8+","+cCursor9+","+cCursor10
	*!*��ȡ����
	LOCAL cSQL
	cSQL="exec WiseMis_RefreshAppInfo_RuntimeMode '"+cAppName+"'"

	IF !SelectData(cSQL,cCursorList)
		MessageBox1("��ȡӦ�÷�����Ϣʧ�ܣ�",0+64,"ϵͳ��ʾ")
		RETURN .f.
	ENDIF

	SELECT (cCursor1)

	m.oAppObject.LoadFromCursor()

	*!* ����Ӧ�÷����ֶ�
	Local oFieldObjects As Collection
	oFieldObjects=m.oAppObject.oFieldObjects
	SELECT (cCursor2)
	LOCAL nFieldID
	nFieldID=0

	SCAN FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName))
		Local oFieldObject As AppFieldObject
		oFieldObject=Createobject("AppFieldObject")
		oFieldObject.oAppObject=m.oAppObject
		nFieldID = nFieldID + 1
		oFieldObject.LoadFromCursor()
		oFieldObject.F2="V_"+oFieldObject.cFieldName+"_C"
		IF !EMPTY(NVL(FieldType_SQL,""))
			Local oUserRightObject As AppUserRightObject
			oUserRightObject=Createobject("AppUserRightObject")
			oUserRightObject.oAppObject=m.oAppObject
			oUserRightObject.cFieldName=oFieldObject.cFieldName
			oUserRightObject.cFieldType=ALLTRIM(FieldType_SQL)
			oUserRightObject.nFieldLength=FieldPrec_SQL &&FieldLength_SQL
			oUserRightObject.nFieldPrec=FieldPrec_SQL
			oUserRightObject.nFieldScale=FieldScale_SQL
			WITH oAppObject.oUserRightObjects as Collection
				.Add(oUserRightObject,Lower(oUserRightObject.cFieldName))
			ENDWITH
			oFieldObject.oUserRightObject=oUserRightObject
		ENDIF


		oFieldObject.SetFieldType()
		IF oFieldObject.bSelectRight
			oFieldObjects.Add(oFieldObject,UPPER(oFieldObject.cFieldName))
		ENDIF 
	ENDSCAN

	*!*����Ӧ�÷����ֶνű�
	SELECT (cCursor3)
	SCAN FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName))
		LOCAL oFieldObject as AppFieldObject
		oFieldObject=m.oAppObject.GetFieldObject(Alltrim(FieldName))
		LOCAL oFieldScriptObject as AppFieldScriptObject
		oFieldScriptObject=CREATEOBJECT("AppFieldScriptObject")
		oFieldScriptObject.LoadFromCursor()
		WITH oFieldObject.oFieldScriptObjects as Collection
			.Add(oFieldScriptObject,oFieldScriptObject.cScriptName)
		ENDWITH
	ENDSCAN

	*!*���������ֶ�
	LOCAL cOrderExpr
	cOrderExpr=""
	LOCAL cOrderTempCursor
	cOrderTempCursor=SYS(2015)
	SELECT 0
	SELECT FieldName,IsDesc FROM (cCursor2) WHERE ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName)) AND NVL(IsOrder,.f.) ORDER BY OrderId INTO CURSOR (cOrderTempCursor)
	Select (cOrderTempCursor)
	SCAN
		cOrderExpr = cOrderExpr + IIF(EMPTY(cOrderExpr),"",",") + Alltrim(FieldName) + IIF(IsDesc," desc","")
	ENDSCAN
	=CloseAlias(cOrderTempCursor)
	m.oAppObject.cOrderExpr=cOrderExpr

	*!* ����Ӧ�÷�����ϵ
	Local oRelationObjects As Collection
	oRelationObjects=m.oAppObject.oRelationObjects
	SELECT (cCursor4)
	Scan FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName))
		Local oRelationObject As AppRelationObject
		oRelationObject=Createobject("AppRelationObject")
		oRelationObject.oAppObject=m.oAppObject
		oRelationObject.LoadFromCursor()
		oRelationObjects.Add(oRelationObject,oRelationObject.cRelationId)
	Endscan

	*!* ����Ӧ�÷�����������
	Local oWorkflowObjects As Collection
	oWorkflowObjects=m.oAppObject.oWorkflowObjects
	SELECT (cCursor5)
	Scan FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName)) AND (AllowExecute="����" OR _screen.IsSysAdmin)
		Local oWorkflowObject As AppWorkflowObject
		oWorkflowObject=Createobject("AppWorkflowObject")
		oWorkflowObject.oAppObject=m.oAppObject
		oWorkflowObject.LoadFromCursor()
		oWorkflowObjects.Add(oWorkflowObject,oWorkflowObject.cTaskId)
	ENDSCAN

	Local oReportObjects As Collection
	oReportObjects=m.oAppObject.oReportObjects
	*!* ���ر�������Excel������
	SELECT (cCursor7)
	Scan FOR ALLTRIM(LOWER(BaseTable))==ALLTRIM(LOWER(oAppObject.cBaseTable))
		Local oReportObject As AppReportObject
		oReportObject=Createobject("AppReportObject")
		oReportObject.bIsReport=.f.
		oReportObject.cReportName=ALLTRIM(ModalName)
		oReportObject.cCursorList=ALLTRIM(NVL(CursorList,""))
		oReportObject.cRemark=ALLTRIM(NVL(Remark,""))
		oReportObject.oAppObject=m.oAppObject
		oReportObject.cSQLText=ALLTRIM(NVL(SQLText,""))

		oReportObjects.Add(oReportObject,"Excel_"+oReportObject.cReportName)
	ENDSCAN
	*!* ���ر�������VFP������
	SELECT (cCursor10)
	Scan FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName))
		Local oReportObject As AppReportObject
		oReportObject=Createobject("AppReportObject")
		oReportObject.bIsReport=.t.
		oReportObject.cReportName=ALLTRIM(ReportName)
		oReportObject.cCursorList=ALLTRIM(NVL(CursorList,""))
		oReportObject.cRemark=ALLTRIM(NVL(Remark,""))
		oReportObject.oAppObject=m.oAppObject
		oReportObject.cSQLText=ALLTRIM(NVL(SQLText,""))
		oReportObject.cFileData=ALLTRIM(NVL(FileData1,""))
		oReportObject.cFileData2=ALLTRIM(NVL(FileData2,""))

		oReportObjects.Add(oReportObject,"Report_"+oReportObject.cReportName)
	ENDSCAN

	*!*����Excel�������
	SELECT (cCursor8)
	SCAN FOR ALLTRIM(LOWER(BaseTable))==ALLTRIM(LOWER(oAppObject.cBaseTable))
		LOCAL oExcelImportObject as AppExcelImportObject
		oExcelImportObject=CREATEOBJECT("AppExcelImportObject")
		oExcelImportObject.oAppObject=m.oAppObject
		oExcelImportObject.cModalName=ALLTRIM(ModalName)
		oExcelImportObject.cSheetName=ALLTRIM(NVL(SheetName,"Sheet1"))
		oExcelImportObject.nTitleLine=NVL(TitleLine,1)
		oExcelImportObject.nDataLine=NVL(DataLine,2)

		WITH m.oAppObject.oExcelImportObjects as Collection
			.Add(oExcelImportObject,oExcelImportObject.cModalName)
		ENDWITH
	ENDSCAN

	SELECT (cCursor9)
	SCAN FOR ALLTRIM(LOWER(BaseTable))==ALLTRIM(LOWER(oAppObject.cBaseTable))
		LOCAL oExcelImportFieldObject as AppExcelImportFieldObject
		oExcelImportFieldObject=CREATEOBJECT("AppExcelImportFieldObject")
		oExcelImportFieldObject.cSQLField=ALLTRIM(SQLField)
		oExcelImportFieldObject.cExcelField=ALLTRIM(ExcelField)
		oExcelImportFieldObject.bIsKey=NVL(IsKey,.f.)
		oExcelImportFieldObject.bIsInsert=NVL(IsInsert,.f.)
		oExcelImportFieldObject.bIsUpdate=NVL(IsUpdate,.f.)

		LOCAL oExcelImportObject as AppExcelImportObject
		WITH m.oAppObject.oExcelImportObjects as Collection
			IF .GetKey(ALLTRIM(ModalName))>0
				oExcelImportObject=.Item(ALLTRIM(ModalName))
				oExcelImportObject.Add(oExcelImportFieldObject,LOWER(oExcelImportFieldObject.cSQLField))
			ENDIF
		ENDWITH
	ENDSCAN

	*!*���ز�ѯ���ö���
	SELECT (cCursor6)
	SCAN FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(cAppName))
		LOCAL oSearchSchameObject as AppSearchSchameObject
		oSearchSchameObject=CREATEOBJECT("AppSearchSchameObject")
		oSearchSchameObject.cSchameName=ALLTRIM(SchameName)
		oSearchSchameObject.cSearchExpr=ALLTRIM(NVL(SearchExpr,""))

		oSearchSchameObject.oAppObject=m.oAppObject
		WITH m.oAppObject.oSearchSchameObjects as Collection
			.Add(oSearchSchameObject,oSearchSchameObject.cSchameName)
		ENDWITH
	ENDSCAN


	*!* ����Ӧ�÷�������
	m.oAppObject.DoInit()
	*MESSAGEBOX("�������󻨷�ʱ��Ϊ��"+TRANSFORM(SECONDS()-nStartSecond)+"�롣")

	=CloseAlias(cCursorList)

	Return m.oAppObject
ENDPROC

*!*����Ӧ�÷�������ע�ᴰ��
PROCEDURE DoWiseMisApplication2
	Lparameters oAppObject As AppObject,oParams As Collection
	RETURN DoWiseMisApplication(oAppObject,oParams,"","","",.t.)
ENDPROC

*!*����Ӧ�÷���
Procedure DoWiseMisApplication
	Lparameters oAppObject As AppObject,oParams As Collection,cAppClass,cAppClassLibrary,cInApplication,bNoRegisterForm as Boolean
	If Vartype(oAppObject)<>"O"
		MessageBox1("Ӧ�÷������󲻴��ڣ�",0+64,"ϵͳ��ʾ")
		Return null
	ENDIF
	If Vartype(cAppClass)<>"C" Or Empty(cAppClass)
		LOCAL cUIStyle
		WITH _screen.oSettingObject as WisemisSettingObject
			cUIStyle=.GetValue("UIStyle")
		ENDWITH
		IF !INLIST(cUIStyle,"new","old")
			cUIStyle="new"
		ENDIF
		IF cUIStyle=="new"
			cAppClass=_Screen.cWiseMisAppClass
		ELSE
			cAppClass=_Screen.cWiseMisAppClass2
		ENDIF
	Endif
	If Vartype(cAppClassLibrary)<>"C" Or Empty(cAppClassLibrary)
		LOCAL cUIStyle
		WITH _screen.oSettingObject as WisemisSettingObject
			cUIStyle=.GetValue("UIStyle")
		ENDWITH
		IF !INLIST(cUIStyle,"new","old")
			cUIStyle="new"
		ENDIF
		IF cUIStyle=="new"
			cAppClassLibrary=_Screen.cWiseMisAppClassLibrary
		ELSE
			cAppClassLibrary=_Screen.cWiseMisAppClassLibrary2
		ENDIF
	Endif
	If Vartype(cInApplication)<>"C" Or Empty(cInApplication)
		cInApplication=_Screen.cWiseMisAppClassInApplication
	ENDIF

	LOCAL nStartSecond
	nStartSecond=SECONDS()

	Local cAppObjectName,oForm As Form
	cAppObjectName=Sys(2015)
	Public &cAppObjectName
	Store Newobject(cAppClass,cAppClassLibrary,cInApplication,oAppObject,oParams,bNoRegisterForm) To (cAppObjectName)
	If Type(cAppObjectName)="O"
		With &cAppObjectName As AppForm
			.Show()
		ENDWITH
		*!*			IF !_screen.bIsWiseMisAdministrator
		*!*				*!*�����¼
		*!*				LOCAL cPreAlias
		*!*				cPreAlias=ALIAS()
		*!*				SELECT (_screen.cAlias_UserClick_App)
		*!*				LOCATE FOR ALLTRIM(LOWER(AppName))==ALLTRIM(LOWER(oAppObject.cAppName))
		*!*				IF FOUND()
		*!*					REPLACE Changed WITH .t.,LastClickTime WITH DATETIME()
		*!*				ELSE
		*!*					APPEND BLANK
		*!*					REPLACE Changed WITH .t.,AppName WITH oAppObject.cAppName,LastClickTime WITH DATETIME()
		*!*				ENDIF
		*!*				IF SELECT(cPreAlias)>0
		*!*					SELECT (cPreAlias)
		*!*				ENDIF
		*!*			ENDIF

		*MESSAGEBOX("�����������ѣ�"+TRANSFORM(SECONDS()-nStartSecond)+"�롣")

		Return &cAppObjectName
	Else
		MessageBox1("����Ӧ�÷���ʧ�ܣ�",0+64,"ϵͳ��ʾ")
		Return null
	ENDIF

ENDPROC

*!*����Ĭ��Excel����ģ��
PROCEDURE CreateAppExcelModal
	LPARAMETERS oAppObject as AppObject
	LOCAL cReportName
	cReportName=InputBox1("������Ҫ���ɵı���ģ�����ƣ�","���ɱ���ģ��","Ĭ�ϱ���")
	IF EMPTY(cReportName)
		RETURN
	ENDIF
	LOCAL cCheckSQL
	TEXT TO cCheckSQL NOSHOW TEXTMERGE 
IF exists(select * from WiseMis_ExcelModal where ModalName='<<cReportName>>')
	SELECT 1
ELSE
	SELECT 0
	ENDTEXT 
	IF GetValue(cCheckSQL)=1
		MessageBox1("�����Ѵ��ڣ��������������ԣ�",0+64,"ϵͳ��ʾ")
		RETURN
	ENDIF
	LOCAL oExcel as Excel.Application
	oExcel=CREATEOBJECT("Excel.Application")
	LOCAL oWorkbook as Excel.Workbook
	oWorkbook=oExcel.Workbooks.Add()
	LOCAL oWorksheet as Excel.Worksheet
	IF oWorkbook.Worksheets.Count=0
		oWorksheet=oWorkbook.Worksheets.Add()
	ELSE
		oWorksheet=oWorkbook.Worksheets(1)
	ENDIF
	************************************************************************************************
	*!*��һ������д���⣬λ�ã�
	LOCAL cAppCaption
	cAppCaption=oAppObject.cAppCaption
	oWorksheet.Range("G2").Value=cAppCaption
	oWorksheet.Range("G2").Font.Bold=.t.

	LOCAL cSQL,cCursorNames,cKeysExpr
	STORE "" TO cSQL,cCursorNames,cKeysExpr
	*!*�ڶ������ж��Ƿ�����ģʽ
	IF oAppObject.bMainDetailMode
		cKeysExpr=""
		FOR EACH oFieldObject as AppFieldObject IN oAppObject.oKeyfieldObjects
			cKeysExpr = cKeysExpr + IIF(EMPTY(cKeysExpr),""," and ") + "[" + oFieldObject.cFieldName + "]=?" +  oFieldObject.cFieldName
		ENDFOR
		cSQL="select "+oAppObject.cselectfields+CHR(13)+CHR(10)+" from ["+oAppObject.cBaseTable+"]"+CHR(13)+CHR(10)+"where "+cKeysExpr
		cCursorNames="A1"
		LOCAL nColumn,nRow
		*���ҳͷ
		nColumn=2
		nRow=4
		FOR EACH oFieldObject as AppFieldObject IN oAppObject.oFieldObjects
			IF oFieldObject.cFieldName="__record__guid__" OR oFieldObject.bIsMemoField
				LOOP
			ENDIF
			oWorksheet.Cells(nRow,nColumn).Value=oFieldObject.cFieldCaption
			nColumn = nColumn + 1
			oWorksheet.Cells(nRow,nColumn).Value="{A1."+oFieldObject.cFieldName+"}"
			nColumn = nColumn + 1
			IF nColumn>=10
				nRow = nRow + 1
				nColumn=2
			ENDIF
		ENDFOR
		*�����ϸ
		LOCAL nCurCount
		nCurCount=1
		FOR EACH oRelationObject as AppRelationObject IN oAppObject.orelationobjects
			LOCAL oRelationAppObject as AppObject
			oRelationAppObject=CreateAppObject(oRelationObject.cChildAppName)
			IF VARTYPE(oRelationAppObject)<>"O"
				LOOP
			ENDIF
			nCurCount = nCurCount + 1
			nRow = nRow + 1
			oWorksheet.Cells(nRow,2).Value=oRelationObject.cCaption
			nRow = nRow + 1
			nColumn=2
			*�����ϸ��ͷ
			FOR EACH oFieldObject as AppFieldObject IN oRelationAppObject.oFieldObjects
				IF oFieldObject.cFieldName="__record__guid__" OR oFieldObject.bIsMemoField
					LOOP
				ENDIF
				oWorksheet.Cells(nRow,nColumn).Value=oFieldObject.cFieldCaption
				oWorksheet.Cells(nRow,nColumn).Font.Bold=.t.
				oWorksheet.Cells(nRow,nColumn).Borders(7).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(8).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(9).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(10).LineStyle=1
				nColumn = nColumn + 1
			ENDFOR
			nRow = nRow + 1
			LOCAL cChildCursor,cChildSQL,cChildKeys
			cChildKeys=""
			FOR i=1 TO GETWORDCOUNT(oRelationObject.cChildFields,",")
				LOCAL oChildFieldObject as AppFieldObject
				oChildFieldObject=oRelationAppObject.GetFieldObject(GETWORDNUM(oRelationObject.cChildFields,i,","))
				IF VARTYPE(oChildFieldObject.oUserRightObject)<>"O"
					LOOP
				ENDIF
				cChildKeys = cChildKeys + IIF(EMPTY(cChildKeys),""," and ") + "[" + GETWORDNUM(oRelationObject.cChildFields,i,",") + "]=?" + GETWORDNUM(oRelationObject.cMainFields,i,",")
			ENDFOR
			cChildCursor="A"+TRANSFORM(nCurCount)
			cChildSQL="select "+oRelationAppObject.cselectfields+CHR(13)+CHR(10)+"from ["+oRelationAppObject.cBaseTable+"]"+CHR(13)+CHR(10)+"where "+cChildKeys+CHR(13)+CHR(10)+IIF(EMPTY(oRelationAppObject.cOrderExpr),""," order by "+oRelationAppObject.cOrderExpr)
			cCursorNames = cCursorNames + "," + cChildCursor
			cSQL = cSQL + REPLICATE(CHR(13)+CHR(10),2) + cChildSQL
			oWorksheet.Cells(nRow,1).Value="{���忪ʼ}"
			oWorksheet.Cells(nRow,2).Value=cChildCursor
			nRow = nRow + 1
			nColumn=2
			FOR EACH oFieldObject as AppFieldObject IN oRelationAppObject.oFieldObjects
				IF oFieldObject.cFieldName="__record__guid__" OR oFieldObject.bIsMemoField
					LOOP
				ENDIF
				oWorksheet.Cells(nRow,nColumn).Value="{"+oFieldObject.cFieldName+"}"
				oWorksheet.Cells(nRow,nColumn).Borders(7).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(8).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(9).LineStyle=1
				oWorksheet.Cells(nRow,nColumn).Borders(10).LineStyle=1
				nColumn = nColumn + 1
			ENDFOR
			nRow = nRow + 1
			oWorksheet.Cells(nRow,1).Value="{�������}"
		ENDFOR
		*���ҳβ
		nRow = nRow + 1
		nRow = nRow + 1
		oWorksheet.Cells(nRow,1).Value="{����}"
	ELSE
		LOCAL nColumn
		nColumn=2
		*���ҳͷ
		FOR EACH oFieldObject as AppFieldObject IN oAppObject.oFieldObjects
			IF oFieldObject.cFieldName="__record__guid__" OR oFieldObject.bIsMemoField
				LOOP
			ENDIF
			oWorksheet.Cells(4,nColumn).Value=oFieldObject.cFieldCaption
			oWorksheet.Cells(4,nColumn).Font.Bold=.t.
			oWorksheet.Cells(4,nColumn).Borders(7).LineStyle=1
			oWorksheet.Cells(4,nColumn).Borders(8).LineStyle=1
			oWorksheet.Cells(4,nColumn).Borders(9).LineStyle=1
			oWorksheet.Cells(4,nColumn).Borders(10).LineStyle=1
			nColumn = nColumn + 1
		ENDFOR
		*�����ϸ
		oWorksheet.Cells(5,1).Value="{���忪ʼ}"
		nColumn=2
		FOR EACH oFieldObject as AppFieldObject IN oAppObject.oFieldObjects
			IF oFieldObject.cFieldName="__record__guid__" OR oFieldObject.bIsMemoField
				LOOP
			ENDIF
			oWorksheet.Cells(6,nColumn).Value="{"+oFieldObject.cFieldName+"}"
			oWorksheet.Cells(6,nColumn).Borders(7).LineStyle=1
			oWorksheet.Cells(6,nColumn).Borders(8).LineStyle=1
			oWorksheet.Cells(6,nColumn).Borders(9).LineStyle=1
			oWorksheet.Cells(6,nColumn).Borders(10).LineStyle=1
			nColumn = nColumn + 1
		ENDFOR
		oWorksheet.Cells(7,1).Value="{�������}"
		*���ҳβ
		oWorksheet.Cells(9,1).Value="{����}"
	ENDIF
	************************************************************************************************
	LOCAL cSaveFileName
	cSaveFileName=ADDBS(_screen.cFilesPath)+SYS(2015)+".xls"
	IF EMPTY(cSaveFileName)
		oWorkbook.Close(.f.)
		oExcel.Quit
		RETURN
	ENDIF
	oWorkbook.SaveAs(cSaveFileName)
	oWorkbook.Close()
	LOCAL cFileStream
	cFileStream=oAppObject.cAppCaption+cReportName+"ģ��:xls&ext;"+FILETOSTR(cSaveFileName)
	cFileStream=STRCONV(cFileStream,15)
	oExcel.Quit
	LOCAL cSaveCmd
	TEXT TO cSaveCmd NOSHOW TEXTMERGE
	INSERT INTO WiseMis_ExcelModal(OrderId,ModalName,BaseTable,SQLText,CursorList,ExcelData,Remark)
		values (10,'<<cReportName>>','<<oAppObject.cBaseTable>>','<<STRTRAN(cSQL,"'","''")>>','<<cCursorNames>>',0x<<cFileStream>>,'')
	ENDTEXT
	IF !Execute(cSaveCmd)
		MessageBox1("����ģ��ʧ�ܣ�",0+64,"ϵͳ��ʾ")
		RETURN
	ENDIF
	ERASE (cSaveFileName)
	MessageBox1("ģ�汣��ɹ�����༭ģ�����ݣ�",0+64,"ϵͳ��ʾ")
	LOCAL oParamsCollection as Collection
	oParamsCollection=CREATEOBJECT("Collection")
	oParamsCollection.Add(oAppObject.cAppName,"AppName")
	oParamsCollection.Add(cReportName,"ModalName")
	LOCAL oTestAppObject as AppObject
	oTestAppObject=CreateAppObject("Excelģ��")
	=DoWiseMisApplication(oTestAppObject,oParamsCollection)
ENDPROC