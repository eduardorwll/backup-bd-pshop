Para funcionar, criar um arquivo env.bat no seguinte formato:
```batch
@echo off

set timestamp=%DATE:~3,2%%DATE:~0,2%%DATE:~6,4%_%TIME:~0,2%%TIME:~3,2%
set timestamp=%timestamp: =0%

set databases=database_1,database_2,database_3
```