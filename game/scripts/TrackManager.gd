## Procedural endless track built from a pool of recycled tiles.
extends Node3D

const TILE_LENGTH := 30.0
const NUM_TILES := 12
const LANE_WIDTH := 2.0

const ObstacleScript := preload("res://scripts/Obstacle.gd")
const CoinScript := preload("res://scripts/Coin.gd")

var lanes: Array = [-LANE_WIDTH, 0.0, LANE_WIDTH]

var _tiles: Array = []
var _player: Node3D
var _rng := RandomNumberGenerator.new()
var _floor_mat: StandardMaterial3D
var _rail_mat: StandardMaterial3D


func _ready() -> void:
    _rng.randomize()
    _floor_mat = _mat(Color("#2b2b3a"), 0.9)
    _rail_mat = _mat(Color("#00e5ff"), 0.4)
    _build_pool()


func _mat(c: Color, rough: float) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = rough
    return m


func _build_pool() -> void:
    for t in _tiles:
        t.queue_free()
    _tiles.clear()
    for i in range(NUM_TILES):
        var tile := _make_tile()
        add_child(tile)
        tile.position = Vector3(0.0, 0.0, -float(i) * TILE_LENGTH)
        _tiles.append(tile)


func _make_tile() -> Node3D:
    var tile := Node3D.new()
    var floor_mi := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = Vector3(LANE_WIDTH * 3.0 + 2.0, 0.5, TILE_LENGTH)
    bm.material = _floor_mat
    floor_mi.mesh = bm
    floor_mi.position = Vector3(0.0, -0.25, 0.0)
    tile.add_child(floor_mi)
    for sx in [-1.0, 1.0]:
        var rail := MeshInstance3D.new()
        var rm := BoxMesh.new()
        rm.size = Vector3(0.3, 1.0, TILE_LENGTH)
        rm.material = _rail_mat
        rail.mesh = rm
        rail.position = Vector3(sx * (LANE_WIDTH + 1.0), 0.25, 0.0)
        tile.add_child(rail)
    _populate(tile)
    return tile


func _populate(tile: Node3D) -> void:
    for c in tile.get_children():
        if c.is_in_group("obstacle") or c.is_in_group("coin"):
            tile.remove_child(c)
            c.queue_free()
    var z := -TILE_LENGTH * 0.5 + 6.0
    while z < TILE_LENGTH * 0.5 - 6.0:
        var order := [0, 1, 2]
        order.shuffle()
        var n := _rng.randi_range(0, 2)  # block 0..2 lanes, always leave >=1 open
        for k in range(n):
            _spawn_obstacle(tile, lanes[order[k]], z)
        if _rng.randf() < 0.75:
            _spawn_coin(tile, lanes[order[n]], z)
        z += 7.5


func _spawn_obstacle(tile: Node3D, x: float, z: float) -> void:
    var o = ObstacleScript.new()
    o.position = Vector3(x, 0.75, z)
    tile.add_child(o)


func _spawn_coin(tile: Node3D, x: float, z: float) -> void:
    var c = CoinScript.new()
    c.position = Vector3(x, 0.9, z)
    tile.add_child(c)


func _process(_delta: float) -> void:
    if _player == null or not is_instance_valid(_player):
        _player = get_tree().get_first_node_in_group("player")
        if _player == null:
            return
    if not Game.is_running or _tiles.is_empty():
        return
    if _player.global_position.z < _tiles[0].position.z - TILE_LENGTH * 0.5:
        var t: Node3D = _tiles.pop_front()
        var last: Node3D = _tiles[_tiles.size() - 1]
        t.position.z = last.position.z - TILE_LENGTH
        _populate(t)
        _tiles.append(t)


func reset() -> void:
    if _tiles.is_empty():
        _build_pool()
        return
    for i in range(_tiles.size()):
        _tiles[i].position = Vector3(0.0, 0.0, -float(i) * TILE_LENGTH)
        _populate(_tiles[i])
