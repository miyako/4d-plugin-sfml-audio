$event:=Form event code:C388

Case of 
	: ($event=On Clicked:K2:4)
		
		$Settings:=OBJECT Get pointer:C1124(Object named:K67:5; "Settings")
		
		$menu_channel:=Create menu:C408
		
		APPEND MENU ITEM:C411($menu_channel; "モノラル")
		SET MENU ITEM PARAMETER:C1004($menu_channel; -1; "Sound channel count mono")
		If (OB Get:C1224($Settings->; "channelCount"; Is longint:K8:6)=Sound channel count mono)
			SET MENU ITEM MARK:C208($menu_channel; -1; Char:C90(18))
		End if 
		
		APPEND MENU ITEM:C411($menu_channel; "ステレオ")
		SET MENU ITEM PARAMETER:C1004($menu_channel; -1; "Sound channel count stereo")
		If (OB Get:C1224($Settings->; "channelCount"; Is longint:K8:6)=Sound channel count stereo)
			SET MENU ITEM MARK:C208($menu_channel; -1; Char:C90(18))
		End if 
		
		$menu_rate:=Create menu:C408
		
		APPEND MENU ITEM:C411($menu_rate; "11025")
		SET MENU ITEM PARAMETER:C1004($menu_rate; -1; "Sound sample rate 11025")
		If (OB Get:C1224($Settings->; "sampleRate"; Is longint:K8:6)=Sound sample rate 11025)
			SET MENU ITEM MARK:C208($menu_rate; -1; Char:C90(18))
		End if 
		
		APPEND MENU ITEM:C411($menu_rate; "22050")
		SET MENU ITEM PARAMETER:C1004($menu_rate; -1; "Sound sample rate 22050")
		If (OB Get:C1224($Settings->; "sampleRate"; Is longint:K8:6)=Sound sample rate 22050)
			SET MENU ITEM MARK:C208($menu_rate; -1; Char:C90(18))
		End if 
		
		APPEND MENU ITEM:C411($menu_rate; "44100")
		SET MENU ITEM PARAMETER:C1004($menu_rate; -1; "Sound sample rate 44100")
		If (OB Get:C1224($Settings->; "sampleRate"; Is longint:K8:6)=Sound sample rate 44100)
			SET MENU ITEM MARK:C208($menu_rate; -1; Char:C90(18))
		End if 
		
		$menu_mode:=Create menu:C408
		APPEND MENU ITEM:C411($menu_mode; "続けて録音する")
		SET MENU ITEM PARAMETER:C1004($menu_mode; -1; "rec.continue")
		If (Not:C34(OB Get:C1224($Settings->; "createNewRecording"; Is boolean:K8:9)))
			SET MENU ITEM MARK:C208($menu_mode; -1; Char:C90(18))
		End if 
		APPEND MENU ITEM:C411($menu_mode; "新しく録音する")
		SET MENU ITEM PARAMETER:C1004($menu_mode; -1; "rec.new")
		If (OB Get:C1224($Settings->; "createNewRecording"; Is boolean:K8:9))
			SET MENU ITEM MARK:C208($menu_mode; -1; Char:C90(18))
		End if 
		
		$menu:=Create menu:C408
		APPEND MENU ITEM:C411($menu; "チャンネル数"; $menu_channel)
		RELEASE MENU:C978($menu_channel)
		APPEND MENU ITEM:C411($menu; "サンプルレート"; $menu_rate)
		RELEASE MENU:C978($menu_rate)
		APPEND MENU ITEM:C411($menu; "モード"; $menu_mode)
		RELEASE MENU:C978($menu_mode)
		
		
		
		
		
		APPEND MENU ITEM:C411($menu; "-")
		APPEND MENU ITEM:C411($menu; Get default recording device)
		DISABLE MENU ITEM:C150($menu; -1)
		
		$command:=Dynamic pop up menu:C1006($menu)
		
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($command="Sound channel count mono")
				OB SET:C1220($Settings->; "channelCount"; Sound channel count mono)
			: ($command="Sound channel count stereo")
				OB SET:C1220($Settings->; "channelCount"; Sound channel count stereo)
			: ($command="Sound sample rate 11025")
				OB SET:C1220($Settings->; "sampleRate"; Sound sample rate 11025)
			: ($command="Sound sample rate 22050")
				OB SET:C1220($Settings->; "sampleRate"; Sound sample rate 22050)
			: ($command="Sound sample rate 44100")
				OB SET:C1220($Settings->; "sampleRate"; Sound sample rate 44100)
			: ($command="rec.continue")
				OB SET:C1220($Settings->; "createNewRecording"; False:C215)
			: ($command="rec.new")
				OB SET:C1220($Settings->; "createNewRecording"; True:C214)
		End case 
		
End case 