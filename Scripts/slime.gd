extends Node2D

enum slimespecies {RED, GREEN, BLUE, YELLOW, PINK, PURPLE, BLACK, WHITE}

onready var slime_shader = Shader.new()
onready var slime_material = ShaderMaterial.new()
onready var body = $KinematicBody2D

export(slimespecies) var slime_color

var shaderscript
var slime_palette
var palettes =[
	str(#RED
	"""
	const vec4 replace_shadow = vec4(""", 155.0/255,",", 14.0/255,",", 62.0/255,""", 1);
	const vec4 replace_body = vec4(""", 196.0/255,",", 28.0/255,",", 56.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 230.0/255,",",  69.0/255,",", 57.0/255,""", 1);
	"""),
	str(#BLUE
	"""
	const vec4 replace_shadow = vec4(""", 59.0/255,",", 125.0/255,",", 79.0/255,""", 1);
	const vec4 replace_body = vec4(""", 40.0/255,",", 162.0/255,",", 40.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 93.0/255,",",  194.0/255,",", 93.0/255,""", 1);
	"""),
	str(#GREEN
	"""
	const vec4 replace_shadow = vec4(""", 65.0/255,",", 65.0/255,",", 255.0/255,""", 1);
	const vec4 replace_body = vec4(""", 75.0/255,",", 120.0/255,",", 235.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 122.0/255,",",  159.0/255,",", 255.0/255,""", 1);
	"""	),
	str(#YELLOW
	"""
	const vec4 replace_shadow = vec4(""", 255.0/255,",", 162.0/255,",", 0.0/255,""", 1);
	const vec4 replace_body = vec4(""", 255.0/255,",", 226.0/255,",", 36.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 243.0/255,",",  229.0/255,",", 125.0/255,""", 1);
	"""),
	str(#PINK
	"""
	const vec4 replace_shadow = vec4(""", 204.0/255,",", 47.0/255,",", 123.0/255,""", 1);
	const vec4 replace_body = vec4(""", 224.0/255,",", 90.0/255,",", 235.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 245.0/255,",",  134.0/255,",", 255.0/255,""", 1);
	"""),
	str(#PURPLE
	"""
	const vec4 replace_shadow = vec4(""", 97.0/255,",", 16.0/255,",", 162.0/255,""", 1);
	const vec4 replace_body = vec4(""", 135.0/255,",", 60.0/255,",", 224.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 172.0/255,",",  110.0/255,",", 245.0/255,""", 1);
	"""),
	str(#BLACK
	"""
	const vec4 replace_shadow = vec4(""", 0.0/255,",", 0.0/255,",", 0.0/255,""", 1);
	const vec4 replace_body = vec4(""", 33.0/255,",", 24.0/255,",", 27.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 27.0/255,",",  31.0/255,",", 33.0/255,""", 1);
	"""),
	str(#WHITE
	"""
	const vec4 replace_shadow = vec4(""", 217.0/255,",", 217.0/255,",", 217.0/255,""", 1);
	const vec4 replace_body = vec4(""", 235.0/255,",", 235.0/255,",", 235.0/255,""", 1);
	const vec4 replace_outline = vec4(""", 255.0/255,",",  255.0/255,",", 255.0/255,""", 1);
	""")
	]
var counter = 0
var movement_choices = [
	Vector2(0, 1),
	Vector2(1, 0),
	Vector2(0, -1),
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
]
var velocity = Vector2.ZERO
var speed = 80

func _ready():
	randomize()
#Shader Stuff
	slime_palette = palettes[slime_color]
	$KinematicBody2D/AnimatedSprite.material = slime_material
	slime_material.shader = slime_shader
	set_shaderscript()
	$KinematicBody2D/AnimatedSprite.playing = true
#PASS
	velocity = movement_choices[randi() % 4] * speed


func _physics_process(_delta):
#	slime_wander(delta)
	pass


func slime_wander(delta):
	counter += delta
	
	if counter >= rand_range(4.0, 20.0):
		velocity = movement_choices[randi() % movement_choices.size()] * speed
		counter = 0
	body.move_and_slide(velocity / 6)


func set_shaderscript():
	shaderscript = str("""
	shader_type canvas_item;

	const vec4 original_shadow  = vec4(0.639, 0.655, 0.761, 1);
	const vec4 original_body    = vec4(0.227, 0.247, 0.369, 1);
	const vec4 original_outline = vec4(0.408, 0.435, 0.600, 1);
	
	""" + slime_palette + """
	
	const float precision = 0.1;

	vec4 swap_color(vec4 color){
		vec4 original_colors[3] = vec4[3] (original_shadow, original_body, original_outline);
		vec4 replace_colors[3] = vec4[3] (replace_shadow, replace_body, replace_outline);
		for (int i = 0; i < 3; i ++) {
			if (distance(color, original_colors[i]) <= precision){
				return replace_colors[i];
			}
		}
		return color;
	}

	void fragment() {
		COLOR = swap_color(texture(TEXTURE, UV));
	}
	""")
	slime_shader.code = shaderscript
