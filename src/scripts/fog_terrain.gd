extends MeshInstance3D

const TEXTURE_SIZE = 512

var image: Image
var texture: ImageTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image = Image.create(
		TEXTURE_SIZE,
		TEXTURE_SIZE,
		false,
		Image.FORMAT_RF
	)

	image.fill(Color.BLACK)

	texture = ImageTexture.create_from_image(image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
