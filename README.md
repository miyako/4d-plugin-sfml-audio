![version](https://img.shields.io/badge/version-18%2B-EB8E5F)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-32%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-tidy-html5)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-tidy-html5/total)

# 4d-plugin-sfml-audio

This plugin drives audio recording, playback, and file import/export for a 4D application, built on top of the SFML audio library (`sf::Sound`, `sf::SoundBuffer`, `sf::SoundBufferRecorder`) with OpenAL as the underlying capture-device API on Windows. It works with two distinct data shapes: raw 16-bit PCM sample data (as a `Blob`) for in-memory recording/playback, and encoded audio files on disk (WAV, OGG/Vorbis, FLAC — whatever your build of SFML supports) for import/export.

> The exact product/plugin name and version weren't included in what was provided (no `manifest.json`/`.4dp`) — confirm those against your actual plugin bundle. This reference is built directly from the plugin's C++ source and its own sample `.4dm` methods.

## Commands

| Command | Returns | Purpose |
|---|---|---|
| [`GET RECORDING DEVICES`](#get-recording-devices) | — (array, by reference) | List available microphone/capture devices |
| [`Get default recording device`](#get-default-recording-device) | Text | Name of the system's default capture device |
| [`SOUND Start recording`](#sound-start-recording) | Longint | Begin recording from the microphone |
| [`SOUND Stop recording`](#sound-stop-recording) | Blob | Stop recording, return the raw PCM audio and its metadata |
| [`SOUND SET DATA`](#sound-set-data) | — | Load an encoded audio file's bytes into the player |
| [`SOUND Get data`](#sound-get-data) | Blob | Return the currently loaded playback buffer as raw PCM |
| [`SOUND SET PITCH`](#sound-set-pitch) | — | Set playback pitch/speed |
| [`SOUND Get pitch`](#sound-get-pitch) | Real | Current playback pitch |
| [`SOUND SET VOLUME`](#sound-set-volume) | — | Set playback volume |
| [`SOUND Get volume`](#sound-get-volume) | Real | Current playback volume |
| [`SOUND Get position`](#sound-get-position) | Longint | Current playhead position (ms) |
| [`SOUND SET POSITION`](#sound-set-position) | — | Seek the playhead |
| [`SOUND SET LOOP`](#sound-set-loop) | — | Enable/disable looping |
| [`SOUND Get loop`](#sound-get-loop) | Longint | Whether looping is enabled |
| [`SOUND Get status`](#sound-get-status) | Longint | Player state (stopped/paused/playing) |
| [`SOUND Get duration`](#sound-get-duration) | Longint | Duration of the loaded buffer (ms) |
| [`SOUND Get sample rate`](#sound-get-sample-rate) | Longint | Sample rate of the loaded buffer |
| [`SOUND Get channel count`](#sound-get-channel-count) | Longint | Channel count of the loaded buffer |
| [`SOUND PLAY`](#sound-play) | — | Start/resume playback |
| [`SOUND PAUSE`](#sound-pause) | — | Pause playback |
| [`SOUND STOP`](#sound-stop) | — | Stop playback |
| [`EXPORT AUDIO FILE`](#export-audio-file) | — | Save recorded/raw audio to a file on disk |
| [`IMPORT AUDIO FILE`](#import-audio-file) | — | Load an audio file from disk into the player |

**Platforms:** macOS and Windows.

---

## Requirements & platform notes

- **Recording requires an available capture device.** Every recording/device-listing command first checks `sf::SoundBufferRecorder::isAvailable()`; if no microphone/capture backend is available, device-listing commands return an empty result and `SOUND Start recording` returns `-1` rather than raising a 4D error. Always check the return value — failure here is silent by design, not an exception.
- **`SOUND SET DATA` and `IMPORT/EXPORT AUDIO FILE` work with *encoded* audio files** (container + codec, e.g. `.wav`, `.ogg`), while **`SOUND Get data` and `SOUND Stop recording` return *raw, headerless* 16-bit PCM samples** as a `Blob`. These are not interchangeable — don't pass a `SOUND Get data` blob to `SOUND SET DATA` expecting it to play; use `EXPORT AUDIO FILE`/`IMPORT AUDIO FILE` (or set the blob directly as playback data only through the commands documented for that purpose below).
- **Device selection differs by platform.** When starting a recording with an explicit `device` name that isn't recognized/omitted, **Windows** falls back explicitly to the system's default capture device; **macOS** simply leaves the recorder on whatever device it already had. See [`SOUND Start recording`](#sound-start-recording).
- **All playback commands (`SOUND PLAY`/`PAUSE`/`STOP`/`SET PITCH`/etc.) and all recording commands act on a single, plugin-wide player/recorder instance** — there's one current playback buffer and one current recording session per 4D application, not one per process/window. If your application starts a recording or playback session from more than one process at the same time (for example, two open recording windows), the second call reuses and mutates the same underlying state as the first rather than running independently.
- **`SOUND Get status`** returns SFML's own player-state code passed straight through, unmapped by the plugin. Commonly `0` = stopped, `1` = paused, `2` = playing per SFML's `sf::SoundSource::Status` — confirm the exact values you see in practice, since the plugin doesn't reinterpret them.

---

## GET RECORDING DEVICES

### Syntax
```4d
GET RECORDING DEVICES ( arrayDevices )
```

| Parameter | Type | Description |
|---|---|---|
| `arrayDevices` | Array Text | *(by reference, filled by the command)* Receives the list of available capture-device names. |
| Result | — | No function result; the array parameter is the output. |

### Description
Fills `arrayDevices` with the names of all available audio capture (microphone) devices. If `sf::SoundBufferRecorder::isAvailable()` is false, or the platform reports no devices, the array is left as-is (empty if newly declared) rather than raising an error.

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
GET RECORDING DEVICES ($devices)
```
A fuller pattern:
```4d
ARRAY TEXT($devices; 0)
GET RECORDING DEVICES ($devices)
If (Size of array($devices) > 0)
    ALERT("Default-ish device: "+$devices{1})
End if
```

---

## Get default recording device

### Syntax
```4d
Get default recording device -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Text | Name of the system's default recording (capture) device. Empty if no capture device is available. |

### Description
Returns just the default device's name, as opposed to `GET RECORDING DEVICES`'s full list. Useful when you don't need to offer device choice to the user and just want to record from whatever the OS considers the default microphone.

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$device:=Get default recording device
```
Also used in `Recording.4dm`, where the value is read but not passed onward — the plugin's own device-selection default is used instead:
```4d
$d:=Get default recording device
```

---

## SOUND Start recording

### Syntax
```4d
SOUND Start recording ( options ) -> Result
```

| Parameter | Type | Description |
|---|---|---|
| `options` | Text | A JSON string with recording options. Every key is optional; an empty string or invalid JSON is tolerated and simply falls back to defaults. |
| Result | Longint | `-1` if no capture device is available (`sf::SoundBufferRecorder::isAvailable()` is false); `0` on success. |

**`options` JSON keys** (all optional):

| Property | Type | Description |
|---|---|---|
| `sampleRate` | Number | Capture sample rate in Hz. Defaults to `44100` if omitted. |
| `channelCount` | Number | Capture channel count. Defaults to whatever the recorder was last configured with (mono, `1`, the first time it's used). |
| `device` | String | Capture device name (as returned by `GET RECORDING DEVICES`). If omitted or not a string: **on Windows**, the recorder explicitly falls back to the system default capture device; **on macOS**, the recorder's current device is left unchanged. |

### Description
Starts a new recording session, discarding whatever the recorder previously held (see the "this will clear the previous buffer" comment in the plugin's own sample). Call [`SOUND Stop recording`](#sound-stop-recording) to end the session and retrieve the audio. The recorder runs until stopped — there's no built-in duration limit; the caller is responsible for scheduling the stop (typically via `DELAY PROCESS`, as in the sample below).

Passing a `device` name that's identical to the device currently in use is a no-op — the plugin only calls into the underlying device-switch API when the requested name actually differs from the current one.

### Example
From the plugin's own test method (`Recording.4dm`):
```4d
C_OBJECT($params)

OB SET($params; \
"sampleRate"; Sound sample rate 11025; \
"channelCount"; Sound channel count mono)

$error:=SOUND Start recording(JSON Stringify($params))
//-1 if !SoundBufferRecorder::isAvailable()

DELAY PROCESS(Current process; 60*3)
```
(`Sound sample rate 11025` and `Sound channel count mono` are 4D's own built-in constants, reused here for readability — they aren't specific to this plugin.)

Minimal call with no options (uses all defaults):
```4d
$error:=SOUND Start recording("")
```

---

## SOUND Stop recording

### Syntax
```4d
SOUND Stop recording ( info ) -> Result
```

| Parameter | Type | Description |
|---|---|---|
| `info` | Object | *(by reference, filled by the command)* Wait — see note below: the plugin actually fills a **Text** variable with a JSON string, not a native object; parse it yourself. |
| Result | Blob | Raw, headerless 16-bit signed PCM samples recorded since the last `SOUND Start recording`. |

> Correction on the parameter type: tracing the C++ (`Param1.toParamAtIndex(pParams, 1)` where `Param1` is `C_TEXT`) confirms `info` is filled with a **JSON string (Text)**, which you then parse yourself with `JSON Parse`, exactly as the plugin's own sample does. It is not filled as a native 4D object directly.

**`info` JSON shape once parsed:**

| Property | Type | Description |
|---|---|---|
| `duration` | Number | Recording duration in milliseconds. |
| `sampleRate` | Number | Sample rate of the recording. |
| `channelCount` | Number | Channel count of the recording. |
| `device` | String | Name of the device that was used. |

### Description
Stops the current recording and returns the captured audio as a raw PCM `Blob` (function result), plus a JSON string with the recording's metadata written into the `info` parameter. Calling this without a preceding `SOUND Start recording` returns an empty/zero-length result rather than raising an error.

Note for large recordings: each call copies the full recorded buffer internally before returning it, so the cost (time and memory) of this call scales with how long you recorded for.

### Example
From the plugin's own test method (`Recording.4dm`):
```4d
$data:=SOUND Stop recording($info)
$params:=JSON Parse($info)
```
Concatenating two recording sessions (also from `Recording.4dm`):
```4d
$more_data:=SOUND Stop recording($info)
COPY BLOB($more_data; $data; 0; BLOB size($data); BLOB size($more_data))
```

---

## SOUND SET DATA

### Syntax
```4d
SOUND SET DATA ( fileData )
```

| Parameter | Type | Description |
|---|---|---|
| `fileData` | Blob | The raw bytes of an **encoded audio file** (e.g. a `.wav` or `.ogg` file loaded via `DOCUMENT TO BLOB`) — not raw PCM samples. |
| Result | — | No function result. |

### Description
Loads `fileData` into the playback buffer, auto-detecting the format from the file's own container/codec headers, and immediately attaches it to the player (equivalent to what `IMPORT AUDIO FILE` does for a file already on disk). If `fileData` is empty/null, the call is a no-op and the player keeps whatever buffer it already had — this failure mode is silent, not a 4D error.

### Example
From the plugin's own test method (`Method2.4dm`), shown alongside the file-based alternative it's normally used in place of:
```4d
$path:=Get 4D folder(Current resources folder)+"sample.ogg"

If (False)
    DOCUMENT TO BLOB($path; $ogg)
    SOUND SET DATA($ogg)
Else
    IMPORT AUDIO FILE($path)
End if
```

---

## SOUND Get data

### Syntax
```4d
SOUND Get data -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Blob | Raw, headerless 16-bit signed PCM samples of the **currently loaded playback buffer** (whatever was set via `SOUND SET DATA`, `IMPORT AUDIO FILE`, or a prior recording). |

### Description
Use this to get at the decoded samples of whatever is currently loaded for playback, as opposed to `SOUND Stop recording`, which returns the samples of a just-finished *recording*. Both return the same raw PCM shape (16-bit signed, interleaved by channel), so a blob from one can be used anywhere the other's output is expected (e.g. for concatenation or re-export via `EXPORT AUDIO FILE`).

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$data:=SOUND Get data
```

---

## SOUND SET PITCH

### Syntax
```4d
SOUND SET PITCH ( pitch )
```

| Parameter | Type | Description |
|---|---|---|
| `pitch` | Real | Playback pitch multiplier. `1.0` is normal speed/pitch; higher values speed up and raise pitch, lower values slow down and lower pitch. |
| Result | — | No function result. |

### Description
Changes both the speed and pitch of playback together (this is SFML's standard pitch-shift-by-resampling behavior, not an independent time-stretch). Takes effect immediately, whether or not something is currently playing.

### Example
From the plugin's own test method (`Method2.4dm`):
```4d
SOUND SET PITCH(1.5)

SOUND SET PITCH(2)
```

---

## SOUND Get pitch

### Syntax
```4d
SOUND Get pitch -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Real | Current pitch multiplier (see `SOUND SET PITCH`). |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$pitch:=SOUND Get pitch
```

---

## SOUND SET VOLUME

### Syntax
```4d
SOUND SET VOLUME ( volume )
```

| Parameter | Type | Description |
|---|---|---|
| `volume` | Real | Playback volume, `0`–`100` (SFML's own convention; values outside that range aren't clamped by the plugin itself). |
| Result | — | No function result. |

### Example
From the plugin's own test method (`Method2.4dm`):
```4d
SOUND SET VOLUME(20)
```

---

## SOUND Get volume

### Syntax
```4d
SOUND Get volume -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Real | Current playback volume, `0`–`100`. |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$volume:=SOUND Get volume
```

---

## SOUND Get position

### Syntax
```4d
SOUND Get position -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | Current playhead position, in milliseconds. |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$position:=SOUND Get position
```

---

## SOUND SET POSITION

### Syntax
```4d
SOUND SET POSITION ( positionMS )
```

| Parameter | Type | Description |
|---|---|---|
| `positionMS` | Longint | New playhead position, in milliseconds, measured from the start of the buffer. |
| Result | — | No function result. |

### Description
Seeks playback to `positionMS`. Works whether the player is currently playing, paused, or stopped (the seek is applied on the next `SOUND PLAY`/immediately if already playing).

### Example
```4d
SOUND SET POSITION(5000)  //jump to the 5-second mark
```

---

## SOUND SET LOOP

### Syntax
```4d
SOUND SET LOOP ( loop )
```

| Parameter | Type | Description |
|---|---|---|
| `loop` | Longint | `0` to disable looping, non-zero to enable it. |
| Result | — | No function result. |

### Example
```4d
SOUND SET LOOP(1)  //enable looping
```

---

## SOUND Get loop

### Syntax
```4d
SOUND Get loop -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | `1` if looping is enabled, `0` otherwise. |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$loop:=SOUND Get loop
```

---

## SOUND Get status

### Syntax
```4d
SOUND Get status -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | The player's current state, passed straight through from SFML's `sf::SoundSource::Status`. Commonly `0` = stopped, `1` = paused, `2` = playing — verify against your own test output, since the plugin doesn't remap these. |

### Example
From the plugin's own test methods (`Method1.4dm`, `Method2.4dm`):
```4d
$status:=SOUND Get status
```

---

## SOUND Get duration

### Syntax
```4d
SOUND Get duration -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | Total duration of the **currently loaded buffer**, in milliseconds (not the position — see `SOUND Get position` for that). |

### Description
Reflects whatever is currently loaded for playback (via `SOUND SET DATA`/`IMPORT AUDIO FILE`), not a live recording in progress.

### Example
From the plugin's own test methods (`Method2.4dm`), called both before and after loading a file to show the value only becomes meaningful once something is loaded:
```4d
$d:=SOUND Get duration
...
IMPORT AUDIO FILE($path)
...
$d:=SOUND Get duration
```

---

## SOUND Get sample rate

### Syntax
```4d
SOUND Get sample rate -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | Sample rate (Hz) of the currently loaded playback buffer. |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$sampleRate:=SOUND Get sample rate
```

---

## SOUND Get channel count

### Syntax
```4d
SOUND Get channel count -> Result
```

| Parameter | Type | Description |
|---|---|---|
| Result | Longint | Channel count of the currently loaded playback buffer (e.g. `1` for mono, `2` for stereo). |

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
$channelCount:=SOUND Get channel count
```

---

## SOUND PLAY

### Syntax
```4d
SOUND PLAY
```

No parameters, no function result. Starts (or resumes, if paused) playback of the currently loaded buffer from the current position.

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
SOUND PLAY
```

---

## SOUND PAUSE

### Syntax
```4d
SOUND PAUSE
```

No parameters, no function result. Pauses playback; the playhead position is preserved for a subsequent `SOUND PLAY`.

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
SOUND PAUSE
```

---

## SOUND STOP

### Syntax
```4d
SOUND STOP
```

No parameters, no function result. Stops playback and resets the playhead to the start.

### Example
From the plugin's own test method (`Method1.4dm`):
```4d
SOUND STOP
```

---

## EXPORT AUDIO FILE

### Syntax
```4d
EXPORT AUDIO FILE ( path )
EXPORT AUDIO FILE ( path ; data ; sampleRate ; channelCount )
```

| Parameter | Type | Description |
|---|---|---|
| `path` | Text | Destination file path. The file extension (`.wav`, `.ogg`, etc.) determines the output container/codec, per SFML's format support. |
| `data` | Blob | *(optional, but see note below)* Raw 16-bit PCM samples to export, e.g. from `SOUND Stop recording` or `SOUND Get data`. |
| `sampleRate` | Longint | *(optional, only meaningful together with `data`)* Sample rate of `data`, in Hz. |
| `channelCount` | Longint | *(optional, only meaningful together with `data`)* Channel count of `data`. |
| Result | — | No function result. |

### Description
Two distinct usages, both confirmed directly in the plugin's own sample code:
- **Called with just `path`:** exports whatever the *current recorder's* buffer holds (i.e. the last completed recording) directly to `path`.
- **Called with all four parameters:** exports the raw PCM `data` blob you supply — interpreted at `sampleRate`/`channelCount` — to `path`, instead of the recorder's own buffer. This is how you export a manually concatenated recording (see the two-session example under [`SOUND Stop recording`](#sound-stop-recording)).

`data`, `sampleRate`, and `channelCount` should be supplied together or not at all — the plugin doesn't currently validate `sampleRate`/`channelCount` before use, so passing `data` with a zero or unset `sampleRate`/`channelCount` is unsupported and best avoided.

### Example
From the plugin's own test method (`Recording.4dm`), both forms:
```4d
$path:=System folder(Desktop)+"sample.ogg"
//omit $2 if you want to export the last buffer
EXPORT AUDIO FILE($path)
```
```4d
$path:=System folder(Desktop)+"sample-2.ogg"
//specify the data, sample rate and channel count to export concatenated buffer
EXPORT AUDIO FILE($path; $data; \
OB Get($params; "sampleRate"); \
OB Get($params; "channelCount"))
```

---

## IMPORT AUDIO FILE

### Syntax
```4d
IMPORT AUDIO FILE ( path )
```

| Parameter | Type | Description |
|---|---|---|
| `path` | Text | Path to an audio file on disk (format auto-detected from the file itself, per SFML's supported formats). |
| Result | — | No function result. |

### Description
Loads the file at `path` into the playback buffer and attaches it to the player in one step — equivalent to reading the file into a blob and calling `SOUND SET DATA`, but from a path instead of an in-memory blob. If the file doesn't exist or is an unsupported format, the load fails silently and the player keeps whatever buffer it had before.

### Example
From the plugin's own test method (`Method2.4dm`):
```4d
$path:=Get 4D folder(Current resources folder)+"sample.ogg"
IMPORT AUDIO FILE($path)
```

---

## Error handling & troubleshooting

- **No microphone/capture device available is not a 4D error.** `SOUND Start recording` returns `-1` (not an exception, not an `On Error Call` trigger) when `sf::SoundBufferRecorder::isAvailable()` is false. Always check the return value before assuming a recording session started.
- **File load/save failures are silent.** `SOUND SET DATA`, `IMPORT AUDIO FILE`, and `EXPORT AUDIO FILE` don't report success/failure back to 4D — a bad path, missing file, or unsupported/corrupt format simply leaves the player/exported file unchanged, with no error raised. If a load appears to have no effect, check `SOUND Get duration`/`SOUND Get sample rate` afterward to confirm something actually loaded, or verify the file exists and its extension matches a format SFML supports before calling.
- **Don't mix encoded-file blobs with raw-PCM blobs.** `SOUND SET DATA` expects the bytes of a whole encoded audio file; `SOUND Get data`/`SOUND Stop recording` return headerless raw PCM. Passing one where the other is expected won't raise an error — it will just produce nonsense audio or fail to decode.
- **Recording and playback share single, plugin-wide state.** There's one recorder and one player for the whole plugin instance, not one per process. Coordinate access if your application can trigger recording or playback from more than one process at a time.
- **`device` in `SOUND Start recording`'s options is matched by exact name**, and re-selecting the currently active device is a no-op. If you're not hearing a device switch take effect, confirm the name you're passing exactly matches one of the strings returned by `GET RECORDING DEVICES`.
- **`SOUND Get status` values aren't remapped by the plugin** — you're reading SFML's own status code directly. Don't hardcode assumptions about the exact integers without confirming them against your own test output.

---

## Quick reference

```4d
// List devices, record for 3 minutes, export
ARRAY TEXT($devices; 0)
GET RECORDING DEVICES($devices)

C_OBJECT($opts)
OB SET($opts; "sampleRate"; 44100; "channelCount"; 1)
$error:=SOUND Start recording(JSON Stringify($opts))
DELAY PROCESS(Current process; 60*3)
$data:=SOUND Stop recording($info)

$path:=System folder(Desktop)+"recording.ogg"
EXPORT AUDIO FILE($path)

// Load and play a file
IMPORT AUDIO FILE($path)
SOUND SET VOLUME(80)
SOUND SET PITCH(1)
SOUND PLAY

// Poll playback state
Case of
    : (SOUND Get status=2)  //playing
    : (SOUND Get status=1)  //paused
    : (SOUND Get status=0)  //stopped
End case
```
