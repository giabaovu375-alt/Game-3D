extends Node3D

## Cửa hầm đơn giản: trượt lên khi player vào vùng Area3D, đóng lại khi ra

@export var open_offset: Vector3 = Vector3(0, 2.2, 0)
@export var move_time: float = 1.2

@onready var door_mesh: CSGBox3D = $DoorMesh
@onready var area: Area3D = $Area3D

var closed_position: Vector3
var is_open: bool = false
var tween: Tween

func _ready() -> void:
	closed_position = door_mesh.position
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_open:
		_toggle_door(true)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and is_open:
		_toggle_door(false)

func _toggle_door(open: bool) -> void:
	is_open = open
	if tween:
		tween.kill()
	tween = create_tween()
	var target = closed_position + open_offset if open else closed_position
	tween.tween_property(door_mesh, "position", target, move_time).set_trans(Tween.TRANS_SINE)
