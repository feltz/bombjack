cd /d D:\WORK\Développement\Lua\bombjack
"C:\Program Files\7-Zip\7z.exe" a bombjack-love\bombjack.love *.lua -i!.\*.json -i!.\*.png -i!.\*.glsl -ir!sounds\*.* -ir!sprites\*.* -ir!sounds\*.* -ir!graphics\*.* -ir!socket\*.* -tzip
copy /b /y D:\Applications\LOVE\love.exe+D:\WORK\Developpement\Lua\bombjack\bombjack-love\bombjack.love D:\WORK\Developpement\Lua\bombjack\bombjack-64bits\bombjack.exe
cd /d D:\WORK\Developpement\Lua\bombjack\bombjack-64bits
del bombjack-win-64bits.zip
"C:\Program Files\7-Zip\7z.exe" a bombjack-win-64bits.zip *.* -tzip
D:\WORK\Developpement\Lua\bombjack\butler push D:\WORK\Developpement\Lua\bombjack\bombjack-love fongor74/bombjack:love --userversion 1.03
D:\WORK\Developpement\Lua\bombjack\butler push D:\WORK\Developpement\Lua\bombjack\bombjack-64bits fongor74/bombjack:bombjack-win-64bits.zip --userversion 1.03