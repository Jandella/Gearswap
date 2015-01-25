function get_sets()

	windower.register_event('hpp change', hpp_change)
	include('generate_gearcollectorfile.lua')
	mode = T{"HYB", "PDT", "TP"} -- modes should be defined all uppercase
	currentMode = 1 -- the current mode
	debug = false -- for debugging purpose

	sets.weapon = {{main="Buramenk'ah", sub="Ochain"}, {main="Sanus Ensis", sub="Ochain"}}

	sets.JA = {}

	sets.JA.Rampart = {head="Valor Coronet"}
	sets.JA.Sentinel = {feet="Valor Leggings"}
	sets.JA.Invincible = {legs="Cab. Breeches"}
	sets.JA["Divine Emblem"] = {feet="Creed Sabatons +2"}


	sets.Engaged={}
	
	sets.Engaged.TP = {ammo="Oneiros Pebble", head="Yaoyotl Helm", neck="Agitator's Collar", ear1="Steelflash Earring", 
		ear2="Bladeborn Earring", body="Xaddi Mail", hands="Buremte Gloves", ring1="K'ayres Ring", ring2="Mars's Ring", 
		back="Letalis Mantle", waist="Zoran's Belt", legs="Cizin Breeches +1", feet="Whirlpool Greaves"}

	sets.Engaged.PDT = {ammo="Angha Gem", head="Laeradr Helm", neck="Twilight Torque", ear1="Ethereal Earring", 
		ear2="Creed Earring", body="Cab. Surcoat", hands="Buremte Gloves", ring1="Dark Ring", ring2="Dark Ring", 
		back="Repulse Mantle", waist="Nierenschutz", legs="Cab. Breeches", feet="Phorcys Schuhs"}

	sets.Engaged.HYB = set_combine(sets.Engaged.PDT, {neck="Agitator's Collar", ear1="Steelflash Earring", ear2="Bladeborn Earring", 
		back="Weard Mantle", waist="Zoran's Belt", legs="Cizin Breeches +1", feet="Cizin Greaves +1"})

	sets.Twilight = {head="Twilight Helm", body="Twilight Mail"}


	sets.weaponskill={}

	sets.weaponskill.TP = {ammo="Oneiros Pebble", head="Otomi Helm", neck="Agitator's Collar", ear1="Moonshade Earring",
		ear2="Brutal Earring", body="Gorney Haubert +1", hands="Umuthi Gloves", ring1="Ifrit Ring",
		ring2="Ifrit Ring", back="Buquwik Cape", waist="Caudata Belt", legs="Cizin Breeches +1", feet="Whirlpool Greaves"}

	sets.weaponskill.PDT = sets.Engaged.PDT

	sets.weaponskill.HYB = sets.weaponskill.TP
	
	-- WS specifiche

	sets.weaponskill["Atonement"] = set_combine(sets.Engaged.PDT, {body="Phorcys Korazin", legs="Ogier's Breeches"})

	sets.weaponskill["Requiescat"] = set_combine(sets.weaponskill.TP, {neck="Soil Gorget", ring1="Aquasoul Ring",
		back="Tuilha Cape", waist="Shadow Belt"})

	-- Idle sets

	sets.Idle = {}

	sets.Idle.PDT = sets.Engaged.PDT

	sets.Idle.TP = set_combine(sets.Idle.PDT, {body="Laeradr Breastplate", legs="Blood Cuisses"})

	sets.Idle.HYB = set_combine(sets.Idle.PDT, {body="Laeradr Breastplate", legs="Blood Cuisses"})

	sets.Resting = sets.Idle

	-- MAGIC RELATED sets
	
	sets.FastCast = {head="Creed Armet +2", neck="Orunmila's torque", legs="Blood Cuisses"}
	
	sets.Gearcollector = {ring1="Warp Ring"}

end

function precast(spell)
	if player.equipment.body == 'Twilight Mail' then
		 disable('head','body')
        if debug then
			send_command('@input /echo [DEBUG] Twilight detected and disabling slots')
		end
	end
	-- body
	if spell.action_type:lower() == 'magic' then
		if mode[currentMode] ~= 'PDT' then -- if mode is PDT won't swich for casting spells
			if debug then
				send_command('@input /echo [DEBUG] if spell branch, current Mode: '..mode[currentMode])
			end
			equip(sets.FastCast)
		else
			if debug then
				send_command('@input /echo [DEBUG] else spell branch, current Mode '..mode[currentMode])
			end
		end
	end
	if spell.type:lower() == "weaponskill" then
		-- TODO  T{"Amnesia", "Sleep", "Stun", "Terror", "Petrification"}:contains(buffactive) or
		local buff = buffactive.amnesia or buffactive.sleep or buffactive.stun or buffactive.terror or buffactive.petrification
		if player.vitals.tp < 1000 or spell.target.distance > 5.5 or player.status ~= 'Engaged' or buff then
			cancel_spell()
			if debug then
				send_command('@input /echo [DEBUG] ws cancelled for detrimental or improper status')
			end
			return
		end
		if sets.weaponskill[mode[currentMode]] then
			equip(sets.weaponskill[mode[currentMode]])
		end
		if mode[currentMode] ~= 'PDT' then
			if debug then
				send_command('@input /echo [DEBUG] weaponskill branch, current Mode: '..mode[currentMode])
			end
			if sets.weaponskill[spell.english] then
				equip(sets.weaponskill[spell.english])
			end
		end
	elseif sets.JA[spell.english] then
		equip(sets.JA[spell.english])
	elseif T{'Spectral Jig', 'Monomi: Ichi'}:contains(spell.english) and buffactive.sneak then
        windower.ffxi.cancel_buff(71)
	end
end

function midcast(spell)
	-- if mode is PDT won't swich for casting spells
	if spell.english == "Utsusemi: Ichi" and buffactive["copy image"] then
		windower.ffxi.cancel_buff(66)
	end
end

function aftercast(spell)
	-- body
	if sets[player.status] then
		equip(sets[player.status])
		if debug then
        	send_command('@input /echo [DEBUG]aftercast equipped sets.'..player.status)
        end
		if sets[player.status][mode[currentMode]] then
			equip(sets[player.status][mode[currentMode]])
			if debug then
				send_command('@input /echo [DEBUG]aftercast equipped sets.'..player.status..mode[currentMode])
			end
		end
	end
end

-- Triggers on player status change. This only triggers for the following statuses:
-- Idle, Engaged, Resting, Dead, Zoning
function status_change(new,old)
	 disable('head','body')
        if debug then
			send_command('@input /echo [DEBUG] Doomed! Equipping Twilight and disabling slots')
		end
	if player.equipment.body ~= 'Twilight Mail' then
		enable('head', 'body')
		if debug then
			send_command('@input /echo [DEBUG] no Twilight gear detected, enabling head e body slot')
		end
	end
    if T{'Idle','Resting'}:contains(new) then
        equip(sets[new])
        if debug then
        	send_command('@input /echo [DEBUG]1 equipped sets.'..new)
        end
        if sets[new][mode[currentMode]] then
        	equip(sets[new][mode[currentMode]])
        	if debug then
        		send_command('@input /echo [DEBUG]1 equipped sets.'..new..mode[currentMode])
        	end
        end
    elseif new == 'Engaged' then
        if equip(sets[new][mode[currentMode]]) then
        	equip(sets[new][mode[currentMode]])
        	if debug then
        		send_command('@input /echo [DEBUG]2 equipped sets.'..new..mode[currentMode])
        	end
        else
        	equip(sets[new])
        	if debug then
        		send_command('@input /echo [DEBUG]2 equipped sets.'..new)
        	end
        end
    end
end

-- Called when a player gains or loses a status.
-- status == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function buff_change(status,gain)
    if gan and status == 'Doom' then 
        equip(sets.Twilight)
        disable('head','body')
        if debug then
			send_command('@input /echo [DEBUG] Doomed! Equipping Twilight and disabling slots')
		end
    end
end

-- Triggers on HP change. 
function hpp_change(new_hpp, old_hpp)
	if new_hpp < 20 then
		equip(sets.Twilight)
		disable('head','body')
		if debug then
			send_command('@input /echo [DEBUG] hp < 20% equipping Twilight and disabling slots')
		end
	end
end

function self_command(command)
	-- by typing gs c switch mode it will cycle through the various set modes (tp, pdt, acc,...)
    if command == 'switch mode' then
        currentMode = currentMode + 1
        if currentMode > #mode then 
        	currentMode = 1
        end
        send_command('@input /echo ----- Mode changed to '..mode[currentMode]..' -----')
        equip(sets[player.status][mode[currentMode]])
    -- by typing gs c HYB [or TP or PDT or whichever set you define in mode will switch to that mode]
    elseif mode:contains(command:upper()) then
    	if(sets[player.status][command:upper()]) then
	    	equip(sets[player.status][command:upper()])
	    end
	    local newMode = find_index(command, mode)
	    if newMode > 0 then
	    	currentMode = newMode
	    	send_command('@input /echo ----- Mode changed to '..command:upper()..' -----')
	    end
	elseif command == 'gearcollector' then
        set_gearcollector(sets)
    elseif command:lower() == 'debug' then --for debugging purpose, will show print on /echo game chat
    	if debug then
    		debug = false
    		send_command('@input /echo Debug mode: OFF')
    	else
    		debug = true
    		send_command('@input /echo Debug mode: ON')
    	end
    end
end

-- CUSTOM function
-- finds the string in the table and returns the index of the string
-- returns -1 if stringa isn't in the table
function find_index(stringa, table)
	-- body
	for i, v in ipairs(table) do
		local current = v:upper()
		local confronto = stringa:upper()
		if current == confronto then
			return i
		end
	end
	return -1
end
