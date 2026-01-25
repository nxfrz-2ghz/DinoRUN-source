extends PanelContainer

@onready var pbar := $MarginContainer/HBoxContainer/TextureProgressBar
@onready var label := $MarginContainer/HBoxContainer/RichTextLabel

var pvalue: float:
	set(value):
		pbar.value += value
		label.text = "[fade]" + str(pbar.value / 100).substr(0, 4)

var max_value: float:
	set(value):
		pbar.max_value = value
