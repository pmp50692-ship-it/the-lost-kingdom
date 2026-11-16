extends CharacterBody3D

@export var move_speed: float = 5.5
@export var jump_velocity: float = 5.0
var move_input := Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_cooldown := 0.0
var camera_pivot: Node3D
var sword: MeshInstance3D

func _ready() -> void:
    _build_character()
    _build_camera()

func _build_character() -> void:
    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    body.mesh = capsule
    var cloth := StandardMaterial3D.new()
    cloth.albedo_color = Color(0.55, 0.19, 0.09)
    body.material_override = cloth
    body.position.y = 0.95
    add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.25
    head_mesh.height = 0.5
    head.mesh = head_mesh
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.72, 0.48, 0.3)
    head.material_override = skin
    head.position.y = 1.92
    add_child(head)

    sword = MeshInstance3D.new()
    var blade := BoxMesh.new()
    blade.size = Vector3(0.09, 0.85, 0.12)
    sword.mesh = blade
    var steel := StandardMaterial3D.new()
    steel.albedo_color = Color(0.72, 0.78, 0.82)
    sword.material_override = steel
    sword.position = Vector3(0.48, 1.0, -0.25)
    sword.rotation.z = deg_to_rad(-25)
    add_child(sword)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.4
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

func _build_camera() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 1.5, 0)
    add_child(camera_pivot)
    var spring := SpringArm3D.new()
    spring.spring_length = 5.5
    spring.margin = 0.2
    camera_pivot.add_child(spring)
    var camera := Camera3D.new()
    camera.rotation_degrees.x = -12
    spring.add_child(camera)
    camera.current = true

func _physics_process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var input_vector := move_input
    if keyboard.length() > 0.1:
        input_vector = Vector2(keyboard.x, -keyboard.y)
    input_vector = input_vector.limit_length(1.0)

    var forward := -camera_pivot.global_basis.z
    var right := camera_pivot.global_basis.x
    var direction := right * input_vector.x + forward * input_vector.y
    direction.y = 0.0
    direction = direction.normalized()

    if direction.length() > 0.05:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        look_at(global_position + direction, Vector3.UP)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
    move_and_slide()

func attack() -> void:
    if attack_cooldown > 0.0:
        return
    attack_cooldown = 0.55
    var tween := create_tween()
    tween.tween_property(sword, "rotation:z", deg_to_rad(65), 0.12)
    tween.tween_property(sword, "rotation:z", deg_to_rad(-25), 0.18)
