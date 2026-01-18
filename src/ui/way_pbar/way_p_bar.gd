extends MarginContainer

@onready var pbar := $HBoxContainer/TextureProgressBar

var pvalue: float:
	set(value):
		pbar.value += value
		$HBoxContainer/RichTextLabel.text = "[fade]" + str(pbar.value / 100).substr(0, 4)

var max_value: float:
	set(value):
		pbar.max_value = value
