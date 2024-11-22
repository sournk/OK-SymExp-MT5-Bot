# OK-SymExp-MT5-Bot
The Expert Adviser for MetaTrader 5 with Symbol analysis tools

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* https://www.mql5.com/en/job/228394
* https://docs.google.com/document/d/1LMAdo3Hbs8TwVrMA_7W20x0fsfvssmbwKDGVgr08Eq0/edit?tab=t.0
* Version: 1.00

!!! warning ПРЕДУПРЕЖДЕНИЕ
    1. Торговая стратегия определена клиентом, и автор не несет за нее ответственности.
    2. Бот не гарантирует прибыль.
    3. Бот не гарантирует 100% защиты депозита.
    4. Использование бота на свой страх и риск.

![alt Layout](img/UM001.%20Layout.png)    

## Установка

1. **Обновите терминал MetaTrader 5 до последней версии:** `Help->Check For Updates->Latest Release Version`. 
    - Если советник или индикатор не запускается, то проверьте сообщения на вкладке `Journal`. Возможно вы не обновили терминал до нужной версии.
    - Иногда для тестирования советников рекомендуется обновить терминал до самой последней бета-версии: `Help->Check For Updates->Latest Beta Version`. На прошлых версиях советник может не запускаться, потому что скомпилирован на последней версии терминала. В этом случае вы увидите сообщения на вкладке `Journal` об этом.
2. **Скопируйте файл бота `*.ex5` в каталог данных** терминала `MQL5\Experts\`. Открыть каталог данных терминала `File->Open Data Folder`.
3. **Установите бесплатный индикатор `Structure Blocks`** из маркета MetaTrader 5. Введите в строку поиска "Structure Blocks" и в открывшемся окне нажмите установить. Установка из маркета возможна только после логина в телеграмме в ваш аккаунт MetaQuotes.
8. **Откройте график нужной пары**.
9. **Переместите советника из окна `Навигатор` на график**.
10. **Установите в настройках бота галочку `Allow Auto Trading`**.
11. **Включите режим автоторговли** в терминале, нажав кнопку `Algo Trading` на главной панели инструментов.

## Требования

- [x] **Определение тренда:**
    - [x] Определять направление тренда (восходящий, нисходящий или отсутствие тренда) на ТФ 1Д, 4Н, 1Н, 30М, 15М, 5М, 3М, 1М 
    - [x] Выводить информацию на визуальную панель с указанием статуса тренда для каждого таймфрейма
    - [x] Изменять цвет индикатора тренда на панели: зелёный для восходящего тренда, красный для нисходящего тренда, серый для флэта
- [x] **Описание стратегии определения тренда** и **Алгоритм анализа**
    ```
        - Восходящий тренд:
            - Для восходящего тренда последовательность должна быть:
            - Каждая последующая High выше предыдущей High.
            - Каждая последующая Low выше предыдущей Low.
            - Это сигнализирует о сильной бычьей тенденции.
        - Нисходящий тренд:
            - Для нисходящего тренда последовательность должна быть:
            - Каждая последующая High ниже предыдущей High.
            - Каждая последующая Low ниже предыдущей Low.
            - Это сигнализирует о сильной медвежьей тенденции.
        - Слом тренда:
            - Если образуется:
            - Lower High после серии Higher Highs (потенциальный слом восходящего тренда).
            - Higher Low после серии Lower Lows (потенциальный слом нисходящего тренда).
            - В таких случаях тренд переходит в состояние неопределённости или флэта.
        - Флэт (отсутствие тренда):
            - Если последовательность HH и HL или LH и LL нарушается, тренд считается неопределённым (флэт).

        - Выбор ключевых точек (High и Low):
        - На каждом таймфрейме находить экстремумы (локальные High и Low) за заданный интервал времени (например, последние 50 свечей, количество можно задать в настройках индикатора вручную).
        - Проверка последовательности экстремумов:
        - Сравнивать последовательности High и Low:
        - Если High(n) > High(n-1) и Low(n) > Low(n-1), тренд восходящий.
        - Если High(n) < High(n-1) и Low(n) < Low(n-1), тренд нисходящий.
        - В остальных случаях — флэт.
        - (рассмотрю ваш вариант определения тренда и флета)
    ```
    !!! info Как реализовано определение тренда
        Бот определяет структуру и ее BOS/CHoCH с помощью бесплатного индикатора MQL5 Market-а [Structure Blocks](https://www.mql5.com/en/market/product/115943). Он определяет структуру и тренд ==стандартными техниками Smart Money Concept==.

- [x] **Синхронизация таймфреймов**
    - [x] Для каждого таймфрейма определять тренд по алгоритму выше.
    - [x] Проверять тренды на всех таймфреймах одновременно.

    !!! info Как реализован поиск тренда на всех таймфреймах одновременно
        Бот дожидается появления новой свечи на каждом таймфреме. После чего для этого таймфрема получает актуальную структуру и тренд. Например, для M1 обновление тренда происходит ежеминутно, а для H1 - ежечасно. Поэтому для каждого таймфрейма обновления данных происходят только тогда, когда они могут измениться.

- [x] Визуальная панель
    ```
        Расположение:
        Панель по умолчанию находится в правом верхнем углу экрана
        Содержимое панели:
        Для каждого таймфрейма (1D, 4H, 1H, 15M, 5M, 3М, 1M) отображается:
        Надпись таймфрейма.
        Цветовое обозначение:
        Зелёный — восходящий тренд.
        Красный — нисходящий тренд.
        Серый — флэт.
        пример 
        1Д 4Н 1Н 30М 15М 5М 3М 1М
    ```
    !!! info Как реализована визуальная панель
        - Панель - окно со стандартным списком, в который выводятся тренды на каждом таймфрейме. Поэтому его направление может быть только сверху вниз.
        - По умолчанию панель выводится в левом верхнем углу. Вывести ее в правый угол по умолчанию нельзя, потому что в этом случае для небольших разрешений мониторов или VPS она может оказаться за пределами видимости.
        - Но ее можно перемещать по графику за заголовок. Окно запоминает свое расположение при этом.


-  [x] **Функциональные требования**
    - [x] Автоматический расчёт HH и HL (==см. *Описание стратегии определения тренда*==).
    - [x] Робот должен самостоятельно находить ключевые точки (High и Low) с использованием индикаторов ZigZag или кастомного алгоритма поиска экстремумов (==см. *Описание стратегии определения тренда*==).
    - [x] Оптимизация производительности (==см. *Синхронизация таймфреймов*==).:
        ```
        Учитывать необходимость одновременного анализа нескольких таймфреймов.
        Исключить повторные расчёты для повышения быстродействия.
        ```
    - [x] Сохранение данных:
        - [x] Логировать изменения тренда в файл для последующего анализа

    !!! info Как работают логи
        - Бот ведет стандартные логи терминала. Они доступны на закладке `Experts`. 
        - В режиме `INFO` логируется только события изменения тренда.
        - В режиме `DEBUG` логируются все запросы на получение текущего тренда каждого таймфрейма (==см. *Синхронизация таймфреймов*==).
        
- [x] **Выходные данные<**
    - [x] Графическое отображение: Панель трендов с цветовым обозначением.
    - [x] Логи работы:
    ```
    Вывод сообщений в журнал для отладки:
    "1D тренд изменился на Восходящий".
    "4H тренд изменился на Нисходящий".
    “1Н тренд изменился на Нисходящий”
    “30М тренд изменился на Нисходящий”
    “15М тренд изменился на Нисходящий”
    “5М тренд изменился на Нисходящий”
    ```
    - [x] Уведомления: При смене тренда на ключевых таймфреймах (например, 1D и 4H, 1Н) отправлять уведомление.
    
    !!! info Как реализованы уведомления
        В настройках бота можете перечислить через `;` список таймфреймов, об изменении тренда на которых бот будет уведомлять всплывающим в терминале окном или присылать сообщение на мобильный телефон, где установлен MetaTrader 5 и пользователь в нем залогинен тем же логином, что в терминале, где работает бот.

## Настройки



#### 1. ИНТЕРФЕЙС (UI)
- [x] `UI_TRD_ENB`: Показать грубину тренда
- [x] `UI_COL_FLT`: Цвет флэта
- [x] `UI_COL_UP`: Цвет бычьего тренда
- [x] `UI_COL_DWN`: Цвет медвежьего тренда

#### 2. ОПОВЕЩЕНИЯ (ALR)
- [x] `ALR_TF_PUP`: ТФ с оповещениями в терминал (';' разд.)
- [x] `ALR_TF_MOB`: ТФ с оповещениями на телефон (';' разд.)
       
#### 3. MISCELLANEOUS (MSC)
- [x] `MSC_MGC`: Expert Adviser ID - Magic
- [x] `MSC_EGP`: Expert Adviser Global Prefix
- [x] `MSC_LOG_LL`: Log Level