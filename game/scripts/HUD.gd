## Heads-up display: score, coins, start overlay and game-over panel.
extends CanvasLayer

var _score_label: Label
var _coin_label: Label
var _overlay: ColorRect
var _over_panel: PanelContainer
var _final_label: Label
var _best_label: Label


func _ready() -> void:
    _build()
    Game.score_changed.connect(_on_score)
    Game.run_started.connect(_on_started)
    Game.run_over.connect(_on_over)
    Game.run_reset.connect(_on_reset)
    _on_reset()


func _build() -> void:
    var box := HBoxContainer.new()
    box.position = Vector2(24, 20)
    box.add_theme_constant_override("separation", 36)
    add_child(box)
    _score_label = _label("SCORE: 0", 40)
    _coin_label = _label("COINS: 0", 40)
    box.add_child(_score_label)
    box.add_child(_coin_label)

    _overlay = ColorRect.new()
    _overlay.color = Color(0, 0, 0, 0.6)
    _overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_overlay)
    var sl := _label("TAP / SPACE TO START", 56)
    sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    sl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    sl.custom_minimum_size = Vector2(700, 90)
    sl.position = Vector2(-350, -45)
    _overlay.add_child(sl)

    _over_panel = PanelContainer.new()
    _over_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    _over_panel.custom_minimum_size = Vector2(420, 260)
    _over_panel.position = Vector2(-210, -130)
    add_child(_over_panel)
    var vb := VBoxContainer.new()
    vb.add_theme_constant_override("separation", 16)
    _over_panel.add_child(vb)
    var t := _label("GAME OVER", 44)
    t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vb.add_child(t)
    _final_label = _label("Score: 0", 34)
    _final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vb.add_child(_final_label)
    _best_label = _label("Best: 0", 28)
    _best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vb.add_child(_best_label)
    var btn := Button.new()
    btn.text = "RESTART"
    btn.custom_minimum_size = Vector2(200, 56)
    btn.pressed.connect(func() -> void: Game.prepare())
    vb.add_child(btn)


func _label(text: String, size: int) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", Color.WHITE)
    return l


func _on_score(score: int, coins: int) -> void:
    _score_label.text = "SCORE: %d" % score
    _coin_label.text = "COINS: %d" % coins


func _on_started() -> void:
    _overlay.visible = false
    _over_panel.visible = false


func _on_over(score: int, best: int) -> void:
    _over_panel.visible = true
    _final_label.text = "Score: %d" % score
    _best_label.text = "Best: %d" % best


func _on_reset() -> void:
    _overlay.visible = true
    _over_panel.visible = false
    _score_label.text = "SCORE: 0"
    _coin_label.text = "COINS: 0"
