extends Node2D
class_name DialogueInteractable

@export var dialogue_data: DialogueData
@export var fade_duration: float = 1.0
@export var hold_duration: float = 1.0
@export var target_node: Node
@export var script_to_attach: Script
@export var teleport_node: Node2D
@export var teleport_position: Vector2
@export var use_global_position: bool = true
@export var node_to_hide: Node2D

var _player: PlayerController

func _ready() -> void:
	_player = await _wait_for_player()
	DialogueManager.start_dialogue(dialogue_data, _player)
	await DialogueManager.dialogue_finished
	_fade_black_and_back()

func _fade_black_and_back() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.modulate.a = 0.0
	layer.add_child(rect)
	get_tree().root.add_child(layer)

	var tween := create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, fade_duration)  # fade to black
	tween.tween_callback(_teleport)                               # teleport first
	tween.tween_callback(_attach_script)                          # then attach + _setCamera()
	tween.tween_callback(_hide_node)                              # hide while black
	tween.tween_interval(hold_duration)                           # stay black
	tween.tween_property(rect, "modulate:a", 0.0, fade_duration)  # fade back out
	tween.tween_callback(layer.queue_free)                        # clean up

func _attach_script() -> void:
	if target_node == null or script_to_attach == null:
		push_error("Assign Target Node and Script To Attach in the Inspector.")
		return
	target_node.set_script(script_to_attach)
	target_node.set("player", _player)  # exports were reset, so assign it again
	if target_node.has_method("_setCamera"):
		target_node.call("_setCamera")
	else:
		push_error("The attached script has no _setCamera() function.")

func _teleport() -> void:
	if teleport_node == null:
		push_error("Assign Teleport Node in the Inspector.")
		return
	if use_global_position:
		teleport_node.global_position = teleport_position
	else:
		teleport_node.position = teleport_position

func _hide_node() -> void:
	if node_to_hide == null:
		push_error("Assign Node To Hide in the Inspector.")
		return
	node_to_hide.hide()

func _wait_for_player() -> PlayerController:
	while true:
		var p := _find_player(get_tree().root)
		if p:
			return p
		await get_tree().process_frame
	return null

func _find_player(node: Node) -> PlayerController:
	if node is PlayerController:
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found:
			return found
	return null
