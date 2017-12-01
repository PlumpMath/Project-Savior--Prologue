extends Node2D

var level1 = "res://scenes/level1.tscn"
var timer = 150
var gamestart = false
onready var hslogo = get_node("hslogo")
onready var label_logo = get_node("label_logo")
onready var label_title = get_node("label_title")
onready var label_credits = get_node("label_credits")
onready var label_controls = get_node("label_controls")
onready var label_control1 = get_node("label_control1")
onready var label_control2 = get_node("label_control2")
onready var label_control3 = get_node("label_control3")

func _ready():
	set_process(true)
	
func _process(delta):
	if (timer > 0):
		timer -= 1
		
	if (!gamestart):
		if (timer > 120):
			hslogo.hide()
			label_logo.hide()
			label_title.hide()
			label_credits.hide()
			label_controls.hide()
			label_control1.hide()
			label_control2.hide()
			label_control3.hide()
		elif (timer > 60):
			hslogo.show()
			label_logo.show()
		elif (timer > 30):
			hslogo.hide()
			label_logo.hide()
		else:
			if (Input.is_action_pressed("shoot")):
				label_credits.show()
				label_title.hide()
				label_controls.hide()
			elif (Input.is_action_pressed("controls")):
				label_credits.hide()
				label_title.hide()
				label_controls.show()
			else:
				label_credits.hide()
				label_title.show()
				label_controls.hide()
			label_control1.show()
			label_control2.show()
			label_control3.show()
			if (Input.is_action_pressed("jump")):
				gamestart = true
				label_title.hide()
				label_credits.hide()
				label_controls.hide()
				label_control1.hide()
				label_control2.hide()
				label_control3.hide()
				timer = 60
	else:
		if (timer <= 0):
			get_tree().change_scene(level1)
	