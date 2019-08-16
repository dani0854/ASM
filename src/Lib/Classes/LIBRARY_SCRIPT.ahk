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