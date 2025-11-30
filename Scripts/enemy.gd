extends CharacterBody3D

enum States {attack, idle, chase, die}

var state = States.idle
var hp = 100
var speed = 6.5
var accel = 10
var gravity = 9.8
var target = null
var attack = true

@onready var navAgent = $NavigationAgent3D
@onready var anim = $Animation
@onready var timer = $Timer


func enemy():
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity
	
	if state == States.idle:
		velocity = Vector3.ZERO
		
	elif state == States.chase:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * speed, accel * delta)
		
	elif state == States.attack:
		anim.play("attack")
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)

	elif state == States.die:
		velocity = Vector3.ZERO
	
	if hp <= 0:
		anim.play("die")
		state = States.die
	
	move_and_slide()
		
func _attack():
	if attack == true:
		anim.play("attack")
		target.hp -= 25
		attack = false
		timer.start()
		
func _on_chase_body_entered(body: Node3D) -> void:
	if body.has_method('player'):
		target = body
		state = States.chase

func _on_chase_body_exited(body: Node3D) -> void:
	if body.has_method('player'):
		target = null
		state = States.idle

func _on_attack_body_entered(body: Node3D) -> void:
	if body.has_method('player'):
		pass

func _on_attack_body_exited(body: Node3D) -> void:
	if body.has_method('player'):
		pass

func _on_timer_timeout() -> void:
	attack = true
	if target:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
