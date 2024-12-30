@tool

const Coin = preload("res://scenes/coin.tscn")
const Platform = preload("res://scenes/plateform.tscn")
const Player = preload("res://scenes/player.tscn")
const Path_node = preload("res://scenes/path_move.tscn")
const Platform_move = preload("res://scenes/platform_move.tscn")

const LDTKUtil = preload("res://addons/ldtk-importer/src/util/util.gd")

func create_node(parent: Node, group_name: String, entity_count: int) -> Node:
	if entity_count >= 2:
		var group_node = Node.new()
		group_node.name = group_name
		parent.add_child(group_node)
		return group_node
	return null

func create_path(platform_move: Node, entity_layer: Node, entity_groups: Dictionary) -> void:
	var path_points = []
	var path_nodes = platform_move.get("path_nodes")
	
	for path_move_entity in path_nodes:
		path_points.append(path_move_entity.position)
	
	if path_points.size() > 1:
		var path_node = Path2D.new()
		var curve = Curve2D.new()
		for point in path_points:
			curve.add_point(point)
		path_node.offset = platform_move.position
		path_node.curve = curve
		
		platform_move.add_child(path_node)

func process_entity(entity: Dictionary, entity_layer: Node, entity_groups: Dictionary, instantiate_func: Callable) -> void:
	var ent = instantiate_func.call()
	if ent:
		# Positioning Logic
		if entity.identifier == "Player":
			ent.position = Vector2(entity.position.x, entity.position.y + 4)
		else:
			ent.position = entity.position
	
		# Naming logic
		var spawn_count = entity_groups.get(entity.identifier, {}).get("count", 0) + 1
		if spawn_count > 1:
			ent.name = entity.identifier + str(spawn_count)
	
		# Skip group handling for Player, add directly to layer
		if entity.identifier == "Player":
			entity_layer.add_child(ent)
		else:
			var group = entity_groups.get(entity.identifier, {}).get("group", null)
			if group:
				group.add_child(ent)
			else:
				entity_layer.add_child(ent)
	
		# Update instance reference
		LDTKUtil.update_instance_reference(entity.iid, ent)
	
		# Update the spawn count
		if entity_groups.has(entity.identifier):
			entity_groups[entity.identifier]["count"] = spawn_count

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var entity_groups = {}
	var entity_counts = {}
	
	for entity in entity_layer.entities:
		# Initialize the count for the entity type if not already present
		if not entity_counts.has(entity.identifier):
			entity_counts[entity.identifier] = 0
		# Increment the count for the entity type
		entity_counts[entity.identifier] += 1
	
	# Create grouping Nodes for entities except Player
	for identifier in entity_counts.keys():
		var count = entity_counts[identifier]
		if identifier != "Player":  # Skip group creation for Player
			if count >= 2 and not entity_groups.has(identifier):
				# Create the group only if it doesn't already exist
				var group = Node.new()
				group.name = identifier + "_Group"
				entity_layer.add_child(group)
				entity_groups[identifier] = {"group": group, "count": count}
	
	# Loop through the 'entities' Dictionary on the EntityLayer
	for entity in entity_layer.entities:
		if entity.identifier == "Coin":
			process_entity(entity, entity_layer, entity_groups, Callable(Coin, "instantiate"))
		elif entity.identifier == "Platform":
			process_entity(entity, entity_layer, entity_groups, Callable(Platform, "instantiate"))
		elif entity.identifier == "Player":
			process_entity(entity, entity_layer, entity_groups, Callable(Player, "instantiate"))
		elif entity.identifier == "Platform_move":
			process_entity(entity, entity_layer, entity_groups, Callable(Platform_move, "instantiate"))
			var platform_move_instance = entity_layer.get_node(entity.name)
			create_path(platform_move_instance, entity_layer, entity_groups)
	
	return entity_layer
