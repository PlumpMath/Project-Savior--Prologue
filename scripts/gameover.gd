extends Node2D

var level1 = "res://scenes/level1.tscn"
var timer = 400
var gamestart = false
onready var label_title = get_node("label_title")
onready var label_message = get_node("label_message")
onready var label_control = get_node("label_control")

func _ready():
	set_process(true)
	label_message.hide()
	label_control.hide()
	if (!global.hard_mode):
		if (global.perfect):
			global.hard_mode = true
			label_message.set_text("Hard mode unlocked.")
			label_message.add_color_override("font_color", Color(1, 0, 0))
			label_control.add_color_override("font_color", Color(1, 0, 0))
	else:
		if (global.perfect):
			label_message.set_text("That's some skill.")
		label_message.add_color_override("font_color", Color(1, 0, 0))
		label_control.add_color_override("font_color", Color(1, 0, 0))
			
	label_title.set_opacity(0)
	
func _process(delta):
	if (timer > 0):
		timer -= 1
		
	if (!gamestart):
		if (timer > 340):
			label_message.hide()
			label_control.hide()
		elif (timer > 160):
			label_title.set_opacity(label_title.get_opacity() + 0.01)
		elif (timer > 90):
			label_message.show()
		else:
			label_control.show()
			if (Input.is_action_pressed("jump")):
				gamestart = true
				label_title.hide()
				label_message.hide()
				label_control.hide()
				timer = 60
	else:
		if (timer <= 0):
			global.time = 0
			global.level = 1
			get_tree().change_scene(level1)
	
	