//%attributes = {"invisible":true}
C_TEXT:C284($1; $command)
C_TEXT:C284($2; $callerProcessName)
C_LONGINT:C283($3; $callerFormWindow)
C_OBJECT:C1216(${4})

$command:=$1
$callerProcessName:=$2
$callerFormWindow:=$3
$params:=$4


Case of 
	: ($command="playing")
		
		
		
		
	: ($command="play.quit")
		
		REC_STATUS:="stopped"
		
		KILL WORKER:C1390
		
	: ($command="rec.stop")
		
		REC_STATUS:="stopped"
		
		C_TEXT:C284($json)
		REC_BUFFER:=SOUND Stop recording($json)
		
		If (False:C215)
			C_OBJECT:C1216($info)
			$info:=JSON Parse:C1218($json)
		End if 
		
		C_LONGINT:C283($durationMS)
		$lastSampleTimeMS:=Current time:C178
		$durationMS:=OB Get:C1224($params; "durationMS"; Is longint:K8:6)
		$durationMS:=$durationMS+(($lastSampleTimeMS*1000)-OB Get:C1224($params; "lastSampleTimeMS"; Is longint:K8:6))
		OB SET:C1220($params; "durationMS"; $durationMS; "lastSampleTimeMS"; $lastSampleTimeMS)
		
		If (OB Get:C1224($params; "createNewRecording"; Is boolean:K8:9))
			BLOB TO DOCUMENT:C526(REC_FILE_PATH; REC_BUFFER)
		Else 
			
			If (Test path name:C476(REC_FILE_PATH)=Is a document:K24:1)
				$docRef:=Append document:C265(REC_FILE_PATH)
				If (OK=1)
					SEND PACKET:C103($docRef; REC_BUFFER)
					CLOSE DOCUMENT:C267($docRef)
				Else 
					
				End if 
			Else 
				BLOB TO DOCUMENT:C526(REC_FILE_PATH; REC_BUFFER)
			End if 
		End if 
		
		If (Test path name:C476(REC_FILE_PATH)=Is a document:K24:1)
			OB SET:C1220($params; "totalDataLength"; Get document size:C479(REC_FILE_PATH))
		Else 
			OB SET NULL:C1233($params; "totalDataLength")
		End if 
		
		OB SET:C1220($params; \
			"status"; REC_STATUS; \
			"dataLength"; BLOB size:C605(REC_BUFFER))
		
		CLEAR VARIABLE:C89(REC_BUFFER)
		
		CALL FORM:C1391($callerFormWindow; "F_REC"; "rec.stop"; $params)
		
	: ($command="rec.start")
		
		REC_FILE_PATH:=OB Get:C1224($params; "filePath"; Is text:K8:3)
		CLEAR VARIABLE:C89(REC_BUFFER)
		
		$error:=SOUND Start recording(JSON Stringify:C1217($params))
		
		Case of 
			: ($error=0)
				
				REC_STATUS:="recording"
				
				OB SET:C1220($params; "status"; REC_STATUS)
				
				$startTime:=String:C10(Current date:C33; ISO date GMT:K1:10; Current time:C178)
				$lastSampleTimeMS:=Current time:C178
				
				If (OB Get:C1224($params; "createNewRecording"; Is boolean:K8:9)) | (OB Get type:C1230($params; "startTime")=Is null:K8:31)
					OB SET:C1220($params; "startTime"; $startTime; "startTimeMS"; $lastSampleTimeMS; "durationMS"; 0)
				End if 
				
				OB SET:C1220($params; "lastSampleTimeMS"; $lastSampleTimeMS; "fresh"; True:C214)
				
				CALL FORM:C1391($callerFormWindow; "F_REC"; "rec.start.success"; $params)
				
				CALL WORKER:C1389(Current process name:C1392; Current method name:C684; "recording"; $callerProcessName; $callerFormWindow; $params)
				
			Else 
				
				REC_STATUS:="idle"
				
				OB SET:C1220($params; "error"; $error; "status"; REC_STATUS)
				CALL FORM:C1391($callerFormWindow; "F_REC"; "rec.start.failure"; $params)
				
		End case 
		
End case 