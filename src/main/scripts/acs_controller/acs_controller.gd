extends Node

var acs := {}


func add(ac: String):
	if ac in acs.keys():
		acs[ac] += 1
	else:
		acs[ac] = 1
