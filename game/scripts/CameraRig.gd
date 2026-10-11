## Follow camera: sits behind and above the runner and looks at it.
extends Node3D

@export var follow_speed: float = 6.0
@export var offset: Vector3 = Vector3(0.0, 4.5, 9.0)
@export var fov: float = 70.0

var _cam: Camera3D
var _player: Node3D


func _ready() -> void:
    _cam = Camera3D.new()
    _cam.fov = fov
    _cam.current = true
    _cam.position = Vector3.ZERO
    add_child(_cam)


func _physics_process(delta: float) -> void:
    if _player == null or not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player")
        if _player == null:
            return
    var target: Vector3 = _player.global_position + offset
    global_position = global_position.lerp(target, clampf(follow_speed * delta, 0.0, 1.0))
    look_at(_player.global_position + Vector3(0.0, 1.2, 0.0), Vector3.UP)
