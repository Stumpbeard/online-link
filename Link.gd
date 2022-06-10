extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 48
var direction = 'right'
var attacking = false
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$sword.visible = false
	$sword.monitorable = false
	$sword.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if dead:
		return
	var move = Vector2()
	if str(get_tree().get_network_unique_id()) == get_name():
		if !attacking:
			if Input.is_action_pressed("ui_left"):
				move.x -= 1
			if Input.is_action_pressed("ui_right"):
				move.x += 1
			if Input.is_action_pressed("ui_up"):
				move.y -= 1
			if Input.is_action_pressed("ui_down"):
				move.y += 1
			if Input.is_key_pressed(KEY_Z):
				rpc('attack')

	rpc('move_character', move)
			
remotesync func move_character(move_data):
	var move = Vector2(move_data)
	if move.x < 0:
		direction = 'left'
	if move.x > 0:
		direction = 'right'
	if move.y < 0:
		direction = 'up'
	if move.y > 0:
		direction = 'down'
	move = move.normalized()
	move_and_slide(move * speed)
	if move.x < 0:
		$AnimatedSprite.flip_h = true
	elif move.x > 0:
		$AnimatedSprite.flip_h = false
	if move != Vector2():
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("default")
		
	var collisions = get_slide_count()
	if collisions:
		var collider = get_slide_collision(0).collider
		if collider.has_method('is_enemy') and collider.is_enemy():
			handle_death()
			
remotesync func attack():
	match direction:
		'right':
			$sword.rotation_degrees = 0
		'left':
			$sword.rotation_degrees = 180
		'down':
			$sword.rotation_degrees = 90
		'up':
			$sword.rotation_degrees = 270
	$sword.visible = true
	$sword.monitorable = true
	$sword.monitoring = true
	attacking = true
	yield(get_tree().create_timer(0.5), "timeout")
	$sword.visible = false
	$sword.monitorable = false
	$sword.monitoring = false
	attacking = false
	
func handle_death():
	rpc('die')
	
remotesync func die():
	dead = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	visible = false
	$CollisionShape2D.disabled = true
	

func serialize():
	return {
		"position": position,
		"animation": $AnimatedSprite.animation,
		"direction": direction,
		"attacking": attacking,
		"dead": dead
	}
	
func deserialize(data):
	position = Vector2(data["position"])
	$AnimatedSprite.play(data["animation"])
	direction = data["direction"]
	attacking = data["attacking"]
	dead = data["dead"]
	if dead:
		visible = false
		$CollisionShape2D.disabled = true
