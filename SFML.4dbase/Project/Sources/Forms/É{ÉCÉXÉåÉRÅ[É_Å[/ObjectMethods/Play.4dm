$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")

$event:=Form event code:C388

Case of 
	: ($event=On Clicked:K2:4)
		
		F_REC("play.start"; $Settings->)
		
End case 