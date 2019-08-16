class EXTENSION
{
	__New(dir, update_check := 1) 
	{
		add_log(5, "Creating EXTENSION Object for - " . dir)
		this.dir := dir
		IniRead, name, %dir%\manifest.ini, MAIN, name
		if (name == "ERROR") {
			add_log(3, "ERROR: Couldn't find name in manifest")
			throw
		}
		this.name := name
		add_log(5, "Extension name - " . name)
		
		;update
		IniRead, update, %dir%\manifest.ini, MAIN, update, 0
		IniRead, update_dir, %dir%\manifest.ini, MAIN, update_dir, 0
		IniRead, version, %dir%\manifest.ini, MAIN, version, 0.0.0
		this.update := update
		this.update_dir := update_dir
		this.version := version
		
		if (update and update_check) {
			add_log(5, "Autoupdate enabled. Trying to update.")
			this.update_extension() 
		} else {
			add_log(5, "Autoupdate disabled.")
		}
		
		;general
		IniRead, active, %dir%\manifest.ini, MAIN, active, 0
		IniRead, description, %dir%\manifest.ini, MAIN, description, %A_Space%
		this.active := active
		this.description := description
	}
	
	update_extension() 
	{
		add_log(5, "Updating extension - " . this.name)
		Loop {
			try {
				if !this.update_dir {
					add_log(3, "ERROR: Update Dir empty")
					throw
				}
				add_log(5, "Update Dir - " . this.update_dir)
				add_log(5, "Downloading latest manifest")
				latestManifestRaw := get(this.update_dir . "/manifest.ini")
				if ErrorLevel {
					add_log(3, "ERROR: Manifest not found")
					throw
				}
				if FileExist(A_Temp . "\ds_asm_manifest.ini") {
					add_log(5, "Deleting old temp manifest")
					FileDelete, %A_Temp%\ds_asm_manifest.ini
				}
				FileAppend, %latestManifestRaw%, %A_Temp%\ds_asm_manifest.ini, CP1200
				IniRead, latestVersionRaw, %A_Temp%\ds_asm_manifest.ini, MAIN, version, 0.0.0
				if !RegExMatch(latestVersionRaw, "^(\d+?).(\d+?).(\d+?)$", latestVersion) {
					add_log(3, "ERROR: Incorrect server extension version - " . latestVersionRaw)
					throw
				}
				add_log(5, "Latest version - " . latestVersionRaw)
				if !RegExMatch(this.version, "^(\d+?).(\d+?).(\d+?)$", currentVersion) {
					add_log(3, "ERROR: Incorrect local extension version - " . this.version)
					throw
				}
				add_log(5, "Current version - " . this.version)
			} catch {
				name := this.name
				add_log(1, "ERROR: Could not check extension updates for " . name)
				MsgBox, 50, Ошибка, Не удалось проверить наличие обновления расширения %name%.
				IfMsgBox, Abort
				{
					add_log(1, "Exiting")
					ExitApp
				}
				IfMsgBox, Retry
				{
					add_log(2, "Retrying")
					continue
				}
			}
			break
		}
		if ((latestVersion1 > currentVersion1) or (latestVersion1 = currentVersion1 and latestVersion2 > currentVersion2) or (latestVersion1 = currentVersion1 and latestVersion2 = currentVersion2 and latestVersion3 > currentVersion3)) 
		{
			add_log(3, "Update found for " . this.name)
			Loop {
				try {
					IniRead, filesRaw, %A_Temp%\ds_asm_manifest.ini, FILES
					dir := this.dir
					update_dir := this.update_dir
					Loop, Parse, filesRaw, `n, `r
					{
						if RegExMatch(A_LoopField, "^([\w\.\\]+?) (\w+?)$", file) {
							add_log(5, "Couldn't find SHA1 sum")
						} else if A_LoopField {
							file1 := A_LoopField
							file2 := 0
						} else {
							add_log(3, "No file dir given")
							throw
						}
						add_log(5, "Checking if " . file1 . " up to date")
						StringUpper, file2, file2
						if (file2 != FileSHA1(dir . "\" . file1)) {
							add_log(5, "Downloading - " . file1)
							URLDownloadToFile, %update_dir%/%file1%, %dir%\%file1%
							if ((file2 != FileSHA1(dir . "\" . file1)) and file2) {
								add_log(3, "ERROR: SHA1 sums don't match")
								throw
							}
							add_log(5, "File downloaded successfully")
						} else {
							add_log(5, "File is up to date")
						}
					}
					FileDelete, %dir%\manifest.ini
					FileAppend, %latestManifestRaw%, %dir%\manifest.ini, CP1200
				} catch {
					name := this.name
					add_log(1, "ERROR: Couldn't download extension updates for " . name)
					MsgBox, 50, Ошибка, Не удалось скачать обновления расширения %name%.
					IfMsgBox, Abort
					{
						add_log(1, "Exiting")
						ExitApp
					}
					IfMsgBox, Retry
					{
						add_log(2, "Retrying")
						continue
					}	
				}
				break
			}
			FileDelete, %A_Temp%\ds_asm_manifest.ini
			dir := this.dir
			IniRead, name, %dir%\manifest.ini, MAIN, name
			if (name == "ERROR") {
				add_log(3, "ERROR: Couldn't find name in manifest")
				throw
			}
			this.name := name
			IniRead, update, %dir%\manifest.ini, MAIN, update, 0
			IniRead, update_dir, %dir%\manifest.ini, MAIN, update_dir, 0
			IniRead, version, %dir%\manifest.ini, MAIN, version, 0.0.0
			this.update := update
			this.update_dir := update_dir
			this.version := version
			return 1
		} else {
			add_log(3, "Extension " . this.name . " up to date")
			FileDelete, %A_Temp%\ds_asm_manifest.ini
			return 0
		}
	}
	
	init_trigers() {
		dir := this.dir
		IniRead, all_sect, %dir%\manifest.ini
		this.triggers := []
		Loop, Parse, filesRaw, `n, `r
		{
			if RegExMatch(A_LoopField, "^TRIGER__(.+?)$", trigg_name) {
				add_log(5, "Loading trigger - " . trigg_name)
				IniRead, trigg_typ, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_type, 0
				IniRead, trigg_dir, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_dir, 0
				IniRead, trigg_disp_nme, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_display_name, %A_Space%
				IniRead, trigg_desc, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_description, %A_Space%
				IniRead, trigg_wait, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_wait, %A_Space%
				IniRead, trigg_prior, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_priority, %A_Space%
				IniRead, trigg_filt, %dir%\manifest.ini, TRIGER__%trigg_name%, Trigger_filter, .*
				%trigg_name% := new EXTENSION_TRIGGER(trigg_typ, trigg_dir, trigg_disp_nme, trigg_desc, trigg_wait, trigg_prior, trigg_filt)
				this.triggers.Push(%trigg_name%)
			}
		}
	}
	
}