DEFINE CLASS AppGridColumn as Column
	cTempF7Name=""
	*!*�ֶζ���
	oFieldObject=null
	*!*�ű�����
	oScriptEngine=null
	*!*�ֶοؼ�
	oFieldControl=null
	*!*���Ŀؼ�
	oCoreControl=null
	*!*����ؼ�
	oHeader=null
	*!*����ʽ
	nOrderType=0		&& 2��ʾ����,������ʾ����
	*!*����ֵ
	vObjectValue=null
	*!*�û��ı��Сģʽ
	bUserResize=.f.
	*!*��������
	oParentGridContainer=null
	*!*���ݾɰ汾
	cFieldType=""

	_memberdata = FILETOSTR("AppGrid.xml")
	PROCEDURE vObjectValue_Access
		RETURN this.GetValue()
	ENDPROC
	
	PROCEDURE OnLayoutChange
		LPARAMETERS bNoReset as Boolean
	ENDPROC 
	
	PROCEDURE cFieldType_Access
		WITH this.oFieldObject as AppFieldObject
			IF VARTYPE(.oUserRightObject)="O"
				WITH .oUserRightObject as AppUserRightObject
					RETURN .cFieldType
				ENDWITH 
			ELSE
				RETURN .cFieldDataType
			ENDIF 
		ENDWITH 
	ENDPROC 
	
	*!*���ñ���
	PROCEDURE SetTitle
		LPARAMETERS cTitleText
	ENDPROC 

	*!*ִ�г�ʼ��
	PROCEDURE DoInit
		this.ForeColor= RGB(0,0,128)
		
		LOCAL oFieldObject as AppFieldObject
		oFieldObject=this.oFieldObject
		
		IF oFieldObject.nFieldWidth>0
			this.Width=oFieldObject.nFieldWidth
		ENDIF
		
		LOCAL cF1
		cF1=oFieldObject.F1
		*this.ControlSource=oFieldObject.F1
		
		*!*���ӱ���ؼ�
		LOCAL oHeader as Header
		oHeader=EVALUATE("this.Header1")
		this.oHeader=oHeader
		this.SetHeader()
		*!*�������ؼ�
		this.SetControl(oFieldObject.nFieldControlType)
		*!*���ýű�����
		this.SetScriptEngine(this.oScriptEngine)
		*!*���¼�
		this.BindEvents()
		*!*����ֻ������
		this.ReadOnly=oFieldObject.bIsReadonly
		this.SetAll("Readonly",oFieldObject.bIsReadonly)
		*!*��������͸�ʽ
		IF !EMPTY(oFieldObject.cInputMask)
			this.InputMask=oFieldObject.cInputMask
		ELSE
			IF INLIST(LOWER(oFieldObject.cFieldDataType),"n","numeric")
				this.InputMask=REPLICATE("9",oFieldObject.nFieldPrec-oFieldObject.nFieldScale-1)+"."+REPLICATE("9",oFieldObject.nFieldScale)
			ENDIF 
		ENDIF 
		IF !EMPTY(oFieldObject.cFormat)
			this.Format="R"
		ENDIF 
		*!*��̬��ʾ
		IF !EMPTY(NVL(oFieldObject.cDynamicBackColor,""))
			this.DynamicBackColor=oFieldObject.cDynamicBackColor
		ENDIF 
		IF !EMPTY(NVL(oFieldObject.cDynamicForeColor,""))
			this.DynamicForeColor=oFieldObject.cDynamicForeColor
		ENDIF 
		IF !EMPTY(NVL(oFieldObject.cDynamicFontBold,""))
			this.DynamicFontBold=oFieldObject.cDynamicFontBold
		ENDIF 
		IF !EMPTY(NVL(oFieldObject.cDynamicFontItalic,""))
			this.DynamicFontItalic=oFieldObject.cDynamicFontItalic
		ENDIF 
		IF !EMPTY(NVL(oFieldObject.cDynamicFontStrikeThru,""))
			this.DynamicFontStrikeThru=oFieldObject.cDynamicFontStrikeThru
		ENDIF 
		IF !EMPTY(NVL(oFieldObject.cDynamicFontUnderline,""))
			this.DynamicFontUnderline=oFieldObject.cDynamicFontUnderline
		ENDIF 
		 
		*!*��ʼ��ֵ
		*this.SetValue(oFieldObject.vDefaultValue)
		IF VARTYPE(this.oCoreControl)="O"
			WITH this.oCoreControl as AppGridFieldControl_TextBox
				.OnResize()
			ENDWITH 
		ENDIF 
	ENDPROC

	*!*���ñ���
	PROCEDURE SetHeader
		LOCAL oHeader as Header
		oHeader=this.Header1
		oHeader.Alignment= 2
		oHeader.FontName="΢���ź�"
		oHeader.FontCharSet= 134
		oHeader.FontSize=10
		oHeader.BackColor= RGB(199,237,204)
		
		oHeader.FontBold= .T.
		IF VARTYPE(this.oFieldObject)="O"
			WITH this.oFieldObject as AppFieldObject
				oHeader.Caption=.cFieldCaption_NoChange
				IF (!.bIsInsert AND !.bIsUpdate) OR .bIsReadonly
					oHeader.ForeColor= RGB(64,128,128)
					this.SetAll("TabStop",.f.)
					this.Enabled= .f.
				ENDIF
				IF .nOrderType=0
					oHeader.Picture=""
				ENDIF 
				IF .bF7Enabled
					oHeader.Picture="select.bmp"
				ENDIF 
				*!*������ʾ
				IF .bIsTreeField
					oHeader.Picture="treenode.bmp"
				ENDIF 
				*!*������ʾ
				IF .nOrderType=1
					oHeader.Picture="up.bmp"
				ENDIF 
				IF .nOrderType=2
					oHeader.Picture="down.bmp"
				ENDIF 
			ENDWITH
		ENDIF 
		WITH this.Parent as Grid
			IF !.AllowCellSelection
				oHeader.ForeColor=RGB(0,0,0)
				this.Enabled= .T.
			ENDIF 
		ENDWITH 
	ENDPROC

	*!*���ÿؼ�
	PROCEDURE SetControl
		LPARAMETERS nControlType
		IF VARTYPE(nControlType)<>"N"
			IF VARTYPE(this.oFieldObject)="O"
				WITH this.oFieldObject as AppFieldObject
					nControlType=.nFieldControlType
				ENDWITH
			ENDIF 
		ENDIF
		LOCAL cFieldControlClass

		DO CASE
			CASE INLIST(nControlType,3)
				cFieldControlClass="AppGridFieldControl_Checkbox"
			CASE INLIST(nControlType,5,9,11)
				cFieldControlClass="AppGridFieldControl_Combobox"
				IF this.Width<80
					this.Width=80
				ENDIF 
			CASE INLIST(nControlType,12)
				cFieldControlClass="AppGridFieldControl_UrlTextbox"
			OTHERWISE
				cFieldControlClass="AppGridFieldControl_Textbox"
		ENDCASE
		IF TYPE("this.oMainControl")="O"
			this.RemoveObject("oMainControl")
		ENDIF

		this.AddObject("oMainControl",cFieldControlClass)
		this.oCoreControl=EVALUATE("this.oMainControl")
		WITH this.oCoreControl as AppGridFieldControl_Textbox
			.oFieldObject=this.oFieldObject
			.DoInit()
			.Visible= .T.
		ENDWITH
		*!*���������������ʾ��ʽ
		WITH this.oFieldObject as AppFieldObject
			LOCAL cInputMask,cFormat
			cInputMask=.cInputMask
			cFormat=.cFormat
			WITH this.oCoreControl as AppGridFieldControl_Textbox
				IF !EMPTY(cInputMask)
					.InputMask=cInputMask
				ENDIF 
				IF !EMPTY(cFormat)
					.Format=cFormat
				ENDIF 
			ENDWITH 
		ENDWITH 
		this.CurrentControl="oMainControl"
	ENDPROC

	*!*���ýű�����
	PROCEDURE SetScriptEngine
		LPARAMETERS oScriptEngine as AppScriptEngine
		IF VARTYPE(oScriptEngine)<>"O"
			RETURN
		ENDIF

		oScriptEngine.AddFieldControl(this)
	ENDPROC

	*!*��ֵ
	PROCEDURE SetValue
		LPARAMETERS vNewValue

		LOCAL cPreCursor
		cPreCursor=ALIAS()
		WITH this.oFieldObject as AppFieldObject
			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH
			
			LOCAL vOldValue,cF2
			cF2=.F2
			vOldValue=EVALUATE(.F1)
			REPLACE (.F1) WITH m.vNewValue,(.F2) WITH .t.,__edit__ with .t.
*!*				IF .bIsUpdate AND .bUpdateRight AND TRANSFORM(EVALUATE(.F1))<>TRANSFORM(vOldValue)
*!*					REPLACE __edit__ WITH .t.,&cF2 WITH .t.
*!*				ENDIF
		ENDWITH
		IF SELECT(cPreCursor)>0
			SELECT (cPreCursor)
		ENDIF
		this.Refresh
	ENDPROC

	*!*ȡֵ
	PROCEDURE GetValue
		LOCAL cPreCursor
		cPreCursor=ALIAS()
		LOCAL vFieldValue
		WITH this.oFieldObject as AppFieldObject
			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH
			m.vFieldValue=EVALUATE(.F1)
		ENDWITH
		IF VARTYPE(m.vFieldValue)="C"
			m.vFieldValue=ALLTRIM(m.vFieldValue)
		ENDIF
		IF SELECT(cPreCursor)>0
			SELECT (cPreCursor)
		ENDIF
		RETURN m.vFieldValue
	ENDPROC


	*!*�󶨽ű��¼�
	PROCEDURE BindEvents
		TRY
			*!*�󶨻�ý���ǰ�¼�
			=BINDEVENT(this.oCoreControl,"When",this,"OnWhen")
			*!*�󶨻�ý����¼�
			=BINDEVENT(this.oCoreControl,"GotFocus",this,"OnGotFocus")
			*!*��ʧȥ����ǰ�¼�
			=BINDEVENT(this.oCoreControl,"Valid",this,"OnValid")
			*!*��ʧȥ�����¼�
			=BINDEVENT(this.oCoreControl,"LostFocus",this,"OnLostFocus",4)
			*!*�󶨵����¼�
			=BINDEVENT(this.oCoreControl,"Click",this,"OnClick")
			*!*��˫���¼�
			=BINDEVENT(this.oCoreControl,"DblClick",this,"OnDblClick")
			*!*���һ��¼�
			=BINDEVENT(this.oCoreControl,"RightClick",this,"OnRightClick")
			*!*��ֵ�仯�¼�
			=BINDEVENT(this.oCoreControl,"InteractiveChange",this,"OnInteractiveChange")
			=BINDEVENT(this.oCoreControl,"ProgrammaticChange",this,"OnProgrammaticChange")
			*!*�󶨰����¼�
			=BINDEVENT(this.oCoreControl,"KeyPress",this,"OnKeyPress")
			*!*�󶨱������¼�
			=BINDEVENT(this.oHeader,"RightClick",this,"OnHeaderRightClick")
			=BINDEVENT(this.oHeader,"Click",this,"OnHeaderClick")
		CATCH
		ENDTRY
	ENDPROC

	*!*ִ�нű�
	PROCEDURE ExecuteScript
		LPARAMETERS cScriptType as String,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20

		LOCAL cMethodBody
		WITH this.oFieldObject as AppFieldObject
			WITH .oScriptCollection as Collection
				cMethodBody=.Item(cScriptType)
			ENDWITH 
		ENDWITH

		IF EMPTY(cMethodBody)
			RETURN .t.
		ENDIF

		LOCAL oMethod as AppMethodObject
		oMethod=CREATEOBJECT("AppMethodObject")
		oMethod.oScriptEngine=this.oScriptEngine
		oMethod.cMethodBody=cMethodBody
		RETURN oMethod.Execute(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnWhen
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		WITH this.oFieldObject as AppFieldObject
			LOCAL cCursorType
			cCursorType=.cCursorFieldType
			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH 
			REPLACE (.F1) WITH CAST(EVALUATE(.F1) as &cCursorType)
		ENDWITH 
		RETURN this.ExecuteScript("B",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnGotFocus
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		
		this.CurrentControl="oMainControl"

*!*			IF ISNULL(this.GetValue())
*!*				WITH this.oFieldObject as AppFieldObject
*!*					this.SetValue(.vDefaultValue)
*!*					REPLACE __edit__ with .t.
*!*				ENDWITH
*!*			ENDIF
		
		RETURN this.ExecuteScript("C",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnValid
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		RETURN this.ExecuteScript("D",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnClick
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		RETURN this.ExecuteScript("F",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnDblClick
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		RETURN this.ExecuteScript("G",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnRightClick
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		RETURN this.ExecuteScript("H",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnProgrammaticChange
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		WITH this.oFieldObject as AppFieldObject
			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH
			WITH this.oFieldObject as AppFieldObject
				.vObjectValue=EVALUATE(.F1)
			ENDWITH 
			IF .bIsUpdate AND .bUpdateRight
				REPLACE __edit__ WITH .t.
			ENDIF
		ENDWITH

		*RETURN this.ExecuteScript("I",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnInteractiveChange
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		WITH this.oFieldobject as AppFieldObject
			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH
			.vObjectValue=EVALUATE(.F1)
			REPLACE __edit__ with .t.
		ENDWITH
		
		RETURN this.ExecuteScript("I",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	PROCEDURE OnKeyPress
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		WITH this.oFieldobject as AppFieldObject
			IF p1=-2
				WITH .oAppObject as AppObject
					SELECT (.cDataCursor)
				ENDWITH
				REPLACE __delete__ with .t.
			ENDIF
		ENDWITH
		RETURN this.ExecuteScript("L",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC

	*!*�˷���Ϊ���ݾɰ�ű�
	PROCEDURE Bind_Combox
		LPARAMETERS bBind as Boolean
		IF VARTYPE(bBind)<>"L"
			bBind=.f.
		ENDIF
		IF !bBind
			RETURN
		ENDIF

		WITH this.oFieldObject as AppFieldObject
			IF .bF7Enabled
				LOCAL cTempCursor,cListData
				cListData=""
				cTempCursor=SYS(2015)
				SELECT 0
				LOCAL cF7SelectSQL
				LOCAL oAppObject as AppObject
				oAppObject=.oAppObject
				cF7SelectSQL=oAppObject.TransformSQLText(.cF7SelectSQL)
				IF SelectData(cF7SelectSQL,cTempCursor)
					SELECT (cTempCursor)
					SCAN
						cListData = cListData + IIF(EMPTY(cListData),"",",") + EVALUATE(.cF7ReturnField)
					ENDSCAN
					=CloseAlias(cTempCursor)
				ENDIF
				.cListData=cListData
			ENDIF
		ENDWITH
		WITH this.oCoreControl as AppCoreFieldControl
			.DoInit()
		ENDWITH
	ENDPROC

	*!*�������Ҽ��¼�
	PROCEDURE OnHeaderRightClick
		RETURN 
		
		LOCAL nOrderType
		nOrderType=this.nOrderType
		WITH this.Parent as Grid
			.SetAll("nOrderType",0)
		ENDWITH
		WITH this.oFieldObject as AppFieldObject
			LOCAL oUserRight as AppUserRightObject
			oUserRight=.oUserRightObject
			IF VARTYPE(oUserRight)="O"
				IF oUserRight.bIsMemoField
					RETURN
				ENDIF
			ENDIF

			WITH .oAppObject as AppObject
				SELECT (.cDataCursor)
			ENDWITH
			DO CASE
				CASE nOrderType=2
					SET ORDER TO (.cTagName) ASCENDING
					this.nOrderType=1
				OTHERWISE
					SET ORDER TO (.cTagName) DESCENDING
					this.nOrderType=2
			ENDCASE
		ENDWITH
		WITH this.Parent as Grid
			GOTO TOP
			.Refresh
		ENDWITH
	ENDPROC

	*!*�����������¼�
	PROCEDURE OnHeaderClick
		
		If !Used()
			Return
		ENDIF
		
		WITH this.oFieldObject as AppFieldObject
			SET DECIMALS TO .nFieldScale
		ENDWITH 
		LOCAL nRecNo
		Select (Alias())
		nRecNo=RECNO()
		
		Local cField
		cField = This.ControlSource
		If Inlist(Type(cField),"M","G","W")
			Return
		Endif
		Local nCount , vMax , vMin , nAvg , nSum
		nAvg = null
		nSum = null
		Calculate To nCount Cnt ( )
		Calculate To vMax Max ( Evaluate(cField) ) 
		Calculate To vMin Min ( Evaluate(cField) )
		If Type(cField) = "N"
			Calculate To nAvg Avg ( Evaluate(cField) )
			Calculate To nSum Sum ( Evaluate(cField) )
			nAvg = Transform(nAvg)
			nSum = Transform(nSum)
			vMax = Transform(vMax)
			vMin = Transform(vMin)
		Endif
		=SetStatusText(ToEnglish("�ϼƣ�") + Alltrim(Transform(nSum)) + ToEnglish("�����ֵ��") + Alltrim(Transform(vMax)) +  ;
			ToEnglish("����Сֵ��") +  ;
			ALLTRIM(Transform(vMin)) +  ;
			ToEnglish("��ƽ��ֵ��") +  ;
			ALLTRIM(Transform(nAvg)) +  ;
			ToEnglish("��������") +  ;
			ALLTRIM(Transform(nCount)))
			
		GOTO nRecNo
			
		SET DECIMALS TO 
	ENDPROC

	*!*�����п���ʱ
	PROCEDURE Resize
		WITH this.oFieldObject as AppFieldObject
			IF .nFieldWidth<>this.Width AND this.bUserResize
				.bUserSchameChanged=.t.
				.nFieldWidth=this.Width
			ENDIF
		ENDWITH
		WITH this.oCoreControl as AppGridFieldControl_Textbox
			.OnResize()
		ENDWITH 
	ENDPROC

	*!*�ƶ���ʱ
	PROCEDURE Moved
		WITH this.oFieldObject as AppFieldObject
			WITH .oAppObject as AppObject
				FOR EACH oFieldObject as AppFieldObject IN .oFieldObjectsShowInGrid
					LOCAL oFieldColumn as Column
					oFieldColumn=EVALUATE("this.Parent.__"+oFieldObject.cFieldName+"__")
					oFieldObject.nGridOrderId=oFieldColumn.ColumnOrder
					oFieldObject.bUserSchameChanged=.t.
				ENDFOR
			ENDWITH
		ENDWITH
		DODEFAULT()
	ENDPROC

	*!*ʧȥ����ʱ
	PROCEDURE OnLostFocus
		LPARAMETERS p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20
		
		RETURN this.ExecuteScript("E",p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
	ENDPROC
ENDDEFINE