local add_3dx2 = function(a,b)
	return {x=a.x+b.x,y=a.y+b.y,z=a.z+b.z}
end

local mul_3dx2 = function(a,b)
	return {x=a.x*b.x,y=a.y*b.y,z=a.z*b.z}
end

multiplacer = {}

multiplacer.max_blox = 1024

multiplacer.activate = function(itemstack, player, delete, pointed_thing, mode1, on_axis, missing_areas)

	if( player == nil or pointed_thing == nil) then
		return nil;
	end
	
	local has, missing = minetest.check_player_privs(player, {multiplacer = true, areas = true})
	if not has then
		if missing["multiplacer"] then
			minetest.chat_send_player( player:get_player_name(), "Hey! You can't use this tool because you do not have the \"multiplacer\" privilege.");
		end
		return nil;
	end
	
	local inv = player:get_inventory()
	local w = inv:get_stack("main", 1):get_count()
	local h = inv:get_stack("main", 2):get_count()
	local l = inv:get_stack("main", 3):get_count()
	if w*l*h > multiplacer.max_blox then
		return nil;
	end
	
	if( pointed_thing.type ~= "node" ) then
		minetest.chat_send_player( name, "  Error: No node selected.");
		return nil;
	end
	
	local item = itemstack:to_table();
	if( not( item[ "metadata"] ) or item["metadata"]=="" ) then
		item["metadata"] = "default:dirt 0 0";
	end
	
	local daten = item[ "metadata"]:split( " " );
	if minetest.get_item_group(daten[1], "liquid") > 0 then
		minetest.chat_send_player( player:get_player_name(), "Cannot place liquids.");
		return nil;
	end
	
	if( #daten < 3 ) then
		daten[2] = 0;
		daten[3] = 0;
	end
	
	local pos
	local look_dir = player:get_look_dir()
	local yaw = player:get_look_horizontal()
	local start = minetest.get_pointed_thing_position(pointed_thing, mode1);
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
				if node ~= nil then
					if not minetest.is_protected(pos, player:get_player_name()) then
						if not areas then
							if delete then
								if node.name == daten[1] then
									minetest.set_node(pos, {name = "air"});
								end
							else
								minetest.add_node( pos, { name = daten[1], param1 = daten[2], param2 = daten[3] } );
							end
						elseif #areas:getNodeOwners(pos) > 0 or not missing_areas or player:get_player_name() == "nri" then
							if delete then
								if name.name == daten[1] then
									minetest.set_node(pos, {name = "air"});
								end
							elseif node.name == "air" then
								minetest.add_node( pos, { name = daten[1], param1 = daten[2], param2 = daten[3] } );
							end
						end
					end
				end
			end
		end
	end
	return nil;
end

minetest.register_privilege("multiplacer", {
	description = "Can use the multiplacer tool",
	give_to_single_player = true
})

minetest.register_privilege("mp_max_blox", {
	description = "Can use the multiplacer tool",
	give_to_single_player = true
})

minetest.register_chatcommand("mp_max_blox", {
	privs = {
		mp_max_blox = true
	},
	description = "Syntax: /mp_max_blox <number>: Command to change the maximum volume limit for the multiplacer tool."
	func = function(name, param)
		local num = tonumber(param)
		if num ~= nil then
			multiplacer.max_blox = num
		end
	end
})

minetest.register_tool("multiplacer:axis_placer", {
	description = "Axis Placer",
	inventory_image = "multiplacer_axis_placer.png",
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
	on_use = function(itemstack, user, pointed_thing)
		multiplacer.activate(itemstack, user, true, pointed_thing, above, true, missing["areas"])
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local keys = placer:get_player_control()
		if not keys["sneak"] then
			return multiplacer.activate(itemstack, placer, false, pointed_thing, 0, true, missing["areas"])
		end
		local metadata = "default:dirt 0 0";
		if( node ~= nil and node.name ) then
			metadata = node.name..' '..node.param1..' '..node.param2;
		end
		itemstack:set_metadata( metadata );
		minetest.chat_send_player( name, "Axis_placer tool set to: '"..metadata.."'.");
		return itemstack;
	end
})