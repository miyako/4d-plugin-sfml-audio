# 4d-plugin-sfml-audio

Record and play wave audio. 

Using [Simple and Fast Multimedia Library](https://www.sfml-dev.org/index.php).

Updated to SFML ``2.5.1``

The plugin can **play** one audio file at a time. Support file formats are ``WAV``, ``OGG/Vorbis``, and ``FLAC``. You can load the data using either ``IMPORT AUDIO FILE`` or ``SOUND SET DATA``.

The plugin can **record** from one audio capture device at a time. Every time the recording is stopped, a BLOB of sampling frames is returned. You can concatenate such BLOBs with ``COPY BLOB``. When done, use the ``EXPORT AUDIO FILE`` command to create a ``WAV``, ``OGG/Vorbis``, or ``FLAC`` file.

![version](https://img.shields.io/badge/version-18%2B-EB8E5F)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-32%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-tidy-html5)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-tidy-html5/total)

### Remarks for Apple Silicon

* accept arm64 as valid architecture (or just fix in Xcode)

```
# only the default architecture (i.e. 64-bit) is supported
    if(NOT CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
        message(FATAL_ERROR "Only 64-bit architecture is supported")
    endif()
```


### Screenshot

<img width="505" alt="screenshot" src="https://user-images.githubusercontent.com/1725068/28803879-951a2e96-769a-11e7-96dc-9d3c2f0a98b8.png">

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
