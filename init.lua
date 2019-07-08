multiplacer = {}

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/axis_place.lua");
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/basic_3d_math.lua");
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/functions.lua");
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/settings.lua");

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
			local block = multiplacer.get_node(player, pointed_thing)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:place", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to place '"..block.."' blocks.");
			return stack;
		end
	end,
	on_place = function(stack, player, pointed_thing)
		local keys = player:get_player_control()
		if keys["aux1"] then
			local block = multiplacer.get_node(player, pointed_thing)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:place", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to place '"..block.."' blocks.");
			return stack;
		end
		return multiplacer.axis_place(stack, player, pointed_thing, true);
	end,
	on_use = function(stack, player, pointed_thing)
		local keys = player:get_player_control()
		if keys["aux1"] then
			local block = multiplacer.get_node(player, pointed_thing)
			local meta = stack:get_meta();
			meta:set_string("multiplacer:delete", block);
			minetest.chat_send_player(player:get_player_name(), "Multiplacer tool set to delete '"..block.."' blocks.");
			return stack;
		end
		return multiplacer.axis_place(stack, player, pointed_thing, false);
	end,
})