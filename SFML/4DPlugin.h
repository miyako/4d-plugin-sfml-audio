/* --------------------------------------------------------------------------------
 #
 #	4DPlugin.h
 #	source generated by 4D Plugin Wizard
 #	Project : SFML
 #	author : miyako
 #	2017/06/26
 #
 # --------------------------------------------------------------------------------*/

#include "SFML/Config.hpp"
#include "SFML/Audio.hpp"

#define USE_JSON_CPP 1

#if USE_JSON_CPP
#include "json/json.h"
#else
#include "libjson/libjson.h"
#endif

// --- AUDIO
void GET_RECORDING_DEVICES(sLONG_PTR *pResult, PackagePtr pParams);
void Get_default_recording_device(sLONG_PTR *pResult, PackagePtr pParams);

// --- Recording
void SOUND_Start_recording(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Stop_recording(PA_PluginParameters params);

// --- Playing
void SOUND_SET_DATA(PA_PluginParameters params);
void SOUND_Get_data(PA_PluginParameters params);

void SOUND_SET_PITCH(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_status(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_pitch(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_SET_VOLUME(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_volume(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_position(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_SET_POSITION(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_SET_LOOP(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_loop(sLONG_PTR *pResult, PackagePtr pParams);

void SOUND_Get_duration(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_sample_rate(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_Get_channel_count(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_PLAY(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_PAUSE(sLONG_PTR *pResult, PackagePtr pParams);
void SOUND_STOP(sLONG_PTR *pResult, PackagePtr pParams);

// --- Import and Export
void EXPORT_AUDIO_FILE(PA_PluginParameters params);
void IMPORT_AUDIO_FILE(PA_PluginParameters params);
