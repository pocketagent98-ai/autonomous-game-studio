extends Node

func _ready() -> void:
    var main = load("res://scenes/Main.tscn").instantiate()
    add_child(main)
    await get_tree().create_timer(0.3).timeout
    var p = get_tree().get_first_node_in_group("player")
    p._act("right")
    await get_tree().create_timer(1.0).timeout
    var before = Game.score
    p.die()
    await get_tree().create_timer(0.3).timeout
    var died_ok = (not Game.is_running) and Game.best_score >= before
    print("DEATH is_running=", Game.is_running, " best=", Game.best_score, " score_before=", before)
    # restart flow
    Game.prepare()
    await get_tree().create_timer(0.2).timeout
    var reset_ok = (not Game.is_running) and Game.score == 0 and p.state == p.State.IDLE
    p._act("jump")
    await get_tree().create_timer(0.3).timeout
    var restart_ok = Game.is_running and p.state == p.State.RUNNING
    print("RESET ok=", reset_ok, " RESTART ok=", restart_ok)
    print("DEATHTEST RESULT: ", "PASS" if (died_ok and reset_ok and restart_ok) else "FAIL")
    get_tree().quit()
