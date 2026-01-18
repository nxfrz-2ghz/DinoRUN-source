extends GPUParticles2D

const textures := {
	"poison": preload("res://res/sprites/particles/poison_cloud.png"),
	"fire": preload("res://res/sprites/particles/fire_particle.png"),
}

func start(texture_name: String) -> void:
	self.texture = textures[texture_name]
	self.emitting = true
