-- a lua gearswap file for whm.
--Keep it simple!
function get_sets()

	include('generate_gearcollectorfile.lua') --need to load this to use the 'gs c gearcollector' command
	do_midcast = true

	-- PRECAST SETS
	sets.precast = {}
	sets.precast.FastCast = {head="Nahtirah Hat", neck="Orison locket", ear1="Enchntr. Earring +1", ear2="Loquacious Earring",
							body="Hedera Cotehardie", hands="Gendewitha Gages", waist="Witful Belt", legs="Orvail Pants", feet="Augur's Gaiters"}

	-- MIDCAST SETS
	sets.midcast = {}
	
	sets.midcast['Healing Magic'] = {}

	sets.midcast['Healing Magic'].Cure = {main="Tamaxchi",sub="Genbu's Shield", ammo="Incantor Stone",
        head="Gende. Caubeen", neck="Colossus's Torque",ear1="Orison Earring",ear2="Loquac. Earring",
        body="Orison Bliaud +2",hands="Bokwus Gloves",ring1="Ephedra Ring",ring2="Sirona's Ring",
        back="Medala Cape",waist="Witful Belt",legs="Orsn. Pantaln. +2",feet="Rubeus Boots"}

    sets.midcast['Healing Magic'].Curaga = set_combine(sets.midcast['Healing Magic'].Cure, {body="Gendewitha Bliaut", ring1="Karka Ring",
    	feet="Nares Clogs"})

    -- check cursna
    sets.midcast["Healing Magic"].Cursna = set_combine(sets.precast.FastCast, {head="Orison Cap +2", body="Orison Bliaud +2", 
    	hands="Hieros Mittens", ring1="Ephedra Ring", ring2="Sirona's Ring",	back="Mending Cape", legs="Orsn. Pantaln. +2", feet="Gende. Galoshes"})

    sets.midcast['Enhancing Magic'] = {neck="Colossus's Torque",
		hands="Augur's Gloves", back="Merciful Cape", legs="Portent Pants", feet="Orsn. Duckbills +2"}

	sets.midcast['Enhancing Magic'].Barspell = {head="Orison Cap +2", neck="Colossus's Torque", body="Orison Bliaud +2", ear2="Loquac. Earring",
		hands="Augur's Gloves", ring1="Karka Ring", ring2="Sirona's Ring", back="Merciful Cape", waist="Witful Belt", legs="Cleric's Pantaln.",
		feet="Orsn. Duckbills +2"}

	sets.midcast['Enhancing Magic'].Regen = {body="Cleric's briault", hands="Orison Mitts +2"}

	sets.midcast['Enfeebling Magic'] = {main="Baqil Staff",sub="Mephitis Grip", ammo="Memoria Sachet",
        head="Buremte Hat",neck="Enfeebling Torque",ear1="Lifestorm Earring",ear2="Psystorm Earring",
        body="Nares Saio",hands="Rubeus Gloves",ring1="Sangoma Ring",ring2="Perception Ring",
        back="Refraction Cape",waist="Aswang Sash",legs="Portent Pants",feet="Rubeus Boots"}

    -- TODO
    sets.midcast['Divine Magic'] = sets.midcast['Enfeebling Magic']

	sets.midcast['Elemental Magic'] = {}

	sets.midcast['Dark Magic'] = {}
    -- TODO set stun
    sets.midcast['Dark Magic'].Stun = set_combine(sets.precast.FastCast, {main="Apamajas II",sub="Mephitis Grip"})

    -- AFTERCAST SETS
    sets.Idle = {main="Owleyes",sub="Genbu's Shield", ammo="Memoria Sachet",
        head="Wivre Hairpin",neck="Twilight Torque",
        body="Orison Bliaud +2",hands="Serpentes Cuffs",ring1="Dark Ring",ring2="Dark Ring",
        back="Umbra Cape",waist="Fucho-no-Obi",legs="Nares Trews",feet="Serpentes Sabots"}

    -- JA SETS

    --serve? insieme di tutti i buff che non richiedono skill
    NoSkillBuff = { ['Refresh']=true, ['Haste']=true, ['Aquaveil']=true, ['Blink']=true, ['Sneak']=true, ['Invisible']=true,
		['Deodorize']=true, ['Warp']=true, ['Warp II']=true, ['Reraise']=true, ['Reraise II']=true, ['Reraise III']=true, ['Arise']=true,
		['Raise']=true, ['Raise II']=true, ['Raise III']=true}

    --cambia macro book
    send_command('input /macro book 11;wait .1;input /macro set 1')

end

function precast(spell)
	if spell.action_type == 'Magic' then
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
	equip(sets.Idle)
end

function status_change(new,tab)
    if T{'Idle','Resting'}:contains(new) then
        equip(sets.Idle)
        enable('main', 'sub', 'range')
    elseif new == 'Engaged' then
        disable('main', 'sub', 'range')
    end
end

-- Called when a player gains or loses a status.
-- status == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
--function buff_change(status,gain)
    
--end

function self_command(command)
    if command == 'gearcollector' then
        set_gearcollector(sets)
    end
end


-- CUSTOM FUNCTION
-- since I need to check the spell two times I made a custom function
-- check the condition (spell, weather conditions, ecc) and apply the right set
function conditional_equip(spell,set)
	if not set then
		return 
	end
	--TODO buff storm?
	if spell.skill=="Healing Magic" then
		if string.find(spell.english,'Cure') then
			equip(sets.midcast[spell.skill].Cure)
		elseif string.find(spell.english,'Cura') then
			equip(sets.midcast[spell.skill].Curaga)
		elseif spell.english == 'Cursna' then
			equip(sets.midcast[spell.skill].Cursna)
		elseif string.match(spell.english, '*na') then
			equip({head="Orison Cap +2"})
		end
	elseif spell.skill=="Enhancing Magic" then
		if string.match(spell.english, "Bar*") then
			equip(sets.midcast[spell.skill].Bar)
		elseif string.find(spell.english, 'Regen') then
			equip(sets.midcast[spell.skill].Regen)
		end
	elseif NoSkillBuff[spell.english] then
		equip(sets.precast.FastCast)
	else
		equip(set)
	end
end