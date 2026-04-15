@echo off
setlocal enabledelayedexpansion

rem codex.cmd: Launch Codex CLI using the VSCode extension's native binary (Windows).
rem Dynamically finds the latest installed version so it follows extension updates.

set "EXT="
for %%B in ("%USERPROFILE%\.vscode\extensions" "%USERPROFILE%\.vscode-insiders\extensions") do (
  if exist "%%~B" (
    for /f "delims=" %%D in ('dir /b /ad /o:n "%%~B\openai.chatgpt-*" 2^>nul') do (
      set "EXT=%%~B\%%D"
    )
    if defined EXT goto :found
  )
)

:found
if not defined EXT (
  echo Error: OpenAI ChatGPT VSCode extension not found. 1>&2
  echo Install 'ChatGPT' ^(openai.chatgpt^) from the VSCode marketplace first. 1>&2
  exit /b 1
)

set "CODEX="
for /d %%A in ("%EXT%\bin\*") do (
  if exist "%%A\codex.exe" set "CODEX=%%A\codex.exe"
)

if not defined CODEX (
  echo Error: Codex binary not found under "%EXT%\bin\" 1>&2
  exit /b 1
)

"%CODEX%" %*
