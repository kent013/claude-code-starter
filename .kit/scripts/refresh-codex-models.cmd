@echo off
setlocal

rem refresh-codex-models: Ask Codex itself for its currently available model list,
rem then cache the answer to .kit\cache\codex-models.md.

set "SCRIPT_DIR=%~dp0"
set "KIT_DIR=%SCRIPT_DIR%.."
set "CACHE_DIR=%KIT_DIR%\cache"
set "CACHE_FILE=%CACHE_DIR%\codex-models.md"
set "CODEX=%SCRIPT_DIR%codex.cmd"
set "BOOTSTRAP_MODEL=gpt-5"

if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

set "TMP_PROMPT=%TEMP%\codex-models-prompt-%RANDOM%.txt"
set "TMP_OUT=%TEMP%\codex-models-out-%RANDOM%.txt"

> "%TMP_PROMPT%" echo あなたが呼び出せる全モデル名を箇条書きで列挙してください。説明は一切不要、モデル名のみを出力してください。

"%CODEX%" exec --skip-git-repo-check --ephemeral --sandbox read-only -m "%BOOTSTRAP_MODEL%" -c "model_reasoning_effort=""low""" -o "%TMP_OUT%" - < "%TMP_PROMPT%" >nul 2>&1
if errorlevel 1 (
  echo Error: codex exec failed. Is codex authenticated? Try: codex login 1>&2
  del "%TMP_PROMPT%" 2>nul
  exit /b 1
)

if not exist "%TMP_OUT%" (
  echo Error: codex returned no output. 1>&2
  del "%TMP_PROMPT%" 2>nul
  exit /b 1
)

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-ddTHH:mm:ssZ"') do set "NOW=%%I"

> "%CACHE_FILE%" echo # Codex 利用可能モデル一覧
>> "%CACHE_FILE%" echo.
>> "%CACHE_FILE%" echo 取得日時: %NOW%
>> "%CACHE_FILE%" echo 取得元モデル: %BOOTSTRAP_MODEL%
>> "%CACHE_FILE%" echo.
>> "%CACHE_FILE%" echo ## モデル
>> "%CACHE_FILE%" echo.
type "%TMP_OUT%" >> "%CACHE_FILE%"

del "%TMP_PROMPT%" 2>nul
del "%TMP_OUT%" 2>nul

echo Updated: %CACHE_FILE%
