//%attributes = {"invisible":true}
$d:=SOUND Get duration

$path:=Get 4D folder:C485(Current resources folder:K5:16)+"sample.ogg"

If (False:C215)
	DOCUMENT TO BLOB:C525($path; $ogg)
	SOUND SET DATA($ogg)
Else 
	IMPORT AUDIO FILE($path)
End if 

$d:=SOUND Get duration

SOUND PLAY

SOUND SET PITCH(1.5)

SOUND SET PITCH(2)

SOUND SET VOLUME(20)

SOUND PAUSE

SOUND PLAY

SOUND STOP

$status:=SOUND Get status
