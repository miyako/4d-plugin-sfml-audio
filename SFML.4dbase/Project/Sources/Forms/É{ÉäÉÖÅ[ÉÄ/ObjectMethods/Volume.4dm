$event:=Form event code:C388

Case of 
	: ($event=On Data Change:K2:15)
		
		SOUND SET VOLUME(Self:C308->)
		
	: ($event=On Clicked:K2:4)
		
		ACCEPT:C269
		
End case 