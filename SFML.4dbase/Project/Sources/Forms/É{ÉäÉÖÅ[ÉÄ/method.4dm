$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		
		$Volume:=OBJECT Get pointer:C1124(Object named:K67:5; "Volume")
		$Volume->:=SOUND Get volume
		
	: ($event=On Unload:K2:2)
		
End case 