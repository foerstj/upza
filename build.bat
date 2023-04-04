:: This script is supposed to be executed from your DS installation folder.
:: TankCreator and gaspy are expected to be in sibling dirs.

:: name of map
set map=upza
:: name of map, case-sensitive
set map_cs=Utraean Peninsula - Zombie Apocalypse
:: name of resources
set res=upza
:: path of DSLOA documents dir (where Bits are)
set doc_dsloa=%USERPROFILE%\Documents\Dungeon Siege LoA
:: path of DS installation
set ds=.
:: path of TankCreator
set tc=..\TankCreator
:: path of GasPy
set gaspy=..\gaspy

:: param
set mode=%1
echo %mode%

:: pre-build checks
pushd %gaspy%
venv\Scripts\python -m build.check_player_world_locations %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_lore %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_moods %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_quests %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_dupe_node_ids %map%
if %errorlevel% neq 0 pause
venv\Scripts\python -m build.check_tips %map%
if %errorlevel% neq 0 pause
setlocal EnableDelayedExpansion
if "%mode%"=="release" (
  venv\Scripts\python -m build.check_cam_blocks %map%
  if !errorlevel! neq 0 pause
)
endlocal
popd

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
::robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xf .gitignore /xd regions
for %%r in (gi_a gi_a_r2 swamp2gi swamp_town of_r1) do (
  robocopy "%doc_dsloa%\Bits\world\maps\%map%\regions\%%r" "%tmp%\Bits\world\maps\%map%\regions\%%r" /E
)
pushd %gaspy%
venv\Scripts\python -m build.fix_start_positions_required_levels %map% "%tmp%\Bits"
if %errorlevel% neq 0 pause
SETLOCAL EnableDelayedExpansion
if not "%mode%"=="light" (
  venv\Scripts\python -m build.add_world_levels %map% "%tmp%\Bits" "%doc_dsloa%\Bits"
  if !errorlevel! neq 0 pause
)
ENDLOCAL
popd
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "CC-BY-SA 2023" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

:: Compile resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%doc_dsloa%\Bits\art\bitmaps" "%tmp%\Bits\art\bitmaps" /E /xf .gitignore /xf *.psd
robocopy "%doc_dsloa%\Bits\art\meshes" "%tmp%\Bits\art\meshes" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\art\terrain\generic\bridge" "%tmp%\Bits\art\terrain\generic\bridge" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\ai\jobs\%res%" "%tmp%\Bits\world\ai\jobs\%res%" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\ai\jobs\minibits" "%tmp%\Bits\world\ai\jobs\minibits" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\global\moods\%res%" "%tmp%\Bits\world\global\moods\%res%" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\global\effects" "%tmp%\Bits\world\global\effects" %res%-* /S
robocopy "%doc_dsloa%\Bits\world\contentdb\components\%res%" "%tmp%\Bits\world\contentdb\components\%res%" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\contentdb\templates\%res%" "%tmp%\Bits\world\contentdb\templates\%res%" /E /xf .gitignore
robocopy "%doc_dsloa%\Bits\world\contentdb\templates\minibits" "%tmp%\Bits\world\contentdb\templates\minibits" /E /xf .gitignore
%tc%\RTC.exe -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "CC-BY-SA 2022" -title "%map_cs%" -author "Johannes Förstner"
if %errorlevel% neq 0 pause

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
