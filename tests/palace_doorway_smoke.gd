extends SceneTree

func _initialize() -> void:
    call_deferred("_run_test")

func _run_test() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        push_error("DOORWAY_TEST_FAIL: main scene could not be loaded")
        quit(1)
        return

    var scene := packed.instantiate()
    root.add_child(scene)
    for i in range(4):
        await physics_frame

    var hero := scene.get_node_or_null("Hero") as CharacterBody3D
    if hero == null:
        push_error("DOORWAY_TEST_FAIL: Hero node was not created")
        quit(1)
        return

    # Start immediately in front of the palace and walk straight through.
    hero.global_position = Vector3(0, 0.1, -27.0)
    hero.velocity = Vector3.ZERO
    hero.move_input = Vector2(0, 1)

    for i in range(120):
        await physics_frame
        if hero.global_position.z < -34.0:
            print("DOORWAY_TEST_PASS: Hero crossed the palace entrance. z=", hero.global_position.z)
            quit(0)
            return

    var hit_info := "no collision details"
    if hero.get_slide_collision_count() > 0:
        var hit := hero.get_slide_collision(0)
        hit_info = "collider=%s position=%s normal=%s" % [hit.get_collider().name, hit.get_position(), hit.get_normal()]
    push_error("DOORWAY_TEST_FAIL: Hero was blocked at the palace entrance. Final z=%s %s" % [hero.global_position.z, hit_info])
    quit(1)
