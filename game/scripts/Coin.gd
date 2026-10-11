## A spinning coin the player collects.
class_name Coin
extends Area3D

signal collected

const COIN_RADIUS := 0.4
const COIN_HEIGHT := 0.12
const SPIN_SPEED := 4.0


func _ready() -> void:
    add_to_group("coin")
    var mi := MeshInstance3D.new()
    var cm := CylinderMesh.new()
    cm.top_radius = COIN_RADIUS
    cm.bottom_radius = COIN_RADIUS
    cm.height = COIN_HEIGHT
    cm.radial_segments = 16
    cm.rings = 1
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#ffd700")
    mat.metallic = 0.8
    mat.roughness = 0.3
    cm.material = mat
    mi.mesh = cm
    mi.rotation_degrees = Vector3(90, 0, 0)
    add_child(mi)
    var cs := CollisionShape3D.new()
    var sh := CylinderShape3D.new()
    sh.radius = COIN_RADIUS
    sh.height = COIN_HEIGHT
    cs.shape = sh
    cs.rotation_degrees = Vector3(90, 0, 0)
    add_child(cs)
    body_entered.connect(_on_body)


func _process(delta: float) -> void:
    rotate_y(SPIN_SPEED * delta)


func _on_body(body: Node3D) -> void:
    if body.is_in_group("player"):
        Game.add_coin()
        collected.emit()
        queue_free()
