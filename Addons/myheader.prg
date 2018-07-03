Define Class myHeader As Header
	CanOrder = .T.
	bDesc = .T.
	Name = "header"
	Alignment = 2
	ForeColor = Rgb(0,0,255)

	Procedure Click
		If !Used()
			Return
		Endif
		Select (Alias())
		Local cField
		cField = This.Parent.ControlSource
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
			nAvg = Transform(nAvg,"999,999,999,999")
			nSum = Transform(nSum,"999,999,999,999")
			vMax = Transform(vMax,"999,999,999,999")
			vMin = Transform(vMin,"999,999,999,999")
		Endif
		=SetStatusText("合计：" + Alltrim(Transform(nSum)) + "，最大值：" + Alltrim(Transform(vMax)) +  ;
			"，最小值：" +  ;
			ALLTRIM(Transform(vMin)) +  ;
			"，平均值：" +  ;
			ALLTRIM(Transform(nAvg)) +  ;
			"，次数：" +  ;
			ALLTRIM(Transform(nCount,"999,999,999")))
	Endproc

	Procedure RightClick
		If !Used() .Or. !This.CanOrder
			Return
		Endif
		Select (Alias())
		If CursorGetProp("Buffering",Alias()) <> 1
			= Tablerevert(.T.)
		Endif
		Local cField , nFieldIndex
		cField = This.Parent.ControlSource
		For iFieldIndex = 1 To Fcount()
			If Alltrim(Lower(Field(iFieldIndex))) = Alltrim(Lower(cField))
				nFieldIndex = iFieldIndex
			Endif
		Endfor
		If Inlist(Type(cField),"M","G","W")
			Return
		Endif
		*Close Indexes
		LOCAL oGrid as _grid OF _base.vcx
		oGrid=this.Parent.Parent
		SELECT (oGrid.RecordSource)
		CLOSE INDEXES
		oGrid.SetAll("Picture","","Header")
		This.bDesc=!This.bDesc
		If This.bDesc
			this.Picture="down.bmp"
			Index On &cField Tag &cField DESCENDING ADDITIVE 
		Else
			this.Picture="up.bmp"
			Index On &cField Tag &cField ASCENDING ADDITIVE
		ENDIF
		this.Parent.AutoFit
		oGrid.Refresh
*!*			If This.bDesc
*!*				Index On &cField Tag &cField ASCENDING ADDITIVE
*!*				This.bDesc = .F.
*!*				this.Picture="up.bmp"
*!*			Else
*!*				Index On &cField Tag &cField DESCENDING ADDITIVE 
*!*				This.bDesc = .T.
*!*				this.Picture="down.bmp"
*!*			Endif
*!*			This.Parent.Parent.Refresh
*!*			this.Parent.AutoFit()
	Endproc

	Procedure LostFocus
		This.bDesc = .T.
	Endproc

	Procedure Init
		bDesc = .T.
	Endproc
Enddefine

Define Class myCol As Column
	Name = "column"
	HeaderClass = "myHeader"
	HeaderClassLibrary = "myHeader.prg"

	Procedure GetValue
		Return Evaluate(This.ControlSource)
	Endproc

	Procedure SetValue
		Lparameter oColValue As VARIANT
		Select (This.Parent.RecordSource)
		Replace (This.ControlSource) With oColValue
		This.Parent.AutoFit
	Endproc
Enddefine

