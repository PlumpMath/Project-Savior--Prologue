extends Sprite

func _ready():
	set_process(true)
	
func _process(delta):
	if (global.b_enemies):
		set_opacity(1)
	else:
		set_opacity(0.2)
