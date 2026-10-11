## A hazard. Uses an Area3D so it can detect the player and end the run.
class_name Obstacle
extends Area3D

var size: Vector3 = Vector3(1.6, 1.5, 1.0)


func _init(s: Vector3 = Vector3(1.6, 1.5, 1.0)) -> void:
    size = s


func _ready() -> void:
    add_to_group("obstacle")
    var mi := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("#ff8a3d")
    mat.roughness = 0.5
    bm.material = mat
    mi.mesh = bm
    add_child(mi)
    var cs := CollisionShape3D.new()
    var bs := BoxShape3D.new()
    bs.size = size
    cs.shape = bs
    add_child(cs)
    body_entered.connect(_on_body)


func _on_body(body: Node3D) -> void:
    if body.is_in_group("player") and body.has_method("die"):
        body.die()
