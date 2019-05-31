multiplacer = {}

local add_3dx2 = function(a,b)
	return {x=a.x+b.x,y=a.y+b.y,z=a.z+b.z}
end

local mul_3dx2 = function(a,b)
	return {x=a.x*b.x,y=a.y*b.y,z=a.z*b.z}
end

multiplacer.activate = function(player, material, pointed_thing, mode)
	if( player == nil or pointed_thing == nil) then
		return nil;
	end
	if( pointed_thing.type ~= "node" ) then
		return nil;
	end
	local start = minetest.get_pointed_thing_position( pointed_thing, mode );
	local inv = player:get_inventory()
	local stack = inv:get_stack("main", 1)
	local material = material or (stack:is_known() and stack:get_name())
	if not material then
		return
	end
	local x = stack:get_count()
	local y = inv:get_stack("main", 2):get_count()
	local z = inv:get_stack("main", 3):get_count()
	local look_dir = player:get_look_dir()
	local dir = {x=look_dir.x/math.abs(look_dir.x), y=1, z=look_dir.z/math.abs(look_dir.z)}
	-- minetest.chat_send_player( player:get_player_name(), "  " .. material);
	for ix = 0, x-1 do
		for iy = 0, y-1 do
			for iz = 0, z-1 do
				local pos = add_3dx2(start, mul_3dx2(dir, {x=ix, y=iy, z=iz}))
				if not minetest.is_protected(pos) then
					minetest.set_node(pos, {name = material})
				end
			end
		end
	end
end

minetest.register_tool("multiplacer:multiplacer", {
	description = "Placer Tool",
	inventory_image = "multiplacer_multiplacer.png",
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
		multiplacer.activate(user, nil, pointed_thing, 0)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		multiplacer.activate(placer, "air", pointed_thing, above)
	end
})
