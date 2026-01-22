extends Node

@onready var connection := $ConnectionControl
@onready var disk := $DiskControl
@onready var upgrades := $Upgrades

var time_controller: Node
var settings: Node
