$event:=Form event code:C388

Case of 
	: ($event=On Clicked:K2:4)
		
		C_LONGINT:C283($width; $height)
		FORM GET PROPERTIES:C674("ボリューム"; $width; $height)
		
		C_LONGINT:C283($x; $y; $b)
		MOUSE POSITION:C468($x; $y; $b; *)
		$w:=Open window:C153($x; $y; $x+$width; $y+$height; Pop up window:K34:14)
		
		//$w:=Open form window("ボリューム";Pop up form window)
		DIALOG:C40("ボリューム")
		
End case 