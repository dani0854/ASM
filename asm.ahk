#NoEnv
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input
#Include %A_ScriptDir%\library\log.ahk


global LibDir
RegRead, LibDir, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, LibraryDir
MsgBox Hello World
return
if FileExist(A_ScriptDir . "\log.txt") {
	FileDelete, %A_ScriptDir%\log.txt
}

FileMD5(sFile="", cSz=4) {  ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
 cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 18-Jun-2009
 hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
 IfLess,hFil,1, Return,hFil
 hMod := DllCall( "LoadLibrary", Str,"advapi32.dll" )
 DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
 VarSetCapacity( MD5_CTX,104,0 ),    DllCall( "advapi32\MD5Init", UInt,&MD5_CTX )
 Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
   DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
 , DllCall( "advapi32\MD5Update", UInt,&MD5_CTX, UInt,&Buffer, UInt,bytesRead )
 DllCall( "advapi32\MD5Final", UInt,&MD5_CTX )
 DllCall( "CloseHandle", UInt,hFil )
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
Return MD5, DllCall( "FreeLibrary", UInt,hMod )
}

get(url)
{
	add_log(4, "GET request from: " . url)
    loop 5
    {
		add_log(5, "Creating COM Object")
        ComObjError(false)
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url)
        whr.WaitForResponse(5)
        whr.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 YaBrowser/17.6.1.744 Yowser/2.5 Safari/537.36")
        whr.Send()
		add_log(5, "Sending request")
        if(!strlen(whr.ResponseText)) {
			add_log(5, "ERROR: Empty response, retrying.")
            continue
		}
		add_log(5, "Response received")
        return whr.ResponseText
    }
	add_log(5, "ERROR: No response received after 5 requests.")
	ErrorLevel := 1
	return
}


add_log(1, "ASM started")
add_log(1, "Checking: " . A_ScriptDir . "\config.ini")
if !FileExist(A_ScriptDir . "\config.ini") {
	add_log(1, "ERROR: " . A_ScriptDir . "\config.ini not found")
	add_log(1, "Executing: " . A_ScriptDir . "\update.exe")
	try {
		add_log(3, "Trying executing as admin: " . A_ScriptDir . "\update.exe")
		Run, *RunAs %A_ScriptDir%\update.exe
	} catch {
		add_log(3, "ERROR: Could not execute as admin: " . A_ScriptDir . "\update.exe")
		add_log(3, "Executing normaly: " . A_ScriptDir . "\update.exe")
		Run, %A_ScriptDir%\update.exe
	}
	add_log(1, "Exiting")
	ExitApp
}

add_log(2, "Checking, if autoupdate enabled")
IniRead, autoUpdate, %A_ScriptDir%\config.ini, Main, update
if autoUpdate { ; Auto update
	add_log(2, "Autoupdate enabled")
	add_log(1, "Checking updates")
	
	Loop {
		try {
			add_log(3, "Getting current version")
			RegRead, currentVersionRaw, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, version
			if !RegExMatch(currentVersionRaw, "^(\d+?).(\d+?).(\d+?)$", currentVersion) {
				add_log(2, "ERROR: Incorrect local asm version - " . currentVersionRaw)
				throw
			}
			add_log(3, "Current version - " . currentVersionRaw)
			add_log(3, "Getting latest version")
			latestVersionRaw := get("https://doshik-soft.ru/asm/version.txt")
			if !RegExMatch(latestVersionRaw, "^(\d+?).(\d+?).(\d+?)$", latestVersion) {
				add_log(2, "ERROR: Incorrect server asm version - " . latestVersionRaw)
				throw
			}
			add_log(3, "Latest version - " . latestVersionRaw)
			if ((latestVersion1 > currentVersion1) or (latestVersion1 = currentVersion1 and latestVersion2 > currentVersion2) or (latestVersion1 = currentVersion1 and latestVersion2 = currentVersion2 and latestVersion3 > currentVersion3)) 
			{ ; Check for updates
				add_log(1, "Update available")
				MsgBox, 36, Обновление Autohotkey Script Manager, Доступна версия %latestVersion%. Хотите обновить?
				IfMsgBox, Yes
				{
					try {
						add_log(3, "Trying executing as admin: " . A_ScriptDir . "\update.exe")
						Run, *RunAs %A_ScriptDir%\update.exe
					} catch {
						add_log(3, "ERROR: Could not execute as admin: " . A_ScriptDir . "\update.exe")
						add_log(3, "Executing normaly: " . A_ScriptDir . "\update.exe")
						Run, %A_ScriptDir%\update.exe
					}
					ExitApp
				}
			}
		} catch {
			add_log(1, "ERROR: Could not check for updates.")
			MsgBox, 50, Ошибка, Не удалось проверить наличие обновления.
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
		add_log(2, "Latest version installed")
		break
	}
}

;TODO add test for non existent regestry


tqwer := new EXTENSION("C:\repo\ASM\extensions\Test")
tqwer.init_trigers()


class EXTENSION_TRIGGER
{
	__New(typ, dir, disp_nme := "", desc := "", wait := false, prior := 10, filter := ".*") {
		if !RegExMatch(typ, "i)^(?:start|exit|edit|new|settings|run|finish|label)$") {
			throw
		}
		if !FileExist(dir) {
			throw
		}
		if RegExMatch(typ, "i)^(?:edit|new|settings|label)$")
		this.typ := typ
		this.dir := dir
		this.disp_nme := disp_nme
		this.desc := desc
		this.wait := wait
		this.prior := prior
		this.filter := filter
	}
}


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
						if RegExMatch(A_LoopField, "^(.+?)=(.+?)$", file) {
							add_log(5, "Couldn't find md5sum")
						} else if A_LoopField {
							file1 := A_LoopField
							file2 := 0
						} else {
							add_log(3, "No file dir given")
							throw
						}
						add_log(5, "Checking if " . file1 . " up to date")
						if (file2 != FileMD5(dir . "\" . file1)) {
							add_log(5, "Downloading - " . file1)
							URLDownloadToFile, %update_dir%/%file1%, %dir%\%file1%
							if ((file2 != FileMD5(dir . "\" . file1)) and file2) {
								add_log(3, "ERROR: Md5sums don't match")
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

/*
class LIBRARY_SCRIPT
{
	__New(dir) {
		this.dir := dir
		IniRead, name, %LibDir%\.asm\script_info.ini, dir, name
		if name == "ERROR" {
			name := RegExReplace(dir, "([^\\]+?).ahk$", "$1")
			IniWrite, name, %LibDir%\.asm\script_info.ini, dir, name
		}
		this.name := name
		
	}
	
	run() {
		Run
	}
}
*/