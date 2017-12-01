extends Node2D

const speed = 80
var exit = false
var results = "res://scenes/results.tscn"

func _ready():
	set_process(true)

func _process(delta):
	if (!exit && get_pos().x > -480):
		set_pos(Vector2(get_pos().x - speed, get_pos().y))
	elif (exit):
		if (get_pos().x <= -480):
			set_pos(Vector2(480, get_pos().y))
		else:
			set_pos(Vector2(get_pos().x - speed, get_pos().y))
			if (get_pos().x < 0):
				set_pos(Vector2(0, get_pos().y))
				get_tree().change_scene(results)