-- Create an xml file for gearcollector use. The file is structured like a spellcast, setting all item in a set.
-- the variable set is passed as paramether, it should be the sets table in gearswap, otherwise you'll have a beautiful spellcast set of a lua table
function set_gearcollector(set)
	-- body
	windower.add_to_chat(8, "Creating xml file...")
	local myPlayer = windower.ffxi.get_player()
	local gear_for_collector = {}
	set_gearcollector_recursive(set, gear_for_collector)
	local path = windower.windower_path..'plugins/spellcast/'..myPlayer.name.."_"..myPlayer.main_job..".xml"
	--send_command('@input /echo ----- '..path)
	
	local f = io.open(path,'w+')
	f:write('<?xml version="1.0" ?>\n')
	f:write('\t<spellcast>\n')
	f:write('\t\t<sets>\n')
	f:write('\t\t\t<group default="yes" name="'..myPlayer.main_job..'">\n')
	f:write('\t\t\t\t<set name="gearcollector">\n')
	for k,v in pairs(gear_for_collector) do
		if k == "empty" then
			-- do nothing (if you never have something in range slot, like my WHM, there will be
			-- a slot called empty, we need to skip it)
		else
			f:write('\t\t\t\t\t<item>'..k..'</item>\n')
		end
		--windower.add_to_chat(8, k..'\t')
	end
	f:write('\t\t\t\t</set>\n')
	f:write('\t\t\t</group>\n')
	f:write('\t\t</sets>\n')
	f:write('\t</spellcast>\n')
	f:write('</xml>')
	f:flush()
	f:close()
	windower.add_to_chat(8, "Done! Your file ".. myPlayer.name.."_"..myPlayer.main_job..".xml is in you spellcast folder")
end

-- iterate recursively through all the lua set table
function set_gearcollector_recursive(set, gear_for_collector)
	-- body
	if not set then
		return
	end
	for k,v in pairs(set) do
		if (type(v) == "table") then
			-- if a table is found it will be explored
			set_gearcollector_recursive(v, gear_for_collector)
		else
			-- else the key of the gear_for_collector table will be set as the gear
			gear_for_collector[v] = true
		end
	end
end
