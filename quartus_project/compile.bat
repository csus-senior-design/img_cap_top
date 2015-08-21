@ECHO off

SETLOCAL

SET PROJECT=img_cap_top
IF EXIST C:\altera\15.0\quartus\bin64 SET PATH=%PATH%;C:\altera\15.0\quartus\bin64

FOR /F "TOKENS=1* DELIMS= " %%A IN ('DATE /T') DO SET CDATE=%%B
FOR /F "TOKENS=1,2 EOL=/ DELIMS=/ " %%A IN ('DATE /T') DO SET mm=%%B
FOR /F "TOKENS=1,2 DELIMS=/ EOL=/" %%A IN ('ECHO %CDATE%') DO SET dd=%%B
FOR /F "TOKENS=2,3 DELIMS=/ " %%A IN ('ECHO %CDATE%') DO SET yyyy=%%B
SET date=%yyyy%%mm%%dd%

FOR /F "TOKENS=1,2 DELIMS=:" %%A IN ('ECHO %time%') DO (
    SET hour=%%A
    SET min=%%B
)
SET currtime=%hour%%min%

SET timestamp=_%date%_%currtime%

quartus_sh --flow compile %PROJECT%
REN output_files\%PROJECT%.sof %PROJECT%%timestamp%.sof

ENDLOCAL