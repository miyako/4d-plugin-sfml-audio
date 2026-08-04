$event:=Form event code:C388

Case of 
	: ($event=On Data Change:K2:15)
		
		SOUND SET PITCH(Self:C308->/4)
		
	: ($event=On Clicked:K2:4)
		
		ACCEPT:C269
		
End case 