function get_sets()

	include('generate_gearcollectorfile.lua')
	mode = T{"TP", "ACC", "PDT"} -- modes should be defined all uppercase
	currentMode = 1
  
	sets.weapon = {main="Oatixur"}

	sets.JA = {}
	sets.JA.Chakra = {hands="Mel. Gloves +2", ring1="Spiral Ring", ring2="Terrasoul Ring", back="Anchoret's Mantle",
		waist="Caudata Belt", feet="Thurandaut Boots"}
	sets.JA.Counterstance={feet="Melee Gaiters"}

	sets.Engaged={}
	sets.Engaged.TP = set_combine(sets.weapon, {ammo="Honed Tathlum", head="Whirlpool Mask", neck="Asperity Necklace", ear1="Steelflash Earring",
		ear2="Bladeborn Earring", body="Thaumas Coat", hands="Otronif Gloves", ring1="Rajas Ring", ring2="Epona's Ring", 
		back="Letalis Mantle", waist="Windbuffet Belt", legs="Otronif Brais", feet="Otronif Boots +1"})

	sets.Engaged.PDT = set_combine(sets.Engaged.TP, {neck="Twilight torque", ring1="Dark Ring", ring2="Dark Ring", back="Repulse Mantle",
		feet="Thurandaut Boots"})

	sets.Engaged.ACC = sets.Engaged.TP

	sets.weaponskill={}
	sets.weaponskill.TP = {ammo="Thunder Sachet", head="Whirlpool Mask", neck="Light Gorget", ear1="Steelflash Earring",
		ear2="Bladeborn Earring", body="Otronif Harness", hands="Otronif Gloves", ring1="Rajas Ring",
		ring2="Epona's Ring", back="Atheling Mantle", waist="Wanion Belt", legs="Manibozho", feet="Otronif Boots +1"}

	sets.weaponskill.PDT = sets.weaponskill.TP
	sets.weaponskill.ACC = sets.weaponskill.TP

	-- WS specifiche
	sets.weaponskill["Asuran Fist"] = set_combine(sets.weaponskill.TP, {ammo="Flame Sachet", neck="Justice Torque", ring1="Pyrosoul Ring",
		waist="Caudata Belt", legs="Otronif Brais"})

	sets.weaponskill["Ascetic Fury"] = set_combine(sets.weaponskill.TP, {ammo="Flame Sachet", neck="Justice Torque", ring1="Pyrosoul Ring",
		back="Rancorous Mantle", waist="Caudata Belt", legs="Otronif Brais"})

	sets.Idle = {ammo="Honed Tathlum", head="Whirlpool Mask", neck="Wiglen Gorget", ear1="Steelflash Earring",
		ear2="Bladeborn Earring", body="Melee Cyclas", hands="Mel. Gloves +2", ring1="Rajas Ring",
		ring2="Epona's Ring", back="Repulse Mantle", waist="Windbuffet Belt", legs="Otronif Brais", feet="Hermes' Sandals"}

	sets.Resting = sets.Idle

	sets.Gearcollector = {ring1="Warp Ring"}
end

function precast(spell)
	-- body
	if spell.type:lower() == "weaponskill" then
		-- TODO  T{"Amnesia", "Sleep", "Stun", "Terror", "Petrification"}:contains(buffactive) or 
		if player.vitals.tp < 1000 then
			return
		end
		equip(sets.weaponskill[mode[currentMode]])
		if sets.weaponskill[spell.english] then
			equip(sets.weaponskill[spell.english])
		end
	elseif sets.JA[spell.english] then
		equip(sets.JA[spell.english])
	elseif T{'Spectral Jig', 'Monomi: Ichi'}:contains(spell.english) and buffactive.sneak then
        windower.ffxi.cancel_buff(71)
	end
end

function midcast(spell)
	-- body
	if spell.english == "Utsusemi: Ichi" and buffactive["copy image"] then
		windower.ffxi.cancel_buff(66)
	end
end

function aftercast(spell)
	-- body
	if sets[player.status] then
		equip(sets[player.status])
		if sets[player.status][mode[currentMode]] then
			equip(sets[player.status][mode[currentMode]])
		end
	end
end

-- Triggers on player status change. This only triggers for the following statuses:
-- Idle, Engaged, Resting, Dead, Zoning
function status_change(new,old)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets[new])
        if sets[new][mode[currentMode]] then
        	equip(sets[new][mode[currentMode]])
        end
    elseif new == 'Engaged' then
        if equip(sets[new][mode[currentMode]]) then
        	equip(sets[new][mode[currentMode]])
        else
        	equip(sets[new])
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
        equip(sets.Engaged[mode[currentMode]])
    -- by typing gs c TP [or ACC or PDT or whichever set you define in mode will switch to that mode]
    elseif mode:contains(command) then
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
