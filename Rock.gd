extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 24
var dir = Vector2(1, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	move_and_slide(dir * speed)
	if get_slide_count():
		var collision = get_slide_collision(0)
		collision.collider.handle_death()
		queue_free()
		
	
func is_enemy():
	return true
