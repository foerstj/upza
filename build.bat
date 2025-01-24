:: name of map
set map=upza
:: name of map, case-sensitive
set map_cs=Utraean Peninsula - Zombie Apocalypse
:: name of resources
set res=upza

:: path of Bits dir
set bits=%~dp0.
:: path of DS installation
set ds=%DungeonSiege%
:: path of TankCreator
set tc=%TankCreator%

:: tank properties
set year=2025
set copyright=CC-BY-SA %year%
set title=%map_cs%
set author=Johannes Förstner

:: param
set mode=%1
echo %mode%

:: pre-build checks
pushd %gaspy%
setlocal EnableDelayedExpansion
if not "%mode%"=="light" (
  set checks=standard
  if "%mode%"=="release" (
    set checks=all
  )
  venv\Scripts\python -m build.pre_build_checks %map% --check !checks!
  if !errorlevel! neq 0 pause
)
endlocal
popd

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
if not "%mode%"=="light" (
  robocopy "%bits%\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xf .gitignore
)
if "%mode%"=="light" (
  robocopy "%bits%\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /E /xf .gitignore /xd regions
  for %%r in (des_r1 des_r2 grs2des gp_r1) do (
    robocopy "%bits%\world\maps\%map%\regions\%%r" "%tmp%\Bits\world\maps\%map%\regions\%%r" /E
  )
)
pushd %gaspy%
venv\Scripts\python -m build.fix_start_positions_required_levels %map% --bits "%tmp%\Bits"
if %errorlevel% neq 0 pause
setlocal EnableDelayedExpansion
if "%mode%"=="release" (
  venv\Scripts\python -m build.add_world_levels %map% --bits "%tmp%\Bits" --template-bits "%bits%"
  if !errorlevel! neq 0 pause
)
endlocal
popd
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

:: Compile main resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%bits%\art" "%tmp%\Bits\art" *.nnk /S
robocopy "%bits%\art\animations" "%tmp%\Bits\art\animations" /E /xf .gitignore
robocopy "%bits%\art\bitmaps" "%tmp%\Bits\art\bitmaps" /E /xf .gitignore /xf *.psd
robocopy "%bits%\art\meshes" "%tmp%\Bits\art\meshes" /E /xf .gitignore
robocopy "%bits%\art\terrain\generic" "%tmp%\Bits\art\terrain\generic" /E /xf .gitignore /xf .bak
robocopy "%bits%\art\terrain\desert_canyon" "%tmp%\Bits\art\terrain\desert_canyon" /E /xf .bak
robocopy "%bits%\sound" "%tmp%\Bits\sound" /E /xf .gitignore
robocopy "%bits%\world\ai\jobs\%res%" "%tmp%\Bits\world\ai\jobs\%res%" /E /xf .gitignore
robocopy "%bits%\world\ai\jobs\minibits" "%tmp%\Bits\world\ai\jobs\minibits" /E /xf .gitignore
robocopy "%bits%\world\global\moods\%res%" "%tmp%\Bits\world\global\moods\%res%" /E /xf .gitignore
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" %res%-* /S
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" minibits-* /S
robocopy "%bits%\world\contentdb\components\%res%" "%tmp%\Bits\world\contentdb\components\%res%" /E /xf .gitignore
robocopy "%bits%\world\contentdb\components\minibits" "%tmp%\Bits\world\contentdb\components\minibits" /E /xf .gitignore
robocopy "%bits%\world\contentdb\templates\%res%" "%tmp%\Bits\world\contentdb\templates\%res%" /E /xf .gitignore
robocopy "%bits%\world\contentdb\templates\minibits" "%tmp%\Bits\world\contentdb\templates\minibits" /E /xf .gitignore
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

:: Compile language resource file
setlocal EnableDelayedExpansion
if not "%mode%"=="light" (
  rmdir /S /Q "%tmp%\Bits"
  robocopy "%bits%\language" "%tmp%\Bits\language" /E /xf .gitignore
  "%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.de.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
  if !errorlevel! neq 0 pause
)
endlocal

:: Cleanup
rmdir /S /Q "%tmp%\Bits"
