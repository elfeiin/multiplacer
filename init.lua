multiplacer = {}

local add_3dx2 = function(a,b)
	return {x=a.x+b.x,y=a.y+b.y,z=a.z+b.z}
end

local mul_3dx2 = function(a,b)
	return {x=a.x*b.x,y=a.y*b.y,z=a.z*b.z}
end

multiplacer.activate = function(itemstack, player, delete, pointed_thing, mode1, mode2)

	if( player == nil or pointed_thing == nil) then
		return nil;
	end
	if( pointed_thing.type ~= "node" ) then
		return nil;
	end
	if minetest.get_item_group(material, "liquid") > 0 then
		minetest.chat_send_player( player:get_player_name(), "Cannot place liquids.");
		return nil;
	end
	
	local inv = player:get_inventory()
	local x = inv:get_stack("main", 1):get_count()
	local y = inv:get_stack("main", 2):get_count()
	local z = inv:get_stack("main", 3):get_count()
	if x*y*z > 9801 then
		return nil;
	end
	
	local start = minetest.get_pointed_thing_position( pointed_thing, mode1);
	local inv = player:get_inventory()
	local look_dir = player:get_look_dir()
	local dir = {x=look_dir.x/math.abs(look_dir.x), y=look_dir.y/math.abs(look_dir.y), z=look_dir.z/math.abs(look_dir.z)}
	local yaw = player:get_look_horizontal() + math.pi/2
	local msin = math.sin(yaw)
	local mcos = math.cos(yaw)
	
	-- credit to sokomine
	
	local item = itemstack:to_table();
	
	-- make sure it is defined
	if( not( item[ "metadata"] ) or item["metadata"]=="" ) then
		item["metadata"] = "default:dirt 0 0";
	end
	
	-- regain information about nodename, param1 and param2
	local daten = item[ "metadata"]:split( " " );
	-- the old format stored only the node name
	if( #daten < 3 ) then
		daten[2] = 0;
		daten[3] = 0;
	end
	
	for ix = 0, x-1 do
		for iy = 0, y-1 do
			for iz = 0, (not mode2 and -(z-1)) or z, (not mode2 and -1) or 1 do
				local pos
				if mode2 then
					pos = add_3dx2(start, mul_3dx2(dir, {x=ix, y=iy, z=iz}))
				else
					pos = add_3dx2(start, {x=ix*mcos-iz*msin, y=iy, z=ix*msin+iz*mcos})
				end
				local node = minetest.get_node_or_nil( pos );
				if not minetest.is_protected(pos, player:get_player_name()) then
					if delete then
						if minetest.get_node(pos).name == daten[1] then
							minetest.set_node(pos, {name = "air"})
						end
					else
						if( node.name == daten[1] ) then
							if( node.param1 ~= daten[2] or node.param2 ~= daten[3] ) then
								minetest.add_node( pos, { name = node.name, param1 = daten[2], param2 = daten[3] } );
							end
						end
						minetest.add_node( pos, { name = daten[1], param1 = daten[2], param2 = daten[3] } );
						-- minetest.set_node(pos, {name = material})
					end
				end
			end
		end
	end
	return nil;
end

minetest.register_tool("multiplacer:angle_placer", {
	description = "Placer Tool",
	inventory_image = "multiplacer_angle_placer.png",
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
		multiplacer.activate(itemstack, user, true, pointed_thing, above, false)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		local keys = placer:get_player_control()
		if not keys["sneak"] then
			return multiplacer.activate(itemstack, placer, false, pointed_thing, 0, false)
		end
		
		-- credit to sokomine
		if( pointed_thing.type ~= "node" ) then
			minetest.chat_send_player( name, "  Error: No node selected.");
			return nil;
		end
		
		local pos  = minetest.get_pointed_thing_position( pointed_thing, under );
		local node = minetest.get_node_or_nil( pos );
		
		local metadata = "default:dirt 0 0";
		if( node ~= nil and node.name ) then
			metadata = node.name..' '..node.param1..' '..node.param2;
		end
		itemstack:set_metadata( metadata );
		
		minetest.chat_send_player( name, "Angle_placer tool set to: '"..metadata.."'.");
		
		return itemstack; -- nothing consumed but data changed
	end
})

minetest.register_tool("multiplacer:axis_placer", {
	description = "Placer Tool",
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
		multiplacer.activate(itemstack, user, true, pointed_thing, above, true)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		local keys = placer:get_player_control()
		if not keys["sneak"] then
			return multiplacer.activate(itemstack, placer, false, pointed_thing, 0, true)
		end
		
		-- credit to sokomine
		if( pointed_thing.type ~= "node" ) then
			minetest.chat_send_player( name, "  Error: No node selected.");
			return nil;
		end
		
		local pos  = minetest.get_pointed_thing_position( pointed_thing, under );
		local node = minetest.get_node_or_nil( pos );
		
		local metadata = "default:dirt 0 0";
		if( node ~= nil and node.name ) then
			metadata = node.name..' '..node.param1..' '..node.param2;
		end
		itemstack:set_metadata( metadata );
		
		minetest.chat_send_player( name, "Axis_placer tool set to: '"..metadata.."'.");
		
		return itemstack; -- nothing consumed but data changed
	end
})
