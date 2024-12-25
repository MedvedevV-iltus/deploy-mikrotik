# deploy-mikrotik
Самый простой способ запустить скрипт - это вставить написанный ниже код в Терминал Mikrotik (при условии, что на Mikrotik есть интернет)
```
{
  tool/fetch url=https://raw.githubusercontent.com/MedvedevV-iltus/deploy-mikrotik/refs/heads/main/preparation.rsc output=file dst-path=flash;  
  :import flash/preparation.rsc;  
  /system/script/run preparation;
}
```
