# deploy-mikrotik
## Быстрый запуск
```
{
  tool/fetch url=https://raw.githubusercontent.com/MedvedevV-iltus/deploy-mikrotik/refs/heads/main/preparation.rsc output=file dst-path=flash;  
  :import flash/preparation.rsc;  
  /system/script/run preparation;
}
```
## Для чего этот скрипт
## Пошаговый пример запуска
### Если у роутера уже есть доступ в интернет
### Если доступа нет
