extends Sprite

# class member variables go here, for example:
onready var anim = get_node("AnimationPlayer")

func _ready():
	anim.play("main")

func _on_AnimationPlayer_finished():
	queue_free()
	
func set_speed(var speed):
	anim.set_speed(speed)
