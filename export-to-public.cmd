mkdir public
xcopy SpecFlow\*.md public /q
xcopy SpecFlow\.attachments\* public\.attachments\ /E /q /Y
cd public
for %f in (*) do claat export "%~nxf"
for %f in (*) do del "%~nxf"
rmdir .attachments\ /s /q