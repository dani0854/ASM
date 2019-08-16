#NoEnv
;#Warn  ; Enable warnings to assist with detecting common errors.
#Include <FileSHA1>
#Include <log>
#Include <http_lib>
#Include <Classes/EXTENSION>
#Include <Classes/EXTENSION_TRIGGER>
#Include <Classes/LIBRARY_SCRIPT>
SendMode Input



global LibDir
RegRead, LibDir, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, LibraryDir
return
if FileExist(A_ScriptDir . "\log.txt") {
	FileDelete, %A_ScriptDir%\log.txt
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










