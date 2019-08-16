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