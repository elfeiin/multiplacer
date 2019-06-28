local add_3dx2 = function(a,b)
	return {x=a.x+b.x,y=a.y+b.y,z=a.z+b.z}
end

local mul_3dx2 = function(a,b)
	return {x=a.x*b.x,y=a.y*b.y,z=a.z*b.z}
end

multiplacer = {}

multiplacer.max_blocks = 1024

multiplacer.activate = function(stack, player, pointed_thing, mode)
	if( player == nil or pointed_thing == nil) then
		return nil;
	end
	
	local has, missing = minetest.check_player_privs(player, {multiplacer = true})
	if not has then
		if missing["multiplacer"] then
			minetest.chat_send_player( player:get_player_name(), "Hey! You can't use this tool because you do not have the \"multiplacer\" privilege.");
			return nil;
		end
	end
	
	local meta = stack:get_meta():to_table();
	local to_delete = meta["fields"]["multiplacer:delete"];
	local to_place = meta["fields"]["multiplacer:place"];
	if not to_delete or to_delete == "" then
		to_delete = "default:air 0 0"
	end
	if not to_place or to_place == "" then
		to_place = "default:dirt 0 0"
	end
	to_delete = to_delete:split(" ");
	if( #to_delete < 3 ) then
		to_delete[2] = 0;
		to_delete[3] = 0;
	end
	to_place = to_place:split(" ");
	if( #to_place < 3 ) then
		to_place[2] = 0;
		to_place[3] = 0;
	end
	
	local inv = player:get_inventory();
	local w = inv:get_stack("main", 1):get_count();
	local h = inv:get_stack("main", 2):get_count();
	local l = inv:get_stack("main", 3):get_count();
	local blocks_placed = 0;
	
	if( pointed_thing.type ~= "node" ) then
		minetest.chat_send_player(player:get_player_name(), "  Error: No node selected.");
		return nil;
	end
	
	local pos
	local look_dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()
	local start = minetest.get_pointed_thing_position(pointed_thing, mode);
	local axis_dir = {x=look_dir.x/math.abs(look_dir.x),y=-look_dir.y/math.abs(look_dir.y),z=look_dir.z/math.abs(look_dir.z)}
	for iw = 0, w-1 do
		for ih = 0, h-1 do
			for il = 0, l-1 do
				if yaw < math.pi/4 or yaw > 7*math.pi/4 or (yaw > 3*math.pi/4 and yaw < 5*math.pi/4) then
					pos = add_3dx2(start, mul_3dx2(axis_dir, {x=il, y=ih, z=iw}))
				else
					pos = add_3dx2(start, mul_3dx2(axis_dir, {x=iw, y=ih, z=il}))
				end
				local node = minetest.get_node_or_nil(pos)
				if not minetest.is_protected(pos, player:get_player_name()) then
					if node ~= nil then
						if node.name == to_delete[1] then --and node.param1 == to_delete[2] and node.param2 == to_delete[3]
							minetest.set_node( pos, { name = to_place[1], param1 = to_place[2], param2 = to_place[3] } );
						end
					end
				end
				blocks_placed = blocks_placed + 1;
				if blocks_placed > multiplacer.max_blocks then
					return nil;
				end
			end
		end
	end
	return nil;
end

multiplacer.get_node = function(stack, player, pointed_thing, mode)
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

minetest.register_privilege("multiplacer", {
	description = "Can use the multiplacer tools",
	give_to_single_player = true
})

minetest.register_tool("multiplacer:multiplacer", {
	description = "multiplacer",
	inventory_image = "multiplacer_multiplacer.png",
	liquids_pointable = true,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=7.00,[2]=4.00,[3]=1.40},
				uses=0, maxlevel=3}
		},
		damage_groups = {fleshy=1},
	},
	on_secondary_use = function(stack, player, pointed_thing)
		local keys = player:get_player_control()
		if keys["aux1"] then
			local block = multiplacer.get_node(stack, player, pointed_thing, true)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:place", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to place '"..block.."' blocks.");
			return stack;
		end
	end,
	on_place = function(stack, player, pointed_thing)
		local keys = player:get_player_control()
		if keys["aux1"] then
			local block = multiplacer.get_node(stack, player, pointed_thing, true)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:place", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to place '"..block.."' blocks.");
			return stack;
		end
		return multiplacer.activate(stack, player, pointed_thing, true);
	end,
	on_use = function(stack, player, pointed_thing)
		local keys = player:get_player_control()
		if keys["aux1"] then
			local block = multiplacer.get_node(stack, player, pointed_thing, true)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:delete", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to delete '"..block.."' blocks.");
			return stack;
		end
		return multiplacer.activate(stack, player, pointed_thing, false);
	end,
})