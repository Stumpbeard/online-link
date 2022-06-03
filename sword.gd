extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bodies = get_overlapping_bodies()
	if bodies:
		if bodies[0].has_method('is_enemy') and bodies[0].is_enemy():
			bodies[0].die()
