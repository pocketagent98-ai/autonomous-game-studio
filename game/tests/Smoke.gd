## Headless smoke test: boots the game, starts a run and checks the loop works.
extends Node

func _ready() -> void:
    var main = load("res://scenes/Main.tscn").instantiate()
    add_child(main)
    await get_tree().create_timer(0.4).timeout
    var p = get_tree().get_first_node_in_group("player")
    var tm = main.get_node_or_null("TrackManager")
    print("SMOKE player=", p != null, " track=", tm != null)
    p._act("right")  # start the run and turn once
    await get_tree().create_timer(2.0).timeout
    var obstacles := 0
    var coins := 0
    for n in get_tree().get_nodes_in_group("obstacle"):
        obstacles += 1
    for n in get_tree().get_nodes_in_group("coin"):
        coins += 1
    print("SMOKE score=", Game.score, " coins=", Game.coins, " speed=", Game.speed)
    print("SMOKE player_z=", p.global_position.z, " state=", p.state)
    print("SMOKE obstacles=", obstacles, " coins_in_scene=", coins)
    print("SMOKE RESULT: ", "PASS" if Game.score > 0 else "FAIL")
    get_tree().quit()
