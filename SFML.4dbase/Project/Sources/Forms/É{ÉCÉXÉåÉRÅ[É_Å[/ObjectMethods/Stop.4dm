$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")

$event:=Form event code:C388

Case of 
	: ($event=On Clicked:K2:4)
		
		Case of 
			: (OB Get:C1224($Settings->; "status")="recording")
				
				F_REC("rec.pause"; $Settings->)
				
			: (OB Get:C1224($Settings->; "status")="playing")
				
				F_REC("play.pause"; $Settings->)
				
		End case 
		
End case 