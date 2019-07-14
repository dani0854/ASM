#NoEnv
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input


get(url)
{
    loop 5
    {
        ComObjError(false)
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url)
        whr.WaitForResponse(5)
        whr.SetRequestHeader("Content-Type","application/x-www-form-urlencoded")
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 YaBrowser/17.6.1.744 Yowser/2.5 Safari/537.36")
        whr.Send()
        if(!strlen(whr.ResponseText))
            continue
        return whr.ResponseText
    }
	ErrorLevel := 1
	return
}

if !FileExist(A_ScriptDir . "\config.ini") { ; Check for config
	try {
		Run, *RunAs %A_ScriptDir%\update.exe
	} catch {
		Run, %A_ScriptDir%\update.exe
	}
	ExitApp
}

IniRead, autoUpdate, %A_ScriptDir%\config.ini, Main, update
if autoUpdate { ; Auto update
	Loop {
		RegRead, currentVersion, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, version
		latestVersion := get("https://doshik-soft.ru/asm/version.txt")
		if ErrorLevel {
			MsgBox, 50, Ошибка, Не удалось проверить наличие обновления.
			IfMsgBox, Abort
				ExitApp
			IfMsgBox, Retry
				continue
		}else if ((latestVersion - currentVersion) > 0) { ; Check for updates
			MsgBox, 36, Обновление Autohotkey Script Manager, Доступна версия %latestVersion%. Хотите обновить?
			IfMsgBox, Yes
				try {
					Run, *RunAs %A_ScriptDir%\update.exe
				} catch {
					Run, %A_ScriptDir%\update.exe
				}
				ExitApp
		}
		break
	}
}