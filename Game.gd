extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = load("res://Link.tscn").instance()
	player.position = Vector2(44, 44)
	var id = str(get_tree().get_network_unique_id())
	player.set_name(id)
	add_child(player)
	if is_network_master():
		get_tree().root.get_child(0).player_info["1"] = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_name(name):
	$Label.text = name
