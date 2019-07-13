#NoEnv
#Persistent
#SingleInstance Force
SendMode Input
; Проверка елси скрипт был запущен от имени админа
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
{
    try
    {
        Run *RunAs "%A_ScriptFullPath%" /restart
		ExitApp
    }
}

; MD5 сумма для файла
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

; Функция get запроса
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

; Создание GUI интерфейса
Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30 vText1, Добро пожаловать в установщик ASM
Gui, Font, s8
Gui, Add, Text, x20 y70 w200 h23 vText2, Выберите путь установки:
Gui, Add, Edit, x20 y100 w300 h23 vDir, %A_ProgramFiles%\Doshik Soft\ASM
Gui, Add, Button, x320 y100 w50 h23 gChoseDir vChoseDir, Выбрать
Gui, Add, Text, x20 y150 w300 h23 vText3, Выберите путь для библиотеки скриптов:
Gui, Add, Edit, x20 y180 w300 h23 vLibDir, %A_MyDocuments%\ASM Library
Gui, Add, Button, x320 y180 w50 h23 gChoseLibDir vChoseLibDir, Выбрать
Gui, Add, CheckBox, x20 y230 w250 h23 vCreateShortcut, Создать ярлык на рабочем столе.
Gui, Add, CheckBox, x20 y260 w250 h23 vLaunchAfter, Запустить приложение после загрузки.
GuiControl, ,  LaunchAfter, 1
GuiControl, ,  CreateShortcut, 1
Gui, Add, Button, x220 y300 w70 h23 gCancel vCancel, Отменить
Gui, Add, Button, x300 y300 w70 h23 gInstall vInstall, Установить
Gui, Add, Button, x300 y150 w70 h23 gReady vReady, Готово
GuiControl, Hide, Ready
Gui, Add, Text, x20 y60 w200 h23 vCurrentAction
Gui, Add, Progress, x20 y100 w350 h30 vprogressBar, 0
GuiControl, Hide, CurrentAction
GuiControl, Hide, progressBar
Gui, Color, ffffcc
Gui, Show, AutoSize, Установщик ASM
return

ChoseDir: ; Выбор дериктории 
FileSelectFolder, NewDir
GuiControl, Text, Dir, %NewDir%
return

ChoseLibDir: ; Выбор дериктории библиотеки скриптов
FileSelectFolder, NewDir
GuiControl, Text, LibDir, %NewDir%
return

; Установка
Install:
; Отключение GUI
GuiControl, Disable, Install
GuiControl, Disable, ChoseDir
GuiControl, Disable, ChoseLibDir
GuiControl, Disable, Dir
GuiControl, Disable, LibDir
GuiControl, Disable, CreateShortcut
GuiControl, Disable, LaunchAfter
GuiControl, Disable, Cancel

; Проверка существования дерикторий и создание при необходимости
GuiControlGet, Dir,,Dir
GuiControlGet, LibDir,,LibDir
if (Dir == A_ProgramFiles . "\Doshik Soft\ASM") {
	SetWorkingDir, %A_ProgramFiles%
	FileCreateDir, Doshik Soft
	SetWorkingDir, %A_ProgramFiles%\Doshik Soft
	FileCreateDir, ASM
}else if !FileExist(Dir) {
	MsgBox, 48, Ошибка, Указан несуществующий путь установки.
	GuiControl, Enable, Install
	GuiControl, Enable, ChoseDir
	GuiControl, Enable, ChoseLibDir
	GuiControl, Enable, Dir
	GuiControl, Enable, LibDir
	GuiControl, Enable, CreateShortcut
	GuiControl, Enable, LaunchAfter
	GuiControl, Enable, Cancel
	return
}
if (LibDir == A_MyDocuments . "\ASM Library") {
	SetWorkingDir, %A_MyDocuments%
	FileCreateDir, ASM Library
} else if !FileExist(LibDir) {
	MsgBox, 48, Ошибка, Указан несуществующий путь для библиотеки скриптов.
	GuiControl, Enable, Install
	GuiControl, Enable, ChoseDir
	GuiControl, Enable, ChoseLibDir
	GuiControl, Enable, Dir
	GuiControl, Enable, LibDir
	GuiControl, Enable, CreateShortcut
	GuiControl, Enable, LaunchAfter
	GuiControl, Enable, Cancel
	return
}
; Переработка GUI
Gui, Hide
GuiControl, Enable, Cancel
GuiControl, Hide, Install
GuiControl, Hide, ChoseDir
GuiControl, Hide, ChoseLibDir
GuiControl, Hide, Dir
GuiControl, Hide, LibDir
GuiControl, Hide, CreateShortcut
GuiControl, Hide, LaunchAfter
GuiControl, Hide, Text2
GuiControl, Hide, Text3
GuiControl, Move, Cancel, x300 y150
GuiControl, Text, Text1, Идет установка ASM.
GuiControl, Show, CurrentAction
GuiControl, Show, progressBar
Gui, Show, AutoSize

; Загрузка файлов
SetWorkingDir, %Dir%
Loop {
	try {
		GuiControl, Text, CurrentAction, Получение информации
		GuiControl,, progressBar, 10
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
			RegExMatch(A_LoopField, "(.+)=(.+)", match)
			GuiControl, Text, CurrentAction, Загрузка %match1%
			URLDownloadToFile, https://doshik-soft.ru/asm/%match1%, %match1%
			GuiControl,, progressBar, +%increaseStep%
			GuiControl, Text, CurrentAction, Проверка %match1%
			if (match2 != FileMD5(A_WorkingDir + "\" + match1)) {
				Throw
			}
			GuiControl,, progressBar, +%increaseStep%
		}	
	} catch {
		MsgBox, 53, Ошибка, Не удалось загрузить ASM.
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, Retry
			GuiControl,, progressBar, 10
			continue
	}
	break
}
GuiControl,, progressBar, 70
; Создание config.ini
GuiControl, Text, CurrentAction, Создание config.ini
Loop {
	try {
		FileAppend,,  config.ini, CP1200
		IniWrite, %updatedVersion%, config.ini, Main, version
		IniWrite, 1, config.ini, Main, update
		IniWrite, %LibDir%, config.ini, Main, libraryPath
	} catch {
		MsgBox, 53, Ошибка, Ошибка во время создания config.ini
		IfMsgBox, Cancel
			ExitApp
		IfMsgBox, Retry
			continue
	}
	break
}
GuiControl,, progressBar, 90
; Создание ярлыка при необходимости
GuiControlGet, CreateShortcut,,CreateShortcut
if (CreateShortcut == 1) {
	GuiControl, Text, CurrentAction, Создание ярлыка на рабочем столе.
	Loop {
		try {
			if FileExist(A_Desktop . "\ASM") {
				Throw
			}
			FileCreateShortcut, %A_WorkingDir%\asm.exe, %A_Desktop%\ASM.lnk
			if ErrorLevel {
				Throw
			}
		} catch {
			MsgBox, 50, Ошибка, Ошибка во время создания ярлыка на рабочем столе.
			IfMsgBox, Abort
				ExitApp
			IfMsgBox, Retry
				continue
		}
		break
	}
}
GuiControl,, progressBar, 100
GuiControl, Hide, Cancel
GuiControl, Show, Ready
GuiControl, Text, CurrentAction, Готово
return

Ready:
; Запуск приложения при необходимости
GuiControlGet, LaunchAfter,,LaunchAfter
if (LaunchAfter == 1) {
	Loop {
		try {
			Run, asm.exe
		} catch {
			MsgBox, 53, Ошибка, Ошибка во время запуска.
			IfMsgBox, Cancel
				ExitApp
			IfMsgBox, Retry
				continue
		}
		break
	}
}
ExitApp

Cancel:
GuiClose:
MsgBox, 292, Установщик ASM, Вы уверены что хотите прекратить установку?
IfMsgBox, Yes
	ExitApp
return