extends CharacterBody3D

@export var speed := 6.0
@export var mouse_sensitivity := 0.002
@export var fire_rate := 0.2

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var fire_cooldown := 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func _ready() -> void:
	add_to_group("player")
	
	if not InputMap.has_action("shoot"):
		InputMap.add_action("shoot")
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("shoot", mouse_event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, -PI / 2.0, PI / 2.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()


func _process(delta: float) -> void:
	fire_cooldown -= delta
	if Input.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and fire_cooldown <= 0.0:
		fire_cooldown = fire_rate
		_shoot()


func _shoot() -> void:
	var from := camera.global_position
	var to := from - camera.global_basis.z * 100.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(1)
