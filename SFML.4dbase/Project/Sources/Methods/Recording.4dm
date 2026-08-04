//%attributes = {"invisible":true}
$d:=Get default recording device

C_OBJECT:C1216($params)

OB SET:C1220($params; \
"sampleRate"; Sound sample rate 11025; \
"channelCount"; Sound channel count mono)

$error:=SOUND Start recording(JSON Stringify:C1217($params))
//-1 if !SoundBufferRecorder::isAvailable()

DELAY PROCESS:C323(Current process:C322; 60*3)

$data:=SOUND Stop recording($info)
$params:=JSON Parse:C1218($info)

$path:=System folder:C487(Desktop:K41:16)+"sample.ogg"
//omit $2 if you want to export the last buffer
EXPORT AUDIO FILE($path)

//this will clear the previous buffer
$error:=SOUND Start recording(JSON Stringify:C1217($params))
//-1 if !SoundBufferRecorder::isAvailable()

DELAY PROCESS:C323(Current process:C322; 60*3)

$more_data:=SOUND Stop recording($info)

//concatenate the buffer
COPY BLOB:C558($more_data; $data; 0; BLOB size:C605($data); BLOB size:C605($more_data))

$path:=System folder:C487(Desktop:K41:16)+"sample-2.ogg"

//specify the data, sample rate and channel count to export concatenated buffer
EXPORT AUDIO FILE($path; $data; \
OB Get:C1224($params; "sampleRate"); \
OB Get:C1224($params; "channelCount"))