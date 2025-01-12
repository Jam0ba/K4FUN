extends Node3D

# Settings
@export var snappiness : float = 2.0
@export var returnSpeed : float = 20.0

var recoil : Vector3
var targetRotation : Vector3
var currentRotation : Vector3

func _process(delta : float) -> void:
	update_recoil(delta)



func recoilFire(isAiming : bool = false):
	if isAiming:
		targetRotation += Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z))

func New_Recoil(newRecoil : Vector3) -> void:
	recoil = newRecoil

func update_recoil(delta):
		# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, Vector3.ZERO, returnSpeed * delta)
	currentRotation = lerp(currentRotation, targetRotation, snappiness * delta)
	# Set rotation
	rotation = currentRotation
	# Camera z axis tilt fix, ignored if tilt intentional
	# I have no idea why it tilts if recoil.z is set to 0
	if recoil.z == 0:
		global_rotation.z = 0
