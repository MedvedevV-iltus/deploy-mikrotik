# deploy-mikrotik
## Быстрый запуск
1. Через WinBox подключаемся к роутеру
2. Запускаем 'New Terminal'
3. Вводим в терминале следующую команду:  
```
{ /tool/fetch url=https://raw.githubusercontent.com/MedvedevV-iltus/deploy-mikrotik/refs/heads/main/preparation.rsc output=file dst-path=flash; :import flash/preparation.rsc; /system/script/run preparation; }
```
4. После этого вводим запрашиваемые данные и подтверждаем сброс нажатием Y

## Для чего этот скрипт
Скрипт выполняет 3 задачи:
* настраивает роутер на режим Home AP с дополнениями (удаляя старую конфигурацию)
* Создает туннель для ИЛТУС
* Разворачивает скрипты, контролирующих использованние трафика в пределах 2ГБ в сутки.
## Пошаговое описание запуска (user manual)
Результатом работы скрипта является подготовленная к работе конфигурация. Поэтому во время своей работы скрипт произведёт **полный сброс текущей конфигурации**! Поэтому далее будем рассматривать пример запуска скрипта на роутере "из коробки".
 
### Если у роутера уже есть доступ в интернет
### Если доступа нет
