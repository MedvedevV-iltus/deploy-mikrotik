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
Скрипт выполняет 3 задачи:
* настраивает роутер на режим Home AP с дополнениями (удаляя старую конфигурацию)
* Создает туннель для ИЛТУС
* Разворачивает скрипты, контролирующих использованние трафика в пределах 2ГБ в сутки.
## Пошаговый пример запуска
### Если у роутера уже есть доступ в интернет
### Если доступа нет
