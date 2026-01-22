extends "res://src/entity/skelet/skelet.gd"

var attack_debaff := {
	"fire":
		{
			"damage": 0.5,
			"delay": 1,
			"time": 3.0,
		}
	}


func take_damage() -> void:
	super()
	M.E.dino.receive_effects(attack_debaff)
