/proc/check_slaps(var/msg)
	if(findtext(msg, "@"))
		return 1
	else
		return 0

/proc/webhook_send_roundstatus(var/status, var/extraData)
	var/list/query = list("status" = status)

	if(extraData)
		query.Add(extraData)

	webhook_send("roundstatus", query)

/proc/webhook_send_asay(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("asaymessage", query)

/proc/webhook_send_ooc(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	if(!check_slaps(message))
		webhook_send("oocmessage", query)

/proc/webhook_send_me(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("memessage", query)

/proc/webhook_send_ahelp(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("ahelpmessage", query)

/proc/webhook_send_garbage(var/ckey, var/message)
	var/list/query = list("ckey" = ckey, "message" = message)
	webhook_send("garbage", query)

/proc/webhook_send(var/method, var/data)
	if(!webhook_address || !webhook_key)
		return
	var/query = "[webhook_address]?key=[webhook_key]&method=[method]&data=[list2json(data)]"
	spawn(-1)
		world.Export(query)