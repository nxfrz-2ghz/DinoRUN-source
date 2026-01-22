extends AudioStreamPlayer

const GAME_MUSIC := [
	"res://res/music/08 Chicago chiphop.mp3",
	"res://res/music/09 Class cracktro #15.mp3",
	"res://res/music/10 Taren lever.mp3",
	"res://res/music/12 Team Haze Chiptune.mp3",
	"res://res/music/13 Paradox #2.mp3",
	"res://res/music/14 Related memories.mp3",
	"res://res/music/15 Ghost.mp3",
	"res://res/music/16 Plastic.mp3",
	"res://res/music/17 Marihuana.mp3",
	"res://res/music/19 Against the time.mp3",
	"res://res/music/20 Dragon atlas.mp3",
	"res://res/music/21 My dirty old kamel.mp3",
	"res://res/music/23 Paskchip(easter egg).mp3",
	"res://res/music/25 Our darkness.mp3",
	"res://res/music/26 MegaMan2.mp3",
	"res://res/music/27 Scissors mix.mp3",
	"res://res/music/29 Chaos #1.mp3",
	"res://res/music/30 RLD Installer #10.mp3",
	"res://res/music/31 Unreeeal superhero 3.mp3",
	"res://res/music/33 BrD.mp3",
	"res://res/music/34 Hybrid song.mp3",
	"res://res/music/35 Tekilla Groove.mp3",
	"res://res/music/36 Mr. Spock's cryo-bed.mp3",
	"res://res/music/39 Blank page.mp3",
]

const HOME_MUSIC := [
	"res://res/music/32 Aurora dawn.mp3",
]


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		play_music()


func play_music(text: String = "") -> void:
	var rand_music: String
	if text == "home":
		rand_music = HOME_MUSIC[randi_range(0, HOME_MUSIC.size()-1)]
	else:
		rand_music = GAME_MUSIC[randi_range(0, GAME_MUSIC.size()-1)]
	
	self.stream = load(rand_music)
	
	# Getting music name
	var parts: Array = rand_music.split(" ")
	var music_name: String = " ".join(parts.slice(1))
	
	$"../RichTextLabel".text = "[wave][rainbow][pulse]♬ " + music_name
	self.play()


func _on_finished() -> void:
	$Timer.start()


func _on_timer_timeout() -> void:
	play_music()
