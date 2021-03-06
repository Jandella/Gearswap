-- a lua gearswap file for whm.
--Keep it simple!
function get_sets()

	include('generate_gearcollectorfile.lua') --need to load this to use the 'gs c gearcollector' command
	do_midcast = true

	-- PRECAST SETS
	sets.precast = {}
	sets.precast.FastCast = {head="Nahtirah Hat", neck="Orison locket", ear1="Enchntr. Earring +1", ear2="Loquacious Earring",
							body="Hedera Cotehardie", hands="Gendewitha Gages", waist="Witful Belt", legs="Artsieq Hose", feet="Augur's Gaiters"}
	-- calculated by hand from equip
	gear_fastcast = 5 + 2 + 2 + 7 + 3 + 5 + 3
	total_fastcast = gear_fastcast

	-- MIDCAST SETS
	sets.midcast = {}
	
	sets.midcast['Healing Magic'] = {}

	sets.midcast['Healing Magic'].Cure = {main="Tamaxchi",sub="Genbu's Shield", ammo="Incantor Stone",
        head="Gende. Caubeen +1", neck="Colossus's Torque",ear1="Orison Earring",ear2="Loquac. Earring",
        body="Orison Bliaud +2",hands="Bokwus Gloves",ring1="Ephedra Ring",ring2="Sirona's Ring",
        back="Medala Cape",waist="Witful Belt",legs="Orsn. Pantaln. +2",feet="Rubeus Boots"}

    sets.midcast['Healing Magic'].Curaga = set_combine(sets.midcast['Healing Magic'].Cure, {body="Gende. Bliaut +1", ring1="Karka Ring",
    	feet="Gende. Galoshes"})

    -- check cursna
    sets.midcast["Healing Magic"].Cursna = set_combine(sets.precast.FastCast, {head="Orison Cap +2", body="Orison Bliaud +2", 
    	hands="Hieros Mittens", ring1="Ephedra Ring", ring2="Sirona's Ring",	back="Mending Cape", legs="Orsn. Pantaln. +2", feet="Gende. Galoshes"})

    sets.midcast["Healing Magic"].na = set_combine(sets.precast.FastCast, {head="Orison Cap +2"})

    sets.midcast['Enhancing Magic'] = {neck="Colossus's Torque",
		hands="Augur's Gloves", back="Merciful Cape", legs="Portent Pants", feet="Orsn. Duckbills +2"}

	sets.midcast['Enhancing Magic'].Stoneskin = {ear1="Earthcry Earring", back="Siegel Sash"}

	sets.midcast['Enhancing Magic'].Barspell = {head="Orison Cap +2", neck="Colossus's Torque", body="Orison Bliaud +2", ear2="Loquac. Earring",
		hands="Augur's Gloves", ring1="Karka Ring", ring2="Sirona's Ring", back="Merciful Cape", waist="Witful Belt", legs="Cleric's Pantaln.",
		feet="Orsn. Duckbills +2"}

	sets.midcast['Enhancing Magic'].Regen = {main="Bolelabunga",body="Piety Briault", hands="Orison Mitts +2"}

	sets.midcast['Enfeebling Magic'] = {main="Baqil Staff",sub="Mephitis Grip", ammo="Memoria Sachet",
        head="Buremte Hat",neck="Enfeebling Torque",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        body="Ischemia Chasu.",hands="Rubeus Gloves",ring1="Sangoma Ring",ring2="Perception Ring",
        back="Refraction Cape",waist="Aswang Sash",legs="Portent Pants",feet="Rubeus Boots"}

    -- TODO
    sets.midcast['Divine Magic'] = sets.midcast['Enfeebling Magic']

	sets.midcast['Elemental Magic'] = {}

	sets.midcast['Dark Magic'] = {}
    -- TODO set stun
    sets.midcast['Dark Magic'].Stun = set_combine(sets.precast.FastCast, {main="Apamajas II",sub="Mephitis Grip"})

    -- AFTERCAST SETS
    sets.Idle = {main="Bolelabunga",sub="Genbu's Shield", ammo="Memoria Sachet",
        head="Wivre Hairpin",neck="Twilight Torque",
        body="Ischemia Chasu.",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Fucho-no-Obi",legs="Nares Trews",feet="Herald's gaiters"}

    -- JA SETS

    --serve? insieme di tutti i buff che non richiedono skill
    NoSkillBuff = { ['Refresh']=true, ['Haste']=true, ['Aquaveil']=true, ['Blink']=true, ['Sneak']=true, ['Invisible']=true,
		['Deodorize']=true, ['Warp']=true, ['Warp II']=true, ['Reraise']=true, ['Reraise II']=true, ['Reraise III']=true, ['Arise']=true,
		['Raise']=true, ['Raise II']=true, ['Raise III']=true}

    --switch macro book
    send_command('input /macro book 11;wait .1;input /macro set 1')

    -- ENGAGED SETS
    mode = T{"CLUB", "STAFF"} --modes need to be uppercase
	currentMode = 1
	sets.Engaged = {}
	sets.Engaged.CLUB = {main="Tamaxchi", sub="Genbu's Shield"}
	sets.Engaged.STAFF = {main="Baqil Staff", sub="Mephitis Grip"}
	update_fastcast()

end

function precast(spell)
	if spell.action_type == 'Magic' then
		--if spell cast time is < 3 will equip standard set, else will equip fastcast set
		if calculate_castingtime(spell) < 3 then
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
	update_fastcast(gain)    
end

function sub_job_change(new, old)
	update_fastcast()
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
-- since I need to check the spell two times I made a custom function
-- check the condition (spell, weather conditions, ecc) and apply the right set
function conditional_equip(spell,set)
	if not set then
		return 
	end
	if spell.skill=="Healing Magic" then
		if string.find(spell.english,'Cure') then
			equip(sets.midcast[spell.skill].Cure)
		elseif string.find(spell.english,'Cura') then
			equip(sets.midcast[spell.skill].Curaga)
		elseif spell.english == 'Cursna' then
			equip(sets.midcast[spell.skill].Cursna)
		elseif string.match(spell.english, '^.*na') then
			equip(sets.midcast[spell.skill].na)
		end
	elseif NoSkillBuff[spell.english] then
		equip(sets.precast.FastCast)
	elseif spell.skill=="Enhancing Magic" then
		if string.match(spell.english, "Bar*") then
			equip(sets.midcast[spell.skill].Bar)
		elseif string.find(spell.english, 'Regen') then
			equip(sets.midcast[spell.skill].Regen)
		elseif spell.english == 'Stoneskin' then
			equip(sets.midcast[spell.skill].Stoneskin)
		elseif spell.english == 'Erase' then
			equip(sets.midcast[spell.skill].na)
		end
	else
		equip(set)
	end
end

--check current subjob and light arts to update the current value of fastcast.
function update_fastcast(gain)
	-- body
	if(player.sub_job == 'RDM') then
		total_fastcast = gear_fastcast + 15
	elseif (player.sub_job == 'SCH') then
		if (gain and buffactive['Light Arts']) then
			total_fastcast = gear_fastcast + 10
		end
	else
		total_fastcast = gear_fastcast
	end
	--send_command('@input /echo ---- total fastcast '..total_fastcast)
end

--calculate casting time of the spell.
--returns the actual casting time based on fastcast and casting time reducion via merit
function calculate_castingtime(spell)
	-- body
	if (spell.action_type == 'Magic') then
		local curecastingreduction = 0
		if string.match(spell.english, "Cur*") then
			curecastingreduction = 20 --from merit
		end
		local fastcast = (total_fastcast + curecastingreduction) / 100
		local totaltimereduction = 1 - fastcast
		local castingtime = spell.cast_time * totaltimereduction
		return castingtime
	else
		return 1
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
