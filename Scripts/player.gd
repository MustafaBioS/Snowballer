extends CharacterBody3D

@onready var camera = $Neck/Camera
const snowball = preload("uid://d03emu2pc1hmg")
@onready var throwTimer = $ThrowTimer
@onready var neck = $Neck
@onready var point = $Neck/Point

const SPEED = 10.0
const JUMP_VELOCITY = 6.0
var sensitivity = 0.003
var canThrow = true
var hp = 100


func player():
	pass

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(float) -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	print(hp)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))
	if Input.is_action_just_pressed("throw") && canThrow == true:
		throw()

func throw():
	print('clicked')
	canThrow = false
	throwTimer.start()
	var snowballIns = snowball.instantiate()
	snowballIns.position = point.global_position
	get_tree().current_scene.add_child(snowballIns)
	
	var force = -18
	var upDir = 3.5
	
	var playerRotation = neck.global_transform.basis.z.normalized()
	
	snowballIns.apply_central_impulse(playerRotation * force + Vector3(0, upDir, 0))


func _on_throw_timer_timeout() -> void:
	canThrow = true
