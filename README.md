# Проверка модели данных по спецификации Swagger

## Ссылки

[Описание формата](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.0.md)

[Swagger](https://swagger.io/)

## Назначение в жизни

Задача:

* Реализовать http сервис
* Отдать реализованный сервис кому то
* Сделать так, чтобы сервис возвращал понятные ошибки по структуре данных и не тратить время на разбор того, что же не так делает вызываемая сторона.

Дано:

* Swagger спецификация (Если нет, то пишется)

### Решение

В модуле сервиса, при получениие данных, выполнить проверку используя метод:

```bsl
// Возвращает список ошибок модели данных.
//
// Параметры:
//  МодельДанных - Структура - Проверяемый объект.
//               - Массив   - Проверяемый объект.
//  ИмяСхемы     - Строка - Имя схемы данных из спецификации.
//  Спецификация - Строка - Спецификация OpenAPI 3.0.0 в формате JSON.
// 
// Возвращаемое значение:
//  Массив - Список ошибок.
//
Функция ОшибкиПроверкиМоделиДанныхПоСпецификации(Знач МодельДанных, Знач ИмяСхемы, Знач Спецификация) Экспорт
```

Вернуть ответом полученные ошибки и все.

Примеры возвращаемых ошибок:

```bsl
"Отсутствует обязательное свойство "date" (Дата и время записи на стороне банка в формате ISO 8601:2004 вида YYYY-MM-DDThh:mm:ss.)."

"Некорректный тип свойства "passport.number" (Номер). Ожидается тип "Строка", передан тип "Число"."

"Отсутствует обязательное свойство "passport.dateOfIssue" (Дата выдачи в формате ISO 8601:2004 вида YYYY-MM-DD.)."

"Некорректный тип свойства "dateOfBirth" (Дата рождения физического лица в формате ISO 8601:2004 вида YYYY-MM-DD.). Ожидается тип "Строка", передан тип "Не определено"."

"Отсутствует обязательное свойство "name" (Имя физического лица.)."

"Некорректный тип свойства "patronymic" (Отчество физического лица.). Ожидается тип "Строка", передан тип "Не определено"."
```

## Ограничения

* Версия спецификации должна быть 3.0.0
* Спецификация передается в формате JSON
