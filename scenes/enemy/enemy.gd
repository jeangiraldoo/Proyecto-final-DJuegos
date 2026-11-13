class_name Enemy
extends CharacterBody3D

signal died

@export var speed := 2.5

var health := 1
var player: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:
		var to_player := player.global_position - global_position
		to_player.y = 0.0
		if to_player.length() > 0.1:
			var direction := to_player.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			look_at(global_position + direction, Vector3.UP)
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		queue_free()
