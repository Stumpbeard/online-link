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
	if !attacking:
		if Input.is_action_pressed("ui_left"):
			move.x -= 1
		if Input.is_action_pressed("ui_right"):
			move.x += 1
		if Input.is_action_pressed("ui_up"):
			move.y -= 1
		if Input.is_action_pressed("ui_down"):
			move.y += 1

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
			die()
		
func _input(event):
	if dead:
		return
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_RIGHT:
			direction = 'right'
		elif event.pressed and event.scancode == KEY_LEFT:
			direction = 'left'
		elif event.pressed and event.scancode == KEY_UP:
			direction = 'up'
		elif event.pressed and event.scancode == KEY_DOWN:
			direction = 'down'
			
		if !attacking and Input.is_action_just_pressed("ui_accept"):
			attack()
			
func attack():
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
	
func die():
	dead = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
