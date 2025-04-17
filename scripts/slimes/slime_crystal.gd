class_name SlimeCrystal
extends Slime

## A slime that will increase the cohesion and alignment of nearby slimes, so
## they flock together more tightly.


@export var cohesion_multiplier: float = 2.0
@export var alignment_multiplier: float = 2.0

var cohesion_increase: float
var alignment_increase: float


func _ready() -> void:
	super()
	# The increase is additive, so subtract out the default value from the multiplier.
	cohesion_increase = cohesion_weight * (cohesion_multiplier - 1)
	alignment_increase = alignment_weight * (alignment_multiplier - 1)

	cohesion_weight += cohesion_increase
	alignment_weight += alignment_increase


## Keep track of the slimes that within the area and increase their cohesion and alignment.
func _on_flocking_zone_body_entered(body: Node3D) -> void:
	super(body)

	if body is Slime:
		body.cohesion_weight += cohesion_increase
		body.alignment_weight += alignment_increase


## Stop tracking slimes that leave the area and remove the cohesion and alignment increases.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	super(body)

	body.cohesion_weight -= cohesion_increase
	body.alignment_weight -= alignment_increase
