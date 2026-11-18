extends Camera2D

@export var player: Node2D
@export var follow_speed: float = 8.0

func _ready() -> void:
	_setCamera()

func _setCamera() -> void:
	if player:
		global_position = player.global_position
	make_current()
	reset_smoothing()
	set_physics_process(true)  # needed when the script is attached at runtime

func _physics_process(delta: float) -> void:
	if not player:
		return
	var weight := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(player.global_position, weight)
