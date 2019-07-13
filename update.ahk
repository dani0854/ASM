#NoEnv
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
			RegExMatch(A_LoopField, "(.+)=(.+)", match)
			GuiControl, Text, CurrentAction, Проверка %match1%
			GuiControl,, progressBar, +%increaseStep%
			if (match2 != FileMD5(A_WorkingDir + "\" + match1)) {
				GuiControl, Text, CurrentAction, Загрузка %match1%
				URLDownloadToFile, https://doshik-soft.ru/asm/%match1%, %match1%
			} 
			if (match2 != FileMD5(A_WorkingDir + "\" + match1)) {
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