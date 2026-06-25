extends Control

signal fow_updated
signal _dissolve_finished

@onready var fow_sub_viewport: SubViewport = $SubViewport
@onready var fow_texture: Sprite2D = $SubViewport/FowTexture
@onready var fow_units: Node = $SubViewport/FowUnits

var fow_image_to_dissolve: Image
var fow_viewport_texture: ImageTexture

func new_fow(new_texture_size: Vector2i) -> void:
	fow_sub_viewport.size = new_texture_size
	
	fow_image_to_dissolve = Image.create(
		new_texture_size.x,
		new_texture_size.y,
		false, Image.FORMAT_RGBA8
	)
	
	fow_image_to_dissolve.fill(Color(0.0, 0.0, 0.0, 1.0))
	combined_fow_sprites_texture_update()

func fow_request_texture_update() -> void:
	fow_render()
	
	fow_viewport_texture = ImageTexture.create_from_image(fow_sub_viewport.get_texture().get_image())

	await _dissolve_finished
	
	emit_signal("fow_updated")

func combined_fow_sprites_texture_update() -> void:
	fow_texture.set_texture(ImageTexture.create_from_image(fow_image_to_dissolve))

func fow_render() -> void:
	fow_texture.modulate = Color(1.0, 1.0, 1.0)
	await RenderingServer.frame_post_draw
	
	var combined_units_dissolve_sprites: Image = fow_sub_viewport.get_texture().get_image()
	fow_image_to_dissolve.blend_rect(
		combined_units_dissolve_sprites,
		combined_units_dissolve_sprites.get_used_rect(),
		Vector2i.ZERO
	)
	combined_fow_sprites_texture_update()
	
	fow_texture.modulate = Color(0.149, 0.149, 0.149)
	emit_signal("_dissolve_finished")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
