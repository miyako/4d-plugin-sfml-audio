$event:=Form event code:C388

Case of 
	: ($event=On Load:K2:1)
		
		$Pitch:=OBJECT Get pointer:C1124(Object named:K67:5; "Pitch")
		$Pitch->:=4*SOUND Get pitch
		
	: ($event=On Unload:K2:2)
		
End case 