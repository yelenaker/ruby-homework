# CSV Detective

Це мій проєкт Ruby-гема, який визначає роздільник, лапки та кодування CSV-файлу.

## Що реалізовано
- Визначення кодування CSV (`UTF-8`, `Windows-1251`, `ISO-8859-1` тощо)
- Визначення роздільника (`comma`, `semicolon`, `tab`, `pipe`, `colon`)
- Визначення лапок (`"` або `'`)
- Базові тести всередині гема (усі проходять без помилок)
- Демонстраційний скрипт `bin/csv_detective_demo`, який показує результат роботи гема на CSV-файлі

## Приклад використання
```bash
ruby bin/csv_detective_demo example.csv


## Виведе щось на кшталт:

File: example.csv
Detected encoding : UTF-8
Detected delimiter: ","
Detected quote    : "\""


Можу додати скріншот терміналу, щоб показати, що все працює.