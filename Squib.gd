extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 16
var direction = 'right'
var attacking = false
var moving = false
var roll = 0
var spawning = false
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	spawning = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	$AnimatedSprite.play("default")
	spawning = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if spawning or dead:
		return
	if !moving and !attacking:
		roll = randi() % 6
		$DecisionTimer.start(2)
		moving = true
	var move = Vector2()
	if roll == 0:
		move.x -= 1
		direction = 'left'
	if roll == 1:
		move.x += 1
		direction = 'right'
	if roll == 2:
		move.y -= 1
		direction = 'up'
	if roll == 3:
		move.y += 1
		direction = 'down'
		
	if roll == 5:
		var rock = load("res://Rock.tscn").instance()
		rock.position = position
		match direction:
			'right':
				rock.dir = Vector2(1, 0)
			'left':
				rock.dir = Vector2(-1, 0)
			'down':
				rock.dir = Vector2(0, 1)
			'up':
				rock.dir = Vector2(0, -1)
		roll = 4
		get_parent().add_child(rock)

	move = move.normalized()
	move_and_slide(move * speed)
	if move.x < 0:
		$AnimatedSprite.rotation_degrees = 180
	elif move.x > 0:
		$AnimatedSprite.rotation_degrees = 0
	if move.y < 0:
		$AnimatedSprite.rotation_degrees = 270
	elif move.y > 0:
		$AnimatedSprite.rotation_degrees = 90
	if move != Vector2():
		$AnimatedSprite.play("walk")
	else:
		$AnimatedSprite.play("default")
		
	var collisions = get_slide_count()
	if collisions > 0:
		var col = get_slide_collision(0)
		position += col.normal
		roll = 4
		
func _input(event):
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
	return
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
	attacking = true
	yield(get_tree().create_timer(0.5), "timeout")
	$sword.visible = false
	$sword.monitorable = false
	attacking = false


func _on_DecisionTimer_timeout():
	moving = false
	attacking = false
	roll = 4

func is_enemy():
	return true and !(spawning or dead)
	
func die():
	if spawning:
		return
	dead = true
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("cloud")
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
