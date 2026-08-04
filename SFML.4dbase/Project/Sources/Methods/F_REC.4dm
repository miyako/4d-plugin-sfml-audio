//%attributes = {"invisible":true}
$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")
$TimeElapsed:=OBJECT Get pointer:C1124(Object named:K67:5; "TimeElapsed")
$PlayPosition:=OBJECT Get pointer:C1124(Object named:K67:5; "PlayPosition")
$Progress:=OBJECT Get pointer:C1124(Object named:K67:5; "Progress")

C_TEXT:C284($1; $command)
C_OBJECT:C1216(${2})

$command:=$1
$params:=$2

Case of 
	: ($command="playing")
		
		If (OB Get:C1224($Settings->; "status"; Is text:K8:3)="playing")
			$PlayPosition->:=OB Get:C1224($params; "playPositionMS"; Is real:K8:4)/1000
			$Settings->:=$params
			
			$durationMS:=OB Get:C1224($params; "durationMS"; Is real:K8:4)/1000
			
			$Progress->:=($PlayPosition->/$durationMS)*100
			
		Else 
			//late call
		End if 
		
	: ($command="play.start")
		
		$filePath:=OB Get:C1224($Settings->; "filePath"; Is text:K8:3)
		$audioFilePath:=OB Get:C1224($Settings->; "audioFilePath"; Is text:K8:3)
		
		If (OB Get:C1224($Settings->; "fresh"; Is boolean:K8:9))
			If (Test path name:C476($filePath)=Is a document:K24:1)
				DOCUMENT TO BLOB:C525($filePath; $data)
				EXPORT AUDIO FILE($audioFilePath; $data; OB Get:C1224($Settings->; "sampleRate"); OB Get:C1224($Settings->; "channelCount"))
				IMPORT AUDIO FILE($audioFilePath)
				OB SET:C1220($Settings->; "fresh"; False:C215)
			End if 
		End if 
		
		OBJECT SET ENABLED:C1123(*; "Play"; False:C215)
		OBJECT SET ENABLED:C1123(*; "Rec"; False:C215)
		OBJECT SET ENABLED:C1123(*; "Stop"; True:C214)
		OBJECT SET ENABLED:C1123(*; "Progress"; True:C214)
		
		OB SET:C1220($Settings->; "status"; "playing"; "durationMS"; SOUND Get duration)
		
		$PlayPosition->:=SOUND Get position/1000
		$Progress->:=$PlayPosition->/(SOUND Get duration/1000)*100
		
		SOUND PLAY
		
		CALL WORKER:C1389("REC"; "W_REC"; "play.start"; Current process name:C1392; Current form window:C827; $Settings->)
		
	: ($command="play.pause")
		
		SOUND PAUSE
		
		F_REC("play.stop"; $params)
		
		$PlayPosition->:=SOUND Get position/1000
		
		CALL WORKER:C1389("REC"; "W_REC"; "play.stop"; Current process name:C1392; Current form window:C827; $params)
		
	: ($command="play.end")
		
		F_REC("play.stop"; $params)
		
		$PlayPosition->:=SOUND Get duration/1000
		
		SOUND SET POSITION(0)
		
		$Progress->:=100
		
	: ($command="play.stop")
		
		OB SET:C1220($params; "status"; "stopped")
		
		OBJECT SET ENABLED:C1123(*; "Stop"; False:C215)
		OBJECT SET ENABLED:C1123(*; "Rec"; True:C214)
		OBJECT SET ENABLED:C1123(*; "Play"; True:C214)
		OBJECT SET ENABLED:C1123(*; "Progress"; True:C214)
		
		$PlayPosition->:=OB Get:C1224($params; "durationMS"; Is real:K8:4)/1000
		$Settings->:=$params
		
	: ($command="play.quit")
		
		F_REC("play.stop"; $params)
		
		CALL WORKER:C1389("REC"; "W_REC"; "play.quit"; Current process name:C1392; Current form window:C827; $params)
		
	: ($command="recording")
		
		If (OB Get:C1224($Settings->; "status"; Is text:K8:3)="recording")
			$TimeElapsed->:=OB Get:C1224($params; "approximateDurationMS"; Is real:K8:4)/1000
			$Settings->:=$params
		Else 
			//late call
		End if 
		
	: ($command="rec.start")
		
		If (0=SOUND Start recording(JSON Stringify:C1217($params)))
			
			OBJECT SET ENABLED:C1123(*; "Rec"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Stop"; True:C214)
			OBJECT SET ENABLED:C1123(*; "Play"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Progress"; False:C215)
			
			$Progress->:=0
			
			If (OB Get:C1224($params; "createNewRecording"; Is boolean:K8:9))
				$TimeElapsed->:=0
				$PlayPosition->:=0
				OB SET NULL:C1233($Settings->; "dataLength")
				OB SET NULL:C1233($Settings->; "totalDataLength")
				OB SET NULL:C1233($Settings->; "playPositionMS")
			End if 
			
			OB SET:C1220($params; "status"; "recording")
			
			$startTime:=String:C10(Current date:C33; ISO date GMT:K1:10; Current time:C178)
			$startTimeMS:=Current time:C178
			
			If (OB Get:C1224($params; "createNewRecording"; Is boolean:K8:9)) | (OB Get type:C1230($params; "startTime")=Is null:K8:31)
				OB SET NULL:C1233($Settings->; "durationMS")
				OB SET NULL:C1233($Settings->; "approximateDurationMS")
				OB SET:C1220($params; "startTime"; $startTime)
			End if 
			
			OB SET:C1220($params; "startTimeMS"; $startTimeMS; "lastSampleTimeMS"; $startTimeMS; "fresh"; True:C214)
			
			CALL WORKER:C1389("REC"; "W_REC"; "rec.start"; Current process name:C1392; Current form window:C827; $params)
			
		Else 
			
			//error
			OBJECT SET ENABLED:C1123(*; "Stop"; False:C215)
			OBJECT SET ENABLED:C1123(*; "Rec"; True:C214)
			OBJECT SET ENABLED:C1123(*; "Play"; OB Get:C1224($params; "durationMS"; Is real:K8:4)#0)
			OBJECT SET ENABLED:C1123(*; "Progress"; OB Get:C1224($params; "durationMS"; Is real:K8:4)#0)
			
		End if 
		
		$Settings->:=$params
		
	: ($command="rec.pause")
		
		F_REC("rec.stop"; $params)
		
		CALL WORKER:C1389("REC"; "W_REC"; "rec.stop"; Current process name:C1392; Current form window:C827; $params)
		
	: ($command="rec.quit")
		
		F_REC("rec.stop"; $params)
		
		CALL WORKER:C1389("REC"; "W_REC"; "rec.quit"; Current process name:C1392; Current form window:C827; $params)
		
	: ($command="rec.stop")
		
		OB SET:C1220($params; "status"; "stopped")
		
		C_TEXT:C284($json)
		C_BLOB:C604($frames)
		
		$frames:=SOUND Stop recording($json)
		
		C_OBJECT:C1216($info)
		$info:=JSON Parse:C1218($json)
		
		C_REAL:C285($durationMS)
		$durationMS:=OB Get:C1224($params; "durationMS"; Is real:K8:4)
		$durationMS:=$durationMS+OB Get:C1224($info; "duration"; Is real:K8:4)
		OB SET:C1220($params; "durationMS"; $durationMS; "approximateDurationMS"; $durationMS)
		
		$TimeElapsed->:=$durationMS/1000
		
		$filePath:=OB Get:C1224($params; "filePath"; Is text:K8:3)
		
		If (OB Get:C1224($params; "createNewRecording"; Is boolean:K8:9))
			BLOB TO DOCUMENT:C526($filePath; $frames)
		Else 
			If (Test path name:C476($filePath)=Is a document:K24:1)
				$docRef:=Append document:C265($filePath)
				If (OK=1)
					SEND PACKET:C103($docRef; $frames)
					CLOSE DOCUMENT:C267($docRef)
				Else 
					//Append document failed
				End if 
			Else 
				BLOB TO DOCUMENT:C526($filePath; $frames)
			End if 
		End if 
		
		If (Test path name:C476($filePath)=Is a document:K24:1)
			OB SET:C1220($params; "totalDataLength"; Get document size:C479($filePath))
		Else 
			OB SET NULL:C1233($params; "totalDataLength")
		End if 
		
		OB SET:C1220($params; "dataLength"; BLOB size:C605($frames))
		
		$TimeElapsed->:=$durationMS/1000
		
		OBJECT SET ENABLED:C1123(*; "Stop"; False:C215)
		OBJECT SET ENABLED:C1123(*; "Rec"; True:C214)
		OBJECT SET ENABLED:C1123(*; "Play"; $TimeElapsed->#0)
		OBJECT SET ENABLED:C1123(*; "Progress"; $TimeElapsed->#0)
		
		$Settings->:=$params
		
End case 