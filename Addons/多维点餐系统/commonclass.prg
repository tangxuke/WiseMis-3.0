*!*ÃÊªªInputbox
PROCEDURE InputBox1
	LPARAMETERS  cDialogCaption ,cInputPrompt,cDefaultValue , nTimeout ,cTimeoutValue,cCancelValue
	LOCAL cInputValue
	cInputValue=INPUTBOX(cInputPrompt,cDialogCaption,cDefaultValue,nTimeout,cTimeoutValue,cCancelValue)
	*DO FORM frm_tool_inputbox WITH cInputPrompt , cDialogCaption , cDefaultValue TO cInputValue
	RETURN cInputValue
ENDPROC 

*!*÷ÿ–¬…Ë÷√±Ì∏Ò
Procedure ResetGrid
	Lparameters oGrid As Grid
	oGrid.ColumnCount=Fcount(oGrid.RecordSource)
	oGrid.HeaderHeight=26
	oGrid.RowHeight=24
	For i=1 To oGrid.ColumnCount
		With oGrid.Columns[i] As Column
			.ControlSource=Field(i,oGrid.RecordSource)
			With .Header1 As Header
				.Caption=Field(i,oGrid.RecordSource)
				.Alignment= 2
				.FontBold= .T.
				.ForeColor= RGB(0,0,128)
				.FontName="Œ¢»Ì—≈∫⁄"
				.FontSize=10
			ENDWITH
			.FontName="Œ¢»Ì—≈∫⁄"
			.FontSize=9
			If Type(.ControlSource)="L"
				Local oColumn As Column
				oColumn=oGrid.Columns[i]
				With oColumn.Controls[2] As Control
					oColumn.RemoveObject(.Name)
				Endwith
				Local cTempName
				cTempName=Sys(2015)
				.Newobject (cTempName,"Checkbox")
				With .Controls[2] As Checkbox
					.BackStyle= 0
					.Caption=""
					.AutoSize= .F.
					.Alignment= 2
					.Centered= .T.
					.Visible= .T.
				Endwith
				.CurrentControl=cTempName
				.Alignment= 2
				.Width=40
				.Sparse=.F.
			Endif
			If Mod(i,2)=0
				.BackColor=Rgb(236,233,216)
			Else
				.BackColor=Rgb(255,255,255)
			Endif
		Endwith
	Endfor
	oGrid.AutoFit
	For Each oColumn As Column In oGrid.Columns
		oColumn.Width = oColumn.Width + 5
	Endfor
Endproc