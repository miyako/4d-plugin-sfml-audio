$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")

$event:=Form event code:C388

Case of 
	: ($event=On Data Change:K2:15)
		
		SOUND SET POSITION((Self:C308->/100)*SOUND Get duration)
		
	: ($event=On Clicked:K2:4)
		
		If (Sound status playing#SOUND Get status)
			F_REC("play.start"; $Settings->)
		End if 
		
End case 