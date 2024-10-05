extends StaticBody3D
class_name KittenCluster

func interact(player:Player):
	player.kitten_count += 1
	if (randf()) < 0.2: player.tardigrade_count += 1
	queue_free()
