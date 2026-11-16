extends Control

signal value_changed(value: Vector2)
var active := false
var finger_index := -1
var knob_offset := Vector2.ZERO
@export var radius := 82.0

func _ready() -> void:
    custom_minimum_size = Vector2(190, 190)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and not active:
            active = true
            finger_index = event.index
            _update_stick(event.position)
        elif not event.pressed and event.index == finger_index:
            _release()
    elif event is InputEventScreenDrag and active and event.index == finger_index:
        _update_stick(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            active = true
            _update_stick(event.position)
        else:
            _release()
    elif event is InputEventMouseMotion and active:
        _update_stick(event.position)

func _update_stick(point: Vector2) -> void:
    knob_offset = (point - size * 0.5).limit_length(radius)
    value_changed.emit(Vector2(knob_offset.x / radius, -knob_offset.y / radius))
    queue_redraw()

func _release() -> void:
    active = false
    finger_index = -1
    knob_offset = Vector2.ZERO
    value_changed.emit(Vector2.ZERO)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    draw_circle(center, radius, Color(0.05, 0.05, 0.05, 0.35))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.9, 0.8, 0.6, 0.8), 3.0)
    draw_circle(center + knob_offset, 34.0, Color(0.85, 0.68, 0.4, 0.8))
