class_name Player
extends CharacterBody2D

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_came: Camera2D = $PlayerCame
@onready var hurt_timer: Timer = $HurtTimer
@onready var hurt_sound: AudioStreamPlayer = $HurtSound


@export var camera_left:int=-1000
@export var camera_right:int=1000
@export var camera_top:int=-1000
@export var camera_bottom=1000

const FLASH_COUNT: int=6
const FLASH_DURATION: float=0.2
const GRAVITY: float=690.0
const RUN_SPEED: float=100.0
const MAX_FALL_SPEED: float=300.0
const JUMP_FORCE: float=300.0
const HURT_VELOCITY: Vector2= Vector2(0.0,-170.0)
const STOMP_SPEED: float=-200.0

var _jumped:bool=false
var was_on_floar:bool=false
var _start_position:Vector2
var _is_hurt:bool=false
var is_still:bool:
	get:return is_zero_approx(velocity.x)

var is_ground:bool:
	get: return is_on_floor()

var is_falling:bool:
	get:return velocity.y>0

var is_hurt:bool:
	get:return _is_hurt

var _is_invincible:bool = false
var _invincible_tween:Tween
var _damage_areas: Array[Area2D]

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
	if _is_hurt:return
	velocity.x=Input.get_axis("left", "right") * RUN_SPEED
	
	if is_on_floor() and _jumped==true:
		velocity.y -= JUMP_FORCE
		jump_sound.play()
		_jumped=false
	
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)

func fell_off()->void:
	position =_start_position
	#set_deferred("position", _start_position)
	set_position.call_deferred(_start_position)

func apply_hurt_jump()->void:
	if _is_hurt:return
	_is_hurt=true
	hurt_timer.start()
	velocity=HURT_VELOCITY
	hurt_sound.play()

func go_invincible()->void:
	if _is_invincible:return
	_is_invincible = true
	if _invincible_tween and _invincible_tween.is_running():
		_invincible_tween.kill()
	_invincible_tween = create_tween()
	_invincible_tween.set_loops(FLASH_COUNT)
	_invincible_tween.tween_property(sprite_2d,"modulate", Color.TRANSPARENT, FLASH_DURATION)
	_invincible_tween.tween_property(sprite_2d,"modulate", Color.WHITE, FLASH_DURATION)
	_invincible_tween.finished.connect(invincible_finish)

func invincible_finish()->void:
	_is_invincible=false
	if _damage_areas.size()>0:
		apply_hit.call_deferred()
	
func apply_hit()->void:
	if _is_invincible: return
	apply_hurt_jump()
	go_invincible()

func apply_stomp()->void:
	velocity.y = STOMP_SPEED

func _on_hit_area_area_entered(area: Area2D) -> void:
	apply_hit.call_deferred()
	if area not in _damage_areas:
		_damage_areas.append(area)# Replace with function body.

func _on_hit_area_area_exited(area: Area2D) -> void:
	_damage_areas.erase(area) # Replace with function body.

func _on_hurt_timer_timeout() -> void:
	_is_hurt=false # Replace with function body.
 
func apply_bounce(bounce_speed:Vector2)->void:
	velocity = bounce_speed

func _on_stomp_area_area_entered(area: Area2D) -> void:
	if velocity.y<0.0 or _is_hurt: return
	if area is StompBox and not area._is_hit:
		apply_stomp.call_deferred()
		area.trigger()
	if area is Trampoline and not area.bouncing:
		area.bounce()
		apply_bounce.call_deferred(area.bounce_velocity) # Replace with function body.
