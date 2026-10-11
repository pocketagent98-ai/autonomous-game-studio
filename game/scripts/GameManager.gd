## Autoload singleton "Game": global game state, scoring, speed and encrypted save.
class_name GameManager
extends Node

signal coin_collected(total_coins: int)
signal score_changed(score: int, coins: int)
signal run_started()
signal run_over(final_score: int, best_score: int)
signal run_reset()

const SAVE_PATH := "user://save.dat"
const SAVE_PASS := "runner2026"
const INITIAL_SPEED := 14.0

var score: int = 0
var coins: int = 0
var speed: float = INITIAL_SPEED
var distance: float = 0.0
var is_running: bool = false
var best_score: int = 0
var total_coins: int = 0


func _ready() -> void:
    _load()


func prepare() -> void:
    score = 0
    coins = 0
    distance = 0.0
    speed = INITIAL_SPEED
    is_running = false
    score_changed.emit(score, coins)
    run_reset.emit()


func start_run() -> void:
    if is_running:
        return
    is_running = true
    run_started.emit()


func add_coin() -> void:
    if not is_running:
        return
    coins += 1
    total_coins += 1
    _update()
    coin_collected.emit(coins)


func add_distance(d: float) -> void:
    if not is_running:
        return
    distance += d
    speed = INITIAL_SPEED * pow(1.05, distance / 500.0)
    _update()


func _update() -> void:
    score = int(distance) + coins * 10
    score_changed.emit(score, coins)


func end_run() -> void:
    if not is_running:
        return
    is_running = false
    if score > best_score:
        best_score = score
    _save()
    run_over.emit(score, best_score)


func _save() -> void:
    var data := {"best_score": best_score, "total_coins": total_coins}
    var f := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SAVE_PASS)
    if f:
        f.store_string(JSON.stringify(data))
        f.close()


func _load() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var f := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SAVE_PASS)
    if f == null:
        return
    var txt := f.get_as_text()
    f.close()
    var parsed = JSON.parse_string(txt)
    if typeof(parsed) == TYPE_DICTIONARY:
        best_score = int(parsed.get("best_score", 0))
        total_coins = int(parsed.get("total_coins", 0))
