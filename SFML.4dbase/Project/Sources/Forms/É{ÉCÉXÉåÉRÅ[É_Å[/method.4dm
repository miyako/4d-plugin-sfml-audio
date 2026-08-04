$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")

$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		
		OBJECT SET ENABLED:C1123(*; "Progress"; False:C215)
		$Progress:=OBJECT Get pointer:C1124(Object named:K67:5; "Progress")
		$Progress->:=0
		
		OBJECT SET ENABLED:C1123(*; "Rec"; True:C214)
		OBJECT SET ENABLED:C1123(*; "Stop"; False:C215)
		OBJECT SET ENABLED:C1123(*; "Play"; False:C215)
		
		OBJECT SET SHORTCUT:C1185(*; "Rec"; "1"; Command key mask:K16:1)
		OBJECT SET SHORTCUT:C1185(*; "Stop"; "2"; Command key mask:K16:1)
		OBJECT SET SHORTCUT:C1185(*; "Play"; "3"; Command key mask:K16:1)
		
		$modifierName:=Choose:C955(Folder separator:K24:12=":"; "command"; "control")+"+"
		
		OBJECT SET HELP TIP:C1181(*; "Rec"; $modifierName+"1")
		OBJECT SET HELP TIP:C1181(*; "Stop"; $modifierName+"2")
		OBJECT SET HELP TIP:C1181(*; "Play"; $modifierName+"3")
		
		$Settings->:=JSON Parse:C1218("{}")
		
		$UUID:=Generate UUID:C1066
		
		OB SET:C1220($Settings->; \
			"sampleRate"; Sound sample rate 11025; \
			"channelCount"; Sound channel count mono; \
			"filePath"; Temporary folder:C486+$UUID+".frames"; \
			"audioFilePath"; Temporary folder:C486+$UUID+".ogg"; \
			"status"; "idle"; \
			"fresh"; False:C215; \
			"createNewRecording"; False:C215)  //append by default
		
		OB SET NULL:C1233($Settings->; "startTime")
		OB SET NULL:C1233($Settings->; "startTimeMS")
		OB SET NULL:C1233($Settings->; "lastSampleTimeMS")
		OB SET NULL:C1233($Settings->; "durationMS")
		OB SET NULL:C1233($Settings->; "approximateDurationMS")
		OB SET NULL:C1233($Settings->; "dataLength")
		OB SET NULL:C1233($Settings->; "totalDataLength")
		OB SET NULL:C1233($Settings->; "playPositionMS")
		
	: ($event=On Unload:K2:2)
		
		Case of 
				
			: (OB Get:C1224($Settings->; "status")="playing")
				
				F_REC("play.quit"; $Settings->)
				
			: (OB Get:C1224($Settings->; "status")="recording")
				
				F_REC("rec.quit"; $Settings->)
				
		End case 
		
End case 