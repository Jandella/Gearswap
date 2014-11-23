function get_sets()

	include('generate_gearcollectorfile.lua') --need to load this to use the 'gs c gearcollector' command
	do_midcast = true

	-- PRECAST SETS
	sets.precast = {}
	sets.precast.FastCast = {head="Nahtirah Hat", ear1="Enchntr. Earring +1", ear2="Loquacious Earring",
							body="Rubeus Jacket", hands="Rubeus Gloves", waist="Witful Belt", legs="Orvail Pants", feet="Augur's Gaiters"}

	-- MIDCAST SETS
	sets.midcast = {}
	sets.midcast['Elemental Magic'] = {}
	sets.midcast['Elemental Magic'].MAB = {main="Baqil Staff",sub="Mephitis Grip",range=empty, ammo="Memoria Sachet",
        head="Hagondes Hat",neck="Stoicheion Medal",ear1="Friomisi Earring",ear2="Hecate's Earring",
        body="Hagondes Coat +1",hands="Otomi Gloves",ring1="Diamond Ring",ring2="Acumen Ring",
        back="Toro Cape",waist="Aswang Sash",legs="Hagondes Pants +1",feet="Nares Clogs"}

	sets.midcast['Dark Magic'] = {main="Baqil Staff",sub="Mephitis Grip",range=empty, ammo="Memoria Sachet",
        head="Appetence Crown",neck="Aesir Torque",ear1="Goetia Earring",ear2="Loquacious Earring",
        body="Adhara Manteel",hands="Avesta Bangles",ring1="Archon Ring",ring2="Excelsis Ring",
        back="Merciful Cape",waist="Aswang Sash",legs="Portent Pants",feet="Goetia Sabots +2"}
    -- TODO set stun
    sets.midcast['Dark Magic'].Stun = {main="Apamajas II",sub="Mephitis Grip",range=empty, ammo="Memoria Sachet",
        head="Appetence Crown",neck="Aesir Torque",ear1="Goetia Earring",ear2="Loquacious Earring",
        body="Adhara Manteel",hands="Avesta Bangles",ring1="Archon Ring",ring2="Excelsis Ring",
        back="Merciful Cape",waist="Aswang Sash",legs="Portent Pants",feet="Goetia Sabots +2"}

	sets.midcast['Enfeebling Magic'] = {main="Baqil Staff",sub="Mephitis Grip",range=empty, ammo="Memoria Sachet",
        head="Buremte Hat",neck="Enfeebling Torque",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        body="Wzd. Coat +1",hands="Rubeus Gloves",ring1="Sangoma Ring",ring2="Perception Ring",
        back="Refraction Cape",waist="Aswang Sash",legs="Portent Pants",feet="Rubeus Boots"}

	sets.midcast['Healing Magic'] = {}

	sets.midcast['Healing Magic'].Cure = {main="Tamaxchi",sub="Genbu's Shield",
        neck="Fylgja Torque",ear1="Roundel Earring",ear2="Loquacious Earring",
        body="Adhara Manteel",hands="Bokwus Gloves",ring1="Ephedra Ring",ring2="Sirona's Ring",
        back="Medala Cape",waist="Witful Belt",legs="Nares Trews",feet="Rubeus Boots"}

    sets.midcast['Enhancing Magic'] = {neck="Colossus's Torque", ear1="Earthcry Earring",
		hands="Augur's Gloves", back="Merciful Cape", legs="Portent Pants", feet="Rubeus Boots"}

	sets.midcast['Enhancing Magic'].Stoneskin = {ear1="Earthcry Earring", back="Siegel Sash"}
    
    -- AFTERCAST SETS
    sets.Idle = {main="Owleyes",sub="Genbu's Shield",range=empty, ammo="Memoria Sachet",
        head="Wivre Hairpin",neck="Twilight Torque",
        body="Hagondes Coat +1",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Fucho-no-Obi",legs="Nares Trews",feet="Serpentes Sabots"}

    -- JA SETS
    sets.JA = {}
    sets.JA["Mana Wall"] = {feet="Goetia Sabots +2"}

    -- serve? insieme di tutte le spell low tier
    LowTierSpell = { ['Blizzard']=true,['Thunder']=true,['Stone'] = true, ['Aero'] = true,['Water']=true,['Fire']=true,
    	['Blizzard II']=true,['Thunder II']=true,['Stone II'] = true, ['Aero II'] = true,['Water II']=true,['Fire II']=true}
    --serve? insieme di tutti i buff che non richiedono skill
    NoSkillBuff = { ['Refresh']=true, ['Haste']=true, ['Aquaveil']=true, ['Blink']=true, ['Sneak']=true, ['Invisible']=true,
		['Deodorize']=true, ['Warp']=true, ['Warp II']=true, ['Retrace']=true }

    --cambia macro book
    send_command('input /macro book 1;wait .1;input /macro set 1')

    -- ENGAGED SETS
    mode = T{"STAFF"} --modes need to be uppercase
	currentMode = 1
	sets.Engaged = {}
	sets.Engaged.STAFF = {main="Baqil Staff", sub="Mephitis Grip"}

end

function precast(spell)
	if spell.english == "Mana Wall" then
		equip(sets.JA[spell.english])
		disable('feet')
	elseif spell.action_type == 'Magic' then
		--if spell cast time is < 3 will equip standard set, else will equip fastcast set
		if spell.cast_time < 3 then
			-- [DEBUG] windower.add_to_chat(8, '---- Ramo if di precast, '..spell.english..' ha casting time '..spell.cast_time..' ----')
			conditional_equip(spell, sets.midcast[spell.skill])
			do_midcast = false
		else
			-- [DEBUG] windower.add_to_chat(8, '---- Ramo else di precast, '..spell.english..' ha casting time '..spell.cast_time..', equipaggio il set fastcast ----')
			equip(sets.precast.FastCast)
		end
	end
end

function midcast(spell)
	if spell.action_type == 'Magic' and do_midcast then
		conditional_equip(spell, sets.midcast[spell.skill])
	end
	do_midcast = true
end

function aftercast(spell)
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
	if sets[new] then
    	equip(sets[new])
    	if sets[new][mode[currentMode]] then
    		equip(sets[new][mode[currentMode]])
    	end
    end
    if T{'Idle','Resting'}:contains(new) and player.vitals.tp < 300 then
        enable('main', 'sub', 'range')
    elseif new == 'Engaged' then
        disable('main', 'sub', 'range')
    end
end

-- Called when a player gains or loses a status.
-- status == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function buff_change(status,gain)
    if status == 'Mana Wall' and (not gain) then 
        enable('feet')
    end
end

function self_command(command)
    if command == 'gearcollector' then
        set_gearcollector(sets)
    -- by typing gs c TP [or Acc or PDT or whichever set you define in mode will switch to that mode]
    elseif mode:contains(command:upper()) then
    	if(sets[player.status][command:upper()]) then
	    	equip(sets[player.status][command:upper()])
	    end
	    local newMode = find_index(command, mode)
	    if newMode > 0 then
	    		currentMode = newMode
	    		send_command('@input /echo ----- Mode changed to '..command:upper()..' -----')
	    end
    end
end

-- CUSTOM FUNCTION
function conditional_equip(spell,set)
	if not set then
		return 
	end
	--TODO buff storm?
	if spell.skill=="Elemental Magic" then
		equip(sets.midcast["Elemental Magic"].MAB)
		if spell.element == world.weather_element or spell.element == world.day_element then
			equip(set, {back="Twilight Cape", ring1="Zodiac Ring"})
		end
	end
	if spell.english =='Stun' then
		equip(sets.midcast[spell.skill].Stun)
		return -- return so thfollowing code will be skipped
	elseif spell.english == 'Comet' then
		equip(set, {ring1="Archon Ring"})
	elseif string.find(spell.english, 'Drain') or string.find(spell.english, 'Aspir') then
		equip(set, {waist="Fucho-no-Obi"})
	elseif string.find(spell.english,'Cur') then
		equip(set, sets.midcast[spell.skill].Cure)
	elseif NoSkillBuff[spell.english] then
		equip(sets.precast.FastCast)
	else
		equip(set)
	end
end

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
