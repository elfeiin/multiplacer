multiplacer.get_node = function(player, pointed_thing)
	local pos = minetest.get_pointed_thing_position(pointed_thing, false);
	local node;
	if pointed_thing.type == "node" then
		node = minetest.get_node_or_nil(pos);
	end
	local block = "air"..' '.."0"..' '.."0";
	if( node ~= nil and node.name ) then
		block = node.name..' '..node.param1..' '..node.param2;
	end
	return block
end

multiplacer.get_node_pos = function(pointed_thing)
	local pos = minetest.get_pointed_thing_position(pointed_thing, false);
	return pos
end