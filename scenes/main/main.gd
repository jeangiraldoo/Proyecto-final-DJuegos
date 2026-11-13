extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_distance := 20.0

var kills := 0

@onready var player: Node3D = $Player
@onready var kill_label: Label = $UI/KillLabel


func _on_spawn_timer_timeout() -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	add_child(enemy)
	var angle := randf() * TAU
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * spawn_distance
	enemy.global_position = player.global_position + offset
	enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	kills += 1
	kill_label.text = "Kills: %d" % kills
