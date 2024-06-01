extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func animate():
	animation.play("default")
	
