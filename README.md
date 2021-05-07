# bombjack
Clone of an old arcade game which was ported to several plateforms like Amstrad CPC, etc.

The game is hosted in Itch.io : https://fongor74.itch.io/bombjack

The code is splitted in two parts:

# The game itself

The game was created with Lua/Love2D and contain:
- .lua files
- A shader file (.glsl) for the color effects
- Some .json files for the load of the images/sprites and one for local highscores
- Sounds/Musics taken from here: https://downloads.khinsider.com/game-soundtracks/album/bomb-jack-arcade
- Graphics: screens and sprite sheet
- Bat-file for building .love and .zip file and for uploading on itch.io together with buttler.exe (https://itchio.itch.io/butler).

The game has a dependencies: 
- LuaSocket which has to be loaded separately from http://w3.impa.br/~diego/software/luasocket/ and stores in a subfolder socket
- TESound.lua which is included.

# The server part

The server part was written in Python with Flask/Unicorn and the highscores are stored in a Postgrsql database. It contains:
- .py files
- A .service file for the service creation for gunicorn
- a .yaml file for the installation with Ansible on a Ubuntu server (v20.04)
