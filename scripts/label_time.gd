extends Label

var last_time

func _ready():
	last_time = OS.get_unix_time()
	set_align(ALIGN_RIGHT)
	set_process(true)
	
func _process(delta):
	global.time += OS.get_unix_time() - last_time
	last_time = OS.get_unix_time()
	var minutes = global.time / 60
	var seconds = global.time % 60
	set_text("%02d : %02d" % [minutes, seconds])