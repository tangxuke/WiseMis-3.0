Procedure ToExcel
	Lparameters cExcelFile As String, cOutputFile As String, bIsWpsET As BOOLEAN, bPreviewDirect As BOOLEAN, bPrintDirect As BOOLEAN
	If Vartype(bIsWpsET)<>"L"
		bIsWpsET = .F.
	Endif
	If Vartype(cExcelFile)<>"C" .Or. Empty(cExcelFile)
		cExcelFile = Getfile(Iif(bIsWpsET, "et", "xls"))
	Endif
	If Vartype(bPreviewDirect)<>"L"
		bPreviewDirect = .F.
	Endif
	Local oExcelObject As EXCEL.Application
	Try
		If  .Not. bIsWpsET
			oExcelObject = Createobject("Excel.Application")
		Else
			oExcelObject = Createobject("ET.Application")
		Endif
	Catch To oErr
	Endtry
	If Vartype(oExcelObject)<>"O"
		MessageBox1("无法创建对象，请检查是否正确安装了"+Iif(bIsWpsET, "WPS表格", "Excel")+"软件！", 64, "系统提示")
		Return
	Endif
	Local oExcelBook As Excel.Workbook
	oExcelObject.Workbooks.Open(cExcelFile, 0, .F.)
	oExcelBook = oExcelObject.Workbooks.Item(1)
	Local oSheet As Excel.Worksheet
	For Each oSheet In oExcelBook.Worksheets
		If oSheet.UsedRange.Rows.Count=0
			Loop
		Endif
		Local bFormatValid
		bFormatValid = .F.
		For nUsedExcelRow = 1 To oSheet.UsedRange.Rows.Count
			Local vUsedExcelCellValue
			vUsedExcelCellValue = NVL(oSheet.UsedRange.Cells(nUsedExcelRow,1).Value,"")
			If Vartype(vUsedExcelCellValue)="C" .And.  .Not. Empty(vUsedExcelCellValue)
				If Inlist(vUsedExcelCellValue, "{页尾结束}", "{结束}")
					bFormatValid = .T.
					Exit
				Endif
			Endif
		Endfor
		If  .Not. bFormatValid
			Loop
		Endif
		Local nRow, nCol, vCellValue, cItemName, vItemValue, nCurRow
		Store 0 To nRow
		nCol = oSheet.UsedRange.Columns.Count
		Do While .T.
			nRow = nRow+1
			Local vFirstItem
			vFirstItem = NVL(oSheet.Cells(nRow,1).Value,"")
			If Vartype(vFirstItem)="C" .And.  .Not. Empty(vFirstItem)
				Do Case
					Case Inlist(Alltrim(vFirstItem), "{结束}", "{页尾结束}","END")
						oSheet.Rows(nRow).Delete()
						EXIT
					Case Inlist(Alltrim(vFirstItem), "{表头}", "{HEAD}")
						cAliasName = NVL(oSheet.Cells(nRow,2).Value,"")
						IF SELECT(cAliasName)=0
							cAliasName=ALIAS()
						ENDIF 
						SELECT (cAliasName)
						*GOTO TOP 
						oSheet.Rows(nRow).Delete()
						nRow = nRow - 1 
						LOOP 
					Case INLIST(Alltrim(vFirstItem),"{表体开始}","BODY_BEGIN") .Or. Like("{表体开始:*}", Alltrim(vFirstItem)) OR LIKE("{BODY:*}",Alltrim(vFirstItem))
						If INLIST(Alltrim(vFirstItem),"{表体开始}","{BODY_BEGIN}")
							cAliasName = NVL(oSheet.Cells(nRow,2).Value,"")
						Else
							cAliasName = Getwordnum(Strextract(vFirstItem, "{", "}"), 2, ":")
						Endif
						Local nMinRows
						nMinRows = NVL(oSheet.Cells(nRow,3).Value,0)
						If Vartype(nMinRows)<>"N"
							nMinRows = 0
						ENDIF
						LOCAL cScanCondition
						cScanCondition=NVL(oSheet.Cells(nRow,4).Value,"")
						IF EMPTY(cScanCondition)
							cScanCondition=".t."
						ENDIF

						If Vartype(cAliasName)<>"C" .Or. Empty(cAliasName)
							cAliasName = Alias()
						Endif
						If Select(cAliasName)=0
							cAliasName = Alias()
						Endif
						If Select(cAliasName)=0
							MessageBox1("工作表没有打开！", 64, "系统提示")
							Return
						Endif
						Local nModalRow, nCurRow, iPos, nRestRows
						iPos = 0
						nModalRow = nRow+1
						nCurRow = nModalRow
						Select (cAliasName)
						IF RECCOUNT()=0
							LOOP 
						ENDIF 
						nRestRows = nMinRows-Reccount()
						Goto Top
						SCAN FOR &cScanCondition
							Wait Window Noclear Nowait "正在加载..."+Transform(Int(100*Recno()/Reccount()))+"%"
							iPos = iPos+1
							nCurRow = nModalRow+iPos
							oSheet.Rows(nModalRow).Copy()
							oSheet.Rows(nCurRow).Insert(-4121, nModalRow)
							For iCol = 1 To nCol
								vCellValue = NVL(oSheet.Cells(nModalRow,iCol).Value,"")
								If Vartype(vCellValue)="C" .And.  .Not. Empty(vCellValue)
									If Left(vCellValue, 1)="{" .And. Right(vCellValue, 1)="}" .And. Occurs("{", vCellValue)=1 .And. Occurs("}", vCellValue)=1
										cItemName = Strextract(vCellValue, "{", "}")
										If INLIST(cItemName,"下行","SKIP")
											If  .Not. Eof()
												Skip
											Endif
											oSheet.Cells(nCurRow, iCol).Value = ""
											Loop
										Else
											If Inlist(Type(cItemName), "U", "X")
												Loop
											Endif
											vItemValue = Evaluate(cItemName)
											If Vartype(vItemValue)="C"
												vItemValue = Rtrim(vItemValue)
											Endif
											Try
												If  !Eof()
													oSheet.Cells(nCurRow, iCol).Value = NVL(vItemValue,"")
												Else
													oSheet.Cells(nCurRow, iCol).Value = ""
												Endif
											Catch To oErr
												MessageBox1(oErr.Message, 064, "发生异常错误")
											Endtry
										Endif
									Endif
								Endif
							Endfor
						ENDSCAN
						Wait Clear
						DO WHILE nRestRows>0
							iPos = iPos+1
							nCurRow = nModalRow+iPos
							oSheet.Rows(nModalRow).Copy()
							oSheet.Rows(nCurRow).Insert(-4121, nModalRow)
							For iCol = 1 To nCol
								oSheet.Cells(nCurRow, iCol).Value = ""
							ENDFOR
							nRestRows = nRestRows - 1
						ENDDO

						oSheet.Rows(nModalRow-1).Delete()
						oSheet.Rows(nModalRow-1).Delete()
						oSheet.Rows(nCurRow-1).Delete()
					Otherwise
						For iCol = 1 To nCol
							vCellValue = NVL(oSheet.Cells(nRow,iCol).Value,"")
							If Vartype(vCellValue)="C" .And.  .Not. Empty(vCellValue)
								If Left(vCellValue, 1)="{" .And. Right(vCellValue, 1)="}" .And. Occurs("{", vCellValue)=1 .And. Occurs("}", vCellValue)=1
									cItemName = Strextract(vCellValue, "{", "}")
									If Inlist(Type(cItemName), "U", "X")
										Loop
									Endif
									vItemValue = Evaluate(cItemName)
									If Vartype(vItemValue)="C"
										vItemValue = Rtrim(vItemValue)
									Endif
									Try
										oSheet.Cells(nRow, iCol).Value = NVL(vItemValue,"")
									Catch To oErr
										MessageBox1(oErr.Message, 064, "发生异常错误")
									Endtry
								Endif
							Endif
						Endfor
				Endcase
			Else
				For iCol = 1 To nCol
					vCellValue = NVL(oSheet.Cells(nRow,iCol).Value,"")
					If Vartype(vCellValue)="C" .And.  .Not. Empty(vCellValue)
						If Left(vCellValue, 1)="{" .And. Right(vCellValue, 1)="}" .And. Occurs("{", vCellValue)=1 .And. Occurs("}", vCellValue)=1
							cItemName = Strextract(vCellValue, "{", "}")
							If Inlist(Type(cItemName), "U", "X")
								Loop
							Endif
							vItemValue = Evaluate(cItemName)
							If Vartype(vItemValue)="C"
								vItemValue = Rtrim(vItemValue)
							Endif
							oSheet.Cells(nRow, iCol).Value = NVL(vItemValue,"")
						Endif
					Endif
				Endfor
			Endif
		Enddo
		If bPreviewDirect
			oExcelObject.Visible = .T.
			oSheet.PrintPreview()
		Endif
		If bPrintDirect
			oExcelObject.Visible = .T.
			oSheet.PrintOut()
		Endif
	Endfor
	If Vartype(cOutputFile)="C" .And.  .Not. Empty(cOutputFile)
		oExcelBook.SaveAs(cOutputFile)
	Endif
	oExcelBook.Close(.F.)
	oExcelObject.Quit()
ENDPROC