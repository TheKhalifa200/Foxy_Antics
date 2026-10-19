class_name Player
extends CharacterBody2D

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_came: Camera2D = $PlayerCame

@export var camera_left:int=-1000
@export var camera_right:int=1000
@export var camera_top:int=-1000
@export var camera_bottom=1000

const GRAVITY: float=690.0
const RUN_SPEED: float=100.0
var _jumped:bool=false
var JUMP_FORCE: float=300.0
var was_on_floar:bool=false
var _start_position:Vector2
var is_still:bool:
	get:return is_zero_approx(velocity.x)

var is_ground:bool:
	get: return is_on_floor()

var is_falling:bool:
	get:return velocity.y>0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_position = position
	set_camera_limit()# Replace with function body.

func set_camera_limit()->void:
	player_came.limit_left = camera_left
	player_came.limit_bottom = camera_bottom
	player_came.limit_right = camera_right
	player_came.limit_top=camera_top
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		_jumped = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += delta*GRAVITY
	handle_movement()
	flip_sprite()
	move_and_slide()
	check_landed()
	#self.position.y += delta*GRAVITY

func flip_sprite()->void:
	#if Input.is_action_pressed("left"):
		#sprite_2d.flip_h=true
	#elif Input.is_action_pressed("right"):
		#sprite_2d.flip_h=false
	
	if not is_zero_approx(velocity.x):
		sprite_2d.flip_h = velocity.x<0
	
func check_landed()->void:
	if not was_on_floar and is_on_floor():
		land_sound.play()
	was_on_floar = is_on_floor()

func handle_movement()->void:
	velocity.x=Input.get_axis("left", "right") * RUN_SPEED
	
	if is_on_floor() and _jumped==true:
		velocity.y -= JUMP_FORCE
		jump_sound.play()
		_jumped=false

func fell_off()->void:
	position =_start_position
	#set_deferred("position", _start_position)
	set_position.call_deferred(_start_position)
