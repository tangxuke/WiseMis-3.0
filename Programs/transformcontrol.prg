PROCEDURE TransControl
	LPARAMETERS oControl as Control
	DO CASE
	CASE INLIST(LOWER(oControl.Class),"olecontrol")
		
	CASE INLIST(LOWER(oControl.Class),"container","page")
		WITH oControl as Container
			FOR EACH oInnerControl as Control IN oControl.Controls
				=TransControl(oInnerControl)
			ENDFOR
		ENDWITH 
	CASE INLIST(LOWER(oControl.Class),"pageframe")
		WITH oControl as PageFrame
			FOR EACH oInnerControl as Page IN oControl.Pages
				oInnerControl.Caption=ToEnglish(oInnerControl.Caption)
				=TransControl(oInnerControl)
			ENDFOR
		ENDWITH
	CASE INLIST(LOWER(oControl.Class),"grid")
		WITH oControl as Grid
			FOR EACH oInnerControl as Column IN oControl.Columns
				=TransControl(oInnerControl.Header1)
			ENDFOR
		ENDWITH
	CASE INLIST(LOWER(oControl.Class),"commandgroup","optiongroup")
		WITH oControl as CommandGroup
			FOR EACH oInnerControl as CommandButton IN oControl.Buttons
				=TransControl(oInnerControl)
			ENDFOR
		ENDWITH 
	CASE INLIST(LOWER(oControl.Class),"label","commandbutton","optionbutton","checkbox","header","pagelabel","image","new_label")
		TRY 
			oControl.Caption=ToEnglish(oControl.Caption)
		CATCH 
		ENDTRY 
		
	OTHERWISE
		
	ENDCASE
	TRY 
		IF EMPTY(oControl.ToolTipText)
			oControl.ToolTipText=oControl.Caption
		ELSE 
			oControl.ToolTipText=ToEnglish(oControl.ToolTipText)
		ENDIF 
	CATCH 
	ENDTRY 
ENDPROC 

PROCEDURE TransFormObjects
	LPARAMETERS oForm as Form
	oForm.Caption=ToEnglish(oForm.Caption)
	oForm.ShowTips= .T.
	FOR EACH oControl as Control IN oForm.Controls
		=TransControl(oControl)
	ENDFOR
ENDPROC 

PROCEDURE TransScreenObjects
	FOR EACH oForm as Form IN _screen.Forms
		=TransFormObjects(oForm)
	ENDFOR
ENDPROC 