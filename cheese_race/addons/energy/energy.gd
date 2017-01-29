tool
extends HBoxContainer

func show_object_energy(object):
	get_node("Current").set_value(0)
	get_node("Goal").set_value(0)
	var parent = object.get_parent()
	while parent.find_node("Mouse") == null:
		parent = parent.get_parent()
	calculate_energy(parent, object, null, 0)

func calculate_energy(parent, object, last_object, energy):
	for o in parent.get_children():
		var skip = false
		var energy_increase = 0
		if o.is_visible():
			var n = o.get_name()
			if n == "Mouse":
				energy = 50
			elif n == "Goal":
				pass
			elif n.left(6) == "Cheese":
				energy_increase += o.get_energy()
			elif n.left(8) == "Optional":
				if last_object != null:
					var r = calculate_energy(o, object, last_object, energy)
					energy = r.energy
					last_object = r.last_object
					if last_object == null || energy <= 0:
						return { last_object = null, energy = 0 }
					else:
						continue
			elif n.left(4) != "Coin":
				continue
			if energy > 0:
				if last_object != null:
					energy -= 0.02 * abs(last_object.get_pos().x - o.get_pos().x)
					if energy <= 0:
						energy = 0
						print("out of energy before reaching "+o.get_name())
						break
				last_object = o
				energy += energy_increase
				if energy > 100:
					energy = 100
			if o == object:
				get_node("Current").set_value(energy)
			if n == "Goal":
				get_node("Goal").set_value(energy)
				return { last_object = null, energy = 0 }
	return { last_object = last_object, energy = energy }