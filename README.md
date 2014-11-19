Gearswap
========

My gearswap file, with libraries

* <b>Jandel_BLM.lua:</b> this file contains the gearswap for my blm.

* <b>Jandel_WHM.lua:</b> this file contains the gearswap for my whm.

* <b>generate_gearcollectorfile.lua:</b> this file contains the function to create an xml spellcast-like for the use of the plugin gearcollector<br />
Include the file with this line of code <code>include('generate_gearcollectorfile.lua')</code> in <code>get_sets()</code>
<br />
To use the function, put this code in the <code>function self_command(command)</code> like this:
<br />
<code>if command == 'gearcollector' then
        set_gearcollector(sets)
end</code>
<br />
Then, to use it ingame, just type <code>//gs c gearswap</code>.
<br />
The xml file will be created with name <playername>_<playercurrentjob>.xml into Gearswap folder
