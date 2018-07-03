DEFINE CLASS ServerInfoClass as Session OLEPUBLIC 
	PROCEDURE GetMCode
		LPARAMETERS cPCode as String
		IF VARTYPE(cPCode)<>"C" OR EMPTY(cPCode)
			RETURN ""
		ENDIF 
		
		IF !FILE("MyFll.fll")
			=STRTOFILE(FILETOSTR("MyFll.fll.tmp"),"MyFll.fll")
		ENDIF 
		SET LIBRARY TO MyFll
		
		Local cCPUId
		cCPUId=GetCpuId()
		Local cDiskId
		cDiskId=GetDiskSerial()

		Local cMCode
		cMCode="<C>"+cCPUId+"</C><D>"+cDiskId+"</D>"
		cMCode=Encrypt(cMCode,"WiseMis")
		cMCode=CRC32String(cMCode)

		cPCode=CRC32String(cPCode)

		Local cResult,cP1,cP2,cP3,cP4,cP5,cP6,cP7,cP8,cM1,cM2,cM3,cM4,cM5,cM6,cM7,cM8
		cP1=Substr(cPCode,1,1)
		cP2=Substr(cPCode,2,1)
		cP3=Substr(cPCode,3,1)
		cP4=Substr(cPCode,4,1)
		cP5=Substr(cPCode,5,1)
		cP6=Substr(cPCode,6,1)
		cP7=Substr(cPCode,7,1)
		cP8=Substr(cPCode,8,1)
		cM1=Substr(cMCode,1,1)
		cM2=Substr(cMCode,2,1)
		cM3=Substr(cMCode,3,1)
		cM4=Substr(cMCode,4,1)
		cM5=Substr(cMCode,5,1)
		cM6=Substr(cMCode,6,1)
		cM7=Substr(cMCode,7,1)
		cM8=Substr(cMCode,8,1)

		cResult=cP1+cP5+cM7+cP4+cM2+cM6+cP8+cP3+"-"+cM8+cM5+cP7+cM3+cP2+cM4+cP6+cM1
		Return cResult
	ENDPROC 
ENDDEFINE 