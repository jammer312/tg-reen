/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(0))	return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)	return

	log_admin("[key_name(src)] : [msg]")
	webhook_send_asay(key_name(src), msg)
	msg = "<span class='admin'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message'>[msg]</span></span>"
	admins << msg