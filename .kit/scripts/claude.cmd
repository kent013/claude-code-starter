@echo off
setlocal enabledelayedexpansion

rem claude.cmd: Launch Claude Code CLI using the VSCode extension's native binary (Windows).
rem Dynamically finds the latest installed version so it follows extension updates.

set "EXT="
for %%B in ("%USERPROFILE%\.vscode\extensions" "%USERPROFILE%\.vscode-insiders\extensions") do (
  if exist "%%~B" (
    for /f "delims=" %%D in ('dir /b /ad /o:n "%%~B\anthropic.claude-code-*" 2^>nul') do (
      set "EXT=%%~B\%%D"
    )
    if defined EXT goto :found
  )
)

:found
if not defined EXT (
  echo Error: anthropic.claude-code VSCode extension not found. 1>&2
  echo Install 'Claude Code' from the VSCode marketplace first. 1>&2
  exit /b 1
)

set "CLAUDE=%EXT%\resources\native-binary\claude.exe"
if not exist "%CLAUDE%" (
  echo Error: Claude Code binary not found at %CLAUDE% 1>&2
  exit /b 1
)

"%CLAUDE%" %*
