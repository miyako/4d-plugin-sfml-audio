//%attributes = {"invisible":true}
C_TEXT:C284($1; $command)
C_TEXT:C284($2; $callerProcessName)
C_LONGINT:C283($3; $callerFormWindow)
C_OBJECT:C1216(${4})

$command:=$1
$callerProcessName:=$2
$callerFormWindow:=$3
$params:=$4

C_TEXT:C284(REC_STATUS)

Case of 
	: ($command="playing")
		
		OB SET:C1220($params; "playPositionMS"; SOUND Get position)
		
		$status:=SOUND Get status
		
		Case of 
			: ($status=Sound status playing)
				
				CALL WORKER:C1389(Current process name:C1392; Current method name:C684; "playing"; $callerProcessName; $callerFormWindow; $params)
				CALL FORM:C1391($callerFormWindow; "F_REC"; "playing"; $params)
				DELAY PROCESS:C323(Current process:C322; 15)
				
			: ($status=Sound status paused)
				
			: ($status=Sound status stopped)
				
				CALL FORM:C1391($callerFormWindow; "F_REC"; "play.end"; $params)
				
		End case 
		
	: ($command="play.start")
		
		CALL WORKER:C1389(Current process name:C1392; Current method name:C684; "playing"; $callerProcessName; $callerFormWindow; $params)
		
	: ($command="recording")
		
		If (REC_STATUS="recording")
			
			$lastSampleTimeMS:=Current time:C178
			
			C_REAL:C285($durationMS)
			$durationMS:=OB Get:C1224($params; "approximateDurationMS"; Is real:K8:4)
			$durationMS:=$durationMS+(($lastSampleTimeMS*1000)-OB Get:C1224($params; "lastSampleTimeMS"; Is real:K8:4))
			OB SET:C1220($params; "approximateDurationMS"; $durationMS; "lastSampleTimeMS"; $lastSampleTimeMS)
			
			CALL FORM:C1391($callerFormWindow; "F_REC"; "recording"; $params)
			
			CALL WORKER:C1389(Current process name:C1392; Current method name:C684; "recording"; $callerProcessName; $callerFormWindow; $params)
			
			DELAY PROCESS:C323(Current process:C322; 15)
			
		End if 
		
	: ($command="rec.start")
		
		REC_STATUS:="recording"
		
		CALL WORKER:C1389(Current process name:C1392; Current method name:C684; "recording"; $callerProcessName; $callerFormWindow; $params)
		
	: ($command="play.stop")
		
		REC_STATUS:="stopped"
		
	: ($command="rec.stop")
		
		REC_STATUS:="stopped"
		
	: ($command="play.quit")
		
		KILL WORKER:C1390
		
	: ($command="rec.quit")
		
		KILL WORKER:C1390
		
End case 