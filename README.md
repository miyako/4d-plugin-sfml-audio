# 4d-plugin-sfml-audio
Record and play wave audio. 

Using [Simple and Fast Multimedia Library](https://www.sfml-dev.org/index.php).

The plugin can **play** one audio file at a time. Support file formats are ``WAV``, ``OGG/Vorbis``, and ``FLAC``. You can load the data using either ``IMPORT AUDIO FILE`` or ``SOUND SET DATA``.

The plugin can **record** from one audio capture device at a time. Every time the recording is stopped, a BLOB of sampling frames is returned. You can concatenate such BLOBs with ``COPY BLOB``. When done, use the ``EXPORT AUDIO FILE`` command to create a ``WAV``, ``OGG/Vorbis``, or ``FLAC`` file.

Although SFML supports threading, the plugin will play just one audio file at a time.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|

### Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" />

## Syntax

```
GET RECORDING DEVICES (devices)
```

Parameter|Type|Description
------------|------------|----
devices|ARRAY TEXT|

```
device:=Get default recording device
```

Parameter|Type|Description
------------|------------|----
device|TEXT|

```
error:=SOUND Start recording (params)
```

Parameter|Type|Description
------------|------------|----
params|TEXT|JSON
error|LONGINT|``-1`` if recording is not available

```
data:=SOUND Stop recording (params)
```

Parameter|Type|Description
------------|------------|----
params|TEXT|JSON
data|BLOB|Sample frame data (array of ``Int16``)

```
SOUND STOP
SOUND PAUSE
SOUND PLAY
```

```
SOUND SET DATA (data)
data:=SOUND Get data
```

Parameter|Type|Description
------------|------------|----
data|BLOB|``WAV``, ``OGG/Vorbis``, or ``FLAC`` data

```
SOUND SET PITCH (pitch)
pitch:=SOUND Get pitch
```

Parameter|Type|Description
------------|------------|----
pitch|REAL|Perceived fundamental frequency of a sound. Default is ``1``. Changing the pitch modifies the playing speed too.

```
SOUND SET VOLUME (volume)
volume:=SOUND Get volume
```

Parameter|Type|Description
------------|------------|----
volume|REAL|Volume between ``0`` (mute) and ``100`` (full volume).

```
SOUND SET POSITION (position)
position:=SOUND Get position
```

Parameter|Type|Description
------------|------------|----
position|LONGINT|Current playing position milliseconds

```
IMPORT AUDIO FILE (path;data)
```

Parameter|Type|Description
------------|------------|----
path|TEXT|
data|BLOB|``WAV``, ``OGG/Vorbis``, or ``FLAC`` data

```
EXPORT AUDIO FILE (path;data;sampleRate;channelCount)
```

Parameter|Type|Description
------------|------------|----
path|TEXT|
data|BLOB|Sample frame data (array of ``Int16``)
sampleRate|LONGINT|
channelCount|LONGINT|

```
status:=SOUND Get status
```

Parameter|Type|Description
------------|------------|----
status|LONGINT|``Sound status stopped 0``, ``Sound status paused 1``, ``Sound status playing 2``

```
SOUND SET LOOP (loop)
loop:=SOUND Get loop
```

Parameter|Type|Description
------------|------------|----
loop|LONGINT|

duration:=SOUND Get duration

Parameter|Type|Description
------------|------------|----
duration|LONGINT|Duration in milliseconds

```
sampleRate:=SOUND Get sample rate
```

Parameter|Type|Description
------------|------------|----
sampleRate|LONGINT|

```
channelCount:=SOUND Get channel count
```

Parameter|Type|Description
------------|------------|----
channelCount|LONGINT|
