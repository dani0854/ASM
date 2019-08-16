#NoEnv
#Include <http_lib>
#Include <FileSHA1>
#Include <log>

SendMode Input
SetWorkingDir %A_ScriptDir% 

Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30, Идет установка обновления.
Gui, Font, s8
Gui, Add, Button, x300 y150 w70 h23 gCancel vCancel, Отменить
Gui, Add, Text, x20 y60 w200 h23 vCurrentAction, Начало загрузки
Gui, Add, Progress, x20 y100 w350 h30 vprogressBar, 0
Gui, Color, ffffcc
Gui, Show, AutoSize, Установщик ASM


Loop {
	try {
		GuiControl, Text, CurrentAction, Получение информации
		md5sums := get("https://doshik-soft.ru/asm/md5sums.php")
		if ErrorLevel {
			Throw
		}
		updatedVersion := get("https://doshik-soft.ru/asm/version.txt")
		if ErrorLevel {
			Throw
		}
		StrReplace(md5sums, "`n", "`n", linesCount)
		increaseStep := Floor(30 / (linesCount + 1))
		Loop, Parse, md5sums, `n, `r  
		{
			RegExMatch(A_LoopField, "^([\w\.\\]+?) (\w+?)$", match)
			GuiControl, Text, CurrentAction, Проверка %match1%
			GuiControl,, progressBar, +%increaseStep%
			StringUpper, match2, match2
			if (match2 != FileSHA1(A_WorkingDir + "\" + match1)) {
				GuiControl, Text, CurrentAction, Загрузка %match1%
				URLDownloadToFile, https://doshik-soft.ru/asm/%match1%, %match1%
			} 
			if (match2 != FileSHA1(A_WorkingDir + "\" + match1)) {
				Throw
			}
			GuiControl,, progressBar, +%increaseStep%
		}	
	} catch {
		MsgBox, 53, Ошибка, Не удалось скачать обновление.
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, Retry
			continue
	}
	break
}

GuiControl,, progressBar, 70

if !FileExist("config.ini") { ; Check for config
	GuiControl, Text, CurrentAction, Создание config.ini
	Loop {
		try {
			FileAppend,,  config.ini, CP1200
			IniWrite, %updatedVersion%, config.ini, Main, version
			IniWrite, 1, config.ini, Main, update
			IniWrite, 0, config.ini, Main, libraryPath
			GuiControl,, progressBar, +20
		} catch {
			MsgBox, 53, Ошибка, Ошибка во время создания config.ini
			IfMsgBox, Cancel
				ExitApp
			IfMsgBox, Retry
				GuiControl,, progressBar, 70
				continue
		}
		break
	}
}
IniWrite, %updatedVersion%, config.ini, Main, version
GuiControl, Text, CurrentAction, Готово
GuiControl,, progressBar, 100
Run, asm.exe
ExitApp

Cancel:
GuiClose:
MsgBox, 292, Обновление ASM, Вы уверены что хотите прекратить обновление?
IfMsgBox, Yes
	ExitApp
return