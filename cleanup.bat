:: name of map, case-sensitive
set map_cs=Utraean Peninsula - Zombie Apocalypse

:: path of DS installation
set ds=%DungeonSiege%

:: Cleanup resources so as not to confuse Siege Editor
del "%ds%\DSLOA\%map_cs%.dsres"
del "%ds%\DSLOA\%map_cs%.*.dsres"
del "%ds%\DSLOA\%map_cs%.dsmap"
