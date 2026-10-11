## Autoload "Audio": procedural sound effects (no audio files needed).
extends Node

const RATE := 22050

var _coin: AudioStreamPlayer
var _jump: AudioStreamPlayer
var _hit: AudioStreamPlayer


func _ready() -> void:
    _coin = _make(_tone(1000.0, 0.10, 1), -6.0)
    _jump = _make(_tone(520.0, 0.16, 0), -6.0)
    _hit = _make(_tone(150.0, 0.28, 2), -4.0)


func _make(stream: AudioStream, db: float) -> AudioStreamPlayer:
    var p := AudioStreamPlayer.new()
    p.stream = stream
    p.volume_db = db
    add_child(p)
    return p


func _tone(freq: float, dur: float, wave: int) -> AudioStreamWAV:
    var n := int(RATE * dur)
    var data := PackedByteArray()
    data.resize(n * 2)
    for i in range(n):
        var t := float(i) / RATE
        var env := 1.0 - t / dur
        var phase := TAU * freq * t
        var s := 0.0
        if wave == 0:
            s = sin(phase)
        elif wave == 1:
            s = 1.0 if sin(phase) >= 0.0 else -1.0
        else:
            s = 2.0 * (freq * t - floor(freq * t + 0.5))
        var v := int(clampf(s * env * 0.6, -1.0, 1.0) * 32767.0)
        data.encode_s16(i * 2, v)
    var st := AudioStreamWAV.new()
    st.format = AudioStreamWAV.FORMAT_16_BITS
    st.mix_rate = RATE
    st.stereo = false
    st.data = data
    return st


func play_coin() -> void:
    _coin.play()


func play_jump() -> void:
    _jump.play()


func play_hit() -> void:
    _hit.play()
