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