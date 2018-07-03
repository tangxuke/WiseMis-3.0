PROCEDURE HttpDownFile
	LPARAMETERS cUrl,cLocalFile,bShowProcess as Boolean
	RETURN DownFile(cUrl,cLocalFile)
*!*		IF VARTYPE(bShowProcess)<>"L"
*!*			bShowProcess=.f.
*!*		ENDIF

*!*		LOCAL m.bOK
*!*		m.bOK=.f.
*!*		TRY
*!*			LOCAL m.o as MSXML2.XMLHTTP,m.nTotalSize
*!*			m.o=CREATEOBJECT("MSXML2.XMLHTTP")
*!*			m.o.open("HEAD",cUrl,.f.)
*!*			m.o.send()
*!*			m.nTotalSize=m.o.getResponseHeader("Content-Length")
*!*			IF ISDIGIT(m.nTotalSize)
*!*				LOCAL m.nFileHandle,m.i,m.cTempFile
*!*				m.nTotalSize=VAL(m.nTotalSize)
*!*				m.cTempFile=cLocalFile+".tmp"
*!*				IF FILE(m.cTempFile)
*!*					m.nFileHandle=FOPEN(m.cTempFile,2)
*!*					m.i=FSEEK(m.nFileHandle,0,2)
*!*				ELSE
*!*					m.nFileHandle=FCREATE(m.cTempFile)
*!*					m.i=0
*!*				ENDIF

*!*				IF bShowProcess
*!*					WAIT WINDOW "正在下载文件..." NOWAIT NOCLEAR
*!*				ENDIF
*!*				DO WHILE m.i<m.nTotalSize
*!*					IF bShowProcess
*!*						WAIT WINDOW "正在下载文件...完成"+TRANSFORM(INT(100.00*m.i/m.nTotalSize))+"%" NOWAIT NOCLEAR
*!*					ENDIF
*!*					LOCAL m.nBlockSize
*!*					IF m.nTotalSize-m.i>10*1024
*!*						m.nBlockSize=10*1024
*!*					ELSE
*!*						m.nBlockSize=m.nTotalSize-m.i
*!*					ENDIF

*!*					m.o= CreateObject("MSXML2.XMLHTTP")
*!*					m.o.open("GET",cUrl,.f.)
*!*					m.o.setRequestHeader("Referer",STREXTRACT(cUrl,"//","/"))
*!*					m.o.setRequestHeader("Accept", "*/*")
*!*					m.o.setRequestHeader("User-Agent","lyserver")
*!*					m.o.setRequestHeader("Range","bytes="+TRANSFORM(m.i)+"-"+TRANSFORM(m.i+m.nBlockSize-1))
*!*					m.o.setRequestHeader("Content-Type","application/octet-stream")
*!*					m.o.setRequestHeader("Pragma", "no-cache")
*!*					m.o.setRequestHeader("Cache-Control","no-cache")
*!*					m.o.send()

*!*					=FWRITE(m.nFileHandle,m.o.responseBody)
*!*					m.i = m.i + m.nBlockSize
*!*					DOEVENTS
*!*				ENDDO
*!*				IF bShowProcess
*!*					WAIT CLEAR
*!*				ENDIF
*!*				=FCLOSE(m.nFileHandle)
*!*				=APICopyFile(m.cTempFile,cLocalFile)
*!*				=APIDeleteFile(m.cTempFile)
*!*			ELSE
*!*				m.o= CreateObject("MSXML2.XMLHTTP")
*!*				m.o.open("GET",cUrl,.f.)
*!*				m.o.setRequestHeader("Referer",STREXTRACT(cUrl,"//","/"))
*!*				m.o.setRequestHeader("Accept", "*/*")
*!*				m.o.setRequestHeader("User-Agent","lyserver")
*!*				m.o.setRequestHeader("Content-Type","application/octet-stream")
*!*				m.o.setRequestHeader("Pragma", "no-cache")
*!*				m.o.setRequestHeader("Cache-Control","no-cache")
*!*				m.o.send()
*!*				=STRTOFILE(m.o.responseBody,cLocalFile)
*!*			ENDIF
*!*			m.bOK=.t.
*!*		CATCH TO oErr
*!*			m.bOK=.f.
*!*		ENDTRY

*!*		RETURN m.bOK
ENDPROC
