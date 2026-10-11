## Builds the whole scene procedurally and wires the game together.
extends Node3D

var _camera_rig: Node3D
var _track: Node3D
var _player: Node3D
var _hud: CanvasLayer


func _ready() -> void:
    _setup_environment()
    _setup_light()
    _player = _add_scripted(CharacterBody3D.new(), "res://scripts/Player.gd", "Player")
    _track = _add_scripted(Node3D.new(), "res://scripts/TrackManager.gd", "TrackManager")
    _camera_rig = _add_scripted(Node3D.new(), "res://scripts/CameraRig.gd", "CameraRig")
    _hud = _add_scripted(CanvasLayer.new(), "res://scripts/HUD.gd", "HUD")
    Game.prepare()


func _add_scripted(node: Node, script_path: String, node_name: String) -> Node:
    node.set_script(load(script_path))
    node.name = node_name
    add_child(node)
    return node


func _setup_environment() -> void:
    var we := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#0b1026")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#404a7a")
    env.ambient_light_energy = 1.0
    we.environment = env
    add_child(we)


func _setup_light() -> void:
    var dl := DirectionalLight3D.new()
    dl.light_energy = 1.4
    dl.rotation_degrees = Vector3(-55, -35, 0)
    dl.shadow_enabled = true
    add_child(dl)
