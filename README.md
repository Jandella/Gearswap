Gearswap
========

My gearswap file, with libraries

**BLM.lua:** this file contains the gearswap for my blm.

**WHM.lua:** this file contains the gearswap for my whm.

**MNK.lua:** this file contains the gearswap for mnk.

**generate_gearcollectorfile.lua:** this file contains the function to create an xml spellcast-like for the use of the plugin gearcollector

Include the file with this line of code `include('generate_gearcollectorfile.lua')` in `get_sets()`.

To use the function, put this code in the <code>function self_command(command)</code> like this:
```
if command == 'gearcollector' then
        set_gearcollector(sets)
end
```
Then, to use it ingame, just type `//gs c gearcollector`.
The xml file will be created with name [playername]_[playercurrentjob].xml into default spellcast folder ( `C:/Your/Windower/Folder/plugins/spellcast/` ).
If exist a file with the same name it will be overwritten.
