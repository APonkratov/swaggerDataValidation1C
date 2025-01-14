
#Область ПрограммныйИнтерфейс

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
	
	ОшибкиПроверкиМоделиДанныхПоСпецификации = Новый Массив;
	
	СхемыДанныхСпецификации = СхемыДанныхСпецификации(Спецификация);
	ПроверяемаяСхема = СхемыДанныхСпецификации.Получить(ИмяСхемы);
	
	Если Не ЗначениеЗаполнено(ПроверяемаяСхема) Тогда
		ВызватьИсключение "Схема не найдена";
	КонецЕсли;
	
	ПроверитьМодельДанныхПоСхеме(МодельДанных, ПроверяемаяСхема, СхемыДанныхСпецификации,,
		ОшибкиПроверкиМоделиДанныхПоСпецификации);
		
	Возврат ОшибкиПроверкиМоделиДанныхПоСпецификации;

КонецФункции

Функция СхемыДанныхСпецификации(Знач Спецификация) Экспорт

	СхемыДанныхСпецификации = Новый Соответствие;
	
	НачалоКомпонент = СтрНайти(Спецификация, """components""");
	
	ДлинаСпецификации = СтрДлина(Спецификация);
	БлокСхемыДанных = Сред(Спецификация, НачалоКомпонент, ДлинаСпецификации);
	
	Строки = Новый Массив;
	Строки.Добавить("{");
	Строки.Добавить(БлокСхемыДанных);
	
	Спецификация = СтрСоединить(Строки, " ");

	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(Спецификация);
	СпецификацияВФорматеOpenAPI = ПрочитатьJSON(ЧтениеJSON, Истина);
	
	КомпонентыСпецификации = СпецификацияВФорматеOpenAPI.Получить("components");
	Если Не ЗначениеЗаполнено(КомпонентыСпецификации) Тогда
		ВызватьИсключение НСтр("ru='В спецификации отсутсвует блок ""components""'");
	КонецЕсли;

	СхемыДанныхСпецификации = КомпонентыСпецификации.Получить("schemas");

	Если Не ЗначениеЗаполнено(КомпонентыСпецификации) Тогда
		ВызватьИсключение НСтр("ru='В спецификации отсутсвует блок ""schemas""'");
	КонецЕсли;

	Возврат СхемыДанныхСпецификации;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПроверкиМоделей

Процедура ПроверитьМодельДанныхПоСхеме(Знач МодельДанных, Знач ПроверяемаяСхема, Знач СхемыДанных,
		Знач ПутьКСвойствам = "", Ошибки)
		
	КодОсновногоЯзыка = КодОсновногоЯзыка();
	
	ТипСхемы = ПроверяемаяСхема.Получить("type");

	Если ТипСхемы = ТипОбъектOpenAPI() Тогда
		ПроверитьМодельДанныхПоСхемеТипОбъект(МодельДанных, ПроверяемаяСхема, СхемыДанных,ПутьКСвойствам, Ошибки);
	ИначеЕсли ТипСхемы = ТипМассивOpenAPI() Тогда
		ПроверитьМодельДанныхПоСхемеТипМассив(МодельДанных, ПроверяемаяСхема, СхемыДанных,ПутьКСвойствам, Ошибки);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьМодельДанныхПоСхемеТипОбъект(Знач МодельДанных, Знач ПроверяемаяСхема, Знач СхемыДанных,
	Знач ПутьКСвойствам = "", Ошибки)
	
	КодОсновногоЯзыка = КодОсновногоЯзыка();

	Если Не ТипЗнч(МодельДанных) = Тип("Структура") Тогда
		Ошибки.Добавить(НСтр("ru='Модель данных должно быть в формате объекта'"));
		Возврат;
	КонецЕсли;

	СвойстваПоСпецификации = ПроверяемаяСхема.Получить("properties");

	Если Не ЗначениеЗаполнено(СвойстваПоСпецификации) Тогда
		Возврат;
	КонецЕсли;

	ОбязательныеСвойства = ПроверяемаяСхема.Получить("required");
	ОбязательныеСвойства = ?(ОбязательныеСвойства = Неопределено, Новый Массив, ОбязательныеСвойства);

	Для Каждого СвойствоВТерминахСпецификации Из СвойстваПоСпецификации Цикл
	
		ПараметрыСвойства = СвойствоВТерминахСпецификации.Значение;
		
		СвойствоСхемы = СвойствоСхемыВТерминах1С(СвойствоВТерминахСпецификации,
			ОбязательныеСвойства, ПутьКСвойствам, МодельДанных, СхемыДанных);
			
		СвойствоЗаполнено = ЗначениеЗаполнено(СвойствоСхемы.ЗначениеСвойства);
		
		Если СвойствоСхемы.СвойствоОбязательное Тогда
			Если Не СвойствоСхемы.СвойствоОбъявлено  Тогда 
				ПредставлениеОшибки = СтрШаблон(НСтр("ru = 'Отсутствует обязательное свойство ""%1"" (%2).'", КодОсновногоЯзыка),
					СвойствоСхемы.Путь, СвойствоСхемы.Описание);
				
				Ошибки.Добавить(ПредставлениеОшибки);
				Продолжить;
			ИначеЕсли Не СвойствоЗаполнено Тогда
				ПредставлениеОшибки = СтрШаблон(НСтр("ru = 'Не заполнено обязательное свойство ""%1"" (%2).'", КодОсновногоЯзыка),
					СвойствоСхемы.Путь, СвойствоСхемы.Описание);
				
				Ошибки.Добавить(ПредставлениеОшибки);
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		Если Не СвойствоСхемы.СвойствоОбъявлено Тогда
			Продолжить;
		КонецЕсли;
		
		Если СвойствоСхемы.Тип = Тип("Структура") Тогда
			
			ПроверитьМодельДанныхПоСхеме(СвойствоСхемы.ЗначениеСвойства, СвойствоСхемы.ВложеннаяСхема,
				СхемыДанных, СвойствоСхемы.Путь, Ошибки);
			
		ИначеЕсли СвойствоСхемы.Тип = Тип("Массив") Тогда
			
			ПроверитьТипМассивСвойстваМоделиДанных(СвойствоСхемы, ПараметрыСвойства, СхемыДанных, Ошибки);
			
		Иначе
			ПроверитьТипЗначенияСвойстваМоделиДанных(СвойствоСхемы, Ошибки);
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

Процедура ПроверитьМодельДанныхПоСхемеТипМассив(Знач МодельДанных, Знач ПроверяемаяСхема, Знач СхемыДанных,
	Знач ПутьКСвойствам = "", Ошибки)
	
	КодОсновногоЯзыка = КодОсновногоЯзыка();

	Если Не ТипЗнч(МодельДанных) = Тип("Массив") Тогда
		Ошибки.Добавить(НСтр("ru='Модель данных должно быть в формате массива'"));
		Возврат;
	КонецЕсли;

	ВложеннаяСхема = ПроверяемаяСхема.Получить("items");
	
	Для Каждого ОбъектДанных Из МодельДанных Цикл
		ПроверитьМодельДанныхПоСхеме(ОбъектДанных, ВложеннаяСхема, СхемыДанных, ПутьКСвойствам, Ошибки);
	КонецЦикла;

КонецПроцедуры

#Область ПроверкиЗначенийСвойств

Процедура ПроверитьТипЗначенияСвойстваМоделиДанных(Знач СвойствоСхемы,Ошибки)
	
	ЭтоКорректныйТип = Истина;
	
	КодОсновногоЯзыка = КодОсновногоЯзыка();
	
	ЗначениеСвойства = СвойствоСхемы.ЗначениеСвойства;
	Путь             = СвойствоСхемы.Путь;
	
	ПриведенноеЗначениеСвойства = СвойствоСхемы.Тип.ПривестиЗначение(ЗначениеСвойства);
	
	Если ПриведенноеЗначениеСвойства <> ЗначениеСвойства Тогда
		
		РазличаютсяКвалификаторы = ТипЗнч(ПриведенноеЗначениеСвойства) = ТипЗнч(ЗначениеСвойства);
		
		Если РазличаютсяКвалификаторы Тогда
			
			ПредставлениеОшибки = СтрШаблон(НСтр("ru = 'Некорректный тип свойства ""%1"" (%2). См. спецификацию.'",
				КодОсновногоЯзыка), Путь, СвойствоСхемы.Описание);
			
		Иначе
			
			ТипПриведенногоЗначения = ТипЗнч(ЗначениеСвойства);
			ОжидаемыйТип = ТипЗнч(ПриведенноеЗначениеСвойства); 
			
			ПредставлениеОшибки = СтрШаблон(НСтр("ru = 'Некорректный тип свойства ""%1"" (%2). Ожидается тип ""%3"", передан тип ""%4"".'",
				КодОсновногоЯзыка), Путь, СвойствоСхемы.Описание,
				?(СвойствоСхемы.Тип.СодержитТип(Тип("Структура")), НСтр("ru = 'Объект'"), ОжидаемыйТип),
				?(ТипПриведенногоЗначения = Тип("Структура"), НСтр("ru = 'Объект'"), ТипПриведенногоЗначения));
			
		КонецЕсли;
		
		Ошибки.Добавить(ПредставлениеОшибки);
		
		ЭтоКорректныйТип = Ложь;
		
	КонецЕсли;
	
	ЭтоПеречисление = ЗначениеЗаполнено(СвойствоСхемы.ДопустимыеЗначения);
	
	Если ЭтоКорректныйТип И ЭтоПеречисление Тогда
		
		ЭтоКорректноеЗначениеПеречисления = СвойствоСхемы.ДопустимыеЗначения.Найти(ЗначениеСвойства) <> Неопределено;
		
		Если Не ЭтоКорректноеЗначениеПеречисления Тогда
				
			ПредставлениеДопустимыхЗначений = СтрСоединить(СвойствоСхемы.ДопустимыеЗначения, ", ");
			
			ПредставлениеОшибки = СтрШаблон(НСтр("ru = 'Некорректное значение свойства ""%1"" (%2). Возможные значения: %3.'",
				КодОсновногоЯзыка), Путь, СвойствоСхемы.Описание, ПредставлениеДопустимыхЗначений);
			
			Ошибки.Добавить(ПредставлениеОшибки);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьТипМассивСвойстваМоделиДанных(Знач СвойствоСхемы, Знач ПараметрыСвойства, Знач СхемыДанных, Ошибки)
	
	ВложеннаяСхема = ПараметрыСвойства.Получить("items");
	
	СсылкаНаСхему = ВложеннаяСхема.Получить("$ref");
	
	Если ЗначениеЗаполнено(СсылкаНаСхему) Тогда
		ВложеннаяСхема = ВложеннаяСхемаПоСсылке(СсылкаНаСхему, СхемыДанных);
	КонецЕсли;

	ТипВложеннойСхемы = ВложеннаяСхема.Получить("type");
	Если ТипВложеннойСхемы = ТипОбъектOpenAPI() Тогда
		
		ИндексЭлемента = 0;
		
		Для Каждого ЭлементМассива Из СвойствоСхемы.ЗначениеСвойства Цикл
			
			ПроверитьМодельДанныхПоСхеме(ЭлементМассива, ВложеннаяСхема, СхемыДанных,
				СтрШаблон("%1[%2]", СвойствоСхемы.Путь, ИндексЭлемента), Ошибки);
			
			ИндексЭлемента = ИндексЭлемента + 1;
			
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СвойствоСхемы

Функция СвойствоСхемыВТерминах1С(Знач СвойствоВТерминахСпецификации, Знач ОбязательныеСвойства,
		Знач ПутьКСвойствам, Знач МодельДанных, Знач СхемыДанных)
	
	СвойствоСхемыВТерминах1С = Новый Структура;
	
	ИмяСвойства       = СвойствоВТерминахСпецификации.Ключ;
	
	СсылкаНаСхему = СвойствоВТерминахСпецификации.Значение.Получить("$ref");
	
	Если ЗначениеЗаполнено(СсылкаНаСхему) Тогда
		ПараметрыСвойства = ВложеннаяСхемаПоСсылке(СсылкаНаСхему, СхемыДанных);
	Иначе
		ПараметрыСвойства = СвойствоВТерминахСпецификации.Значение;
	КонецЕсли;
	
	Тип               = ТипСвойстваСхемыДанных(ПараметрыСвойства);
	
	СвойствоОбъявлено    = МодельДанных.Свойство(ИмяСвойства);
	СвойствоОбязательное = Не ОбязательныеСвойства.Найти(ИмяСвойства) = Неопределено;
	Описание             = ПараметрыСвойства.Получить("description");
	ДопустимыеЗначения   = ПараметрыСвойства.Получить("enum");
	
	Если ЗначениеЗаполнено(ПутьКСвойствам) Тогда
		ПолныйПутьКСвойству = СтрШаблон("%1.%2", ПутьКСвойствам, ИмяСвойства);
	Иначе
		ПолныйПутьКСвойству = ИмяСвойства;
	КонецЕсли;
	
	СвойствоСхемыВТерминах1С.Вставить("Имя",      ИмяСвойства);
	СвойствоСхемыВТерминах1С.Вставить("Тип",      Тип);
	СвойствоСхемыВТерминах1С.Вставить("Описание", Описание);
	СвойствоСхемыВТерминах1С.Вставить("Путь",     ПолныйПутьКСвойству);
	СвойствоСхемыВТерминах1С.Вставить("ВложеннаяСхема",       ПараметрыСвойства);
	СвойствоСхемыВТерминах1С.Вставить("ДопустимыеЗначения",   ДопустимыеЗначения);
	СвойствоСхемыВТерминах1С.Вставить("СвойствоОбъявлено",    СвойствоОбъявлено);
	СвойствоСхемыВТерминах1С.Вставить("СвойствоОбязательное", СвойствоОбязательное);
	СвойствоСхемыВТерминах1С.Вставить("ЗначениеСвойства",     СвойствоСтруктуры(МодельДанных, ИмяСвойства));
	
	Возврат СвойствоСхемыВТерминах1С;
	
КонецФункции

Функция ТипСвойстваСхемыДанных(Знач Свойство)
	
	ТипСвойстваСхемыДанных = Неопределено;
	
	ТипИзСпецификации = Свойство.Получить("type");

	Если ТипИзСпецификации = ТипОбъектOpenAPI() Тогда
		ТипСвойстваСхемыДанных = Тип("Структура");
	ИначеЕсли ТипИзСпецификации = ТипМассивOpenAPI() Тогда
		ТипСвойстваСхемыДанных = Тип("Массив");
	ИначеЕсли ТипИзСпецификации = ТипСтрокаOpenAPI() Тогда
		ТипСвойстваСхемыДанных = Новый ОписаниеТипов("Строка");
	ИначеЕсли ТипИзСпецификации = ТипЧислоOpenAPI() Тогда
		ТипСвойстваСхемыДанных = Новый ОписаниеТипов("Число");
	ИначеЕсли ТипИзСпецификации = ТипБулевоOpenAPI() Тогда
		ТипСвойстваСхемыДанных = Новый ОписаниеТипов("Булево");
	КонецЕсли;
	
	Возврат ТипСвойстваСхемыДанных;
	
КонецФункции

Функция ВложеннаяСхемаПоСсылке(Знач Ссылка, Знач СхемыДанных)

	ВложеннаяСхемаПоСсылке = Неопределено;

	ИмяСхемы = СтрЗаменить(Ссылка, "#/components/schemas/","");
	ВложеннаяСхемаПоСсылке = СхемыДанных.Получить(ИмяСхемы);

	Возврат ВложеннаяСхемаПоСсылке;

КонецФункции

#КонецОбласти

#Область ТипыOpenAPI

Функция ТипОбъектOpenAPI()
	
	Возврат "object";
	
КонецФункции

Функция ТипМассивOpenAPI()
	
	Возврат "array";
	
КонецФункции

Функция ТипСтрокаOpenAPI()
	
	Возврат "string";
	
КонецФункции

Функция ТипЧислоOpenAPI()
	
	Возврат "integer";
	
КонецФункции

Функция ТипБулевоOpenAPI()
	
	Возврат "boolean";
	
КонецФункции

#КонецОбласти

#Область ОписаниеТипов

// Создает объект ОписаниеТипов, содержащий тип Строка.
//
// Параметры:
//  ДлинаСтроки - Число - длина строки.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Строка.
//
Функция ОписаниеТипаСтрока(ДлинаСтроки) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Строка"));

	КвалификаторСтроки = Новый КвалификаторыСтроки(ДлинаСтроки, ДопустимаяДлина.Переменная);

	Возврат Новый ОписаниеТипов(Массив, , КвалификаторСтроки);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Число.
//
// Параметры:
//  Разрядность - Число - общее количество разрядов числа (количество разрядов
//                        целой части плюс количество разрядов дробной части).
//  РазрядностьДробнойЧасти - Число - число разрядов дробной части.
//  ЗнакЧисла - ДопустимыйЗнак - допустимый знак числа.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Число.
Функция ОписаниеТипаЧисло(Разрядность, РазрядностьДробнойЧасти = 0, ЗнакЧисла = Неопределено) Экспорт

	Если ЗнакЧисла = Неопределено Тогда
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти);
	Иначе
		КвалификаторЧисла = Новый КвалификаторыЧисла(Разрядность, РазрядностьДробнойЧасти, ЗнакЧисла);
	КонецЕсли;

	Возврат Новый ОписаниеТипов("Число", КвалификаторЧисла);

КонецФункции

// Создает объект ОписаниеТипов, содержащий тип Дата.
//
// Параметры:
//  ЧастиДаты - ЧастиДаты - набор вариантов использования значений типа Дата.
//
// Возвращаемое значение:
//  ОписаниеТипов - описание типа Дата.
Функция ОписаниеТипаДата(ЧастиДаты) Экспорт

	Массив = Новый Массив;
	Массив.Добавить(Тип("Дата"));

	КвалификаторДаты = Новый КвалификаторыДаты(ЧастиДаты);

	Возврат Новый ОписаниеТипов(Массив, , , КвалификаторДаты);

КонецФункции

#КонецОбласти

#Область ОбщегоНазначения

Функция КодОсновногоЯзыка() Экспорт
	
	Возврат "ru";
	
КонецФункции

// Возвращает значение свойства структуры.
//
// Параметры:
//   Структура - Структура, ФиксированнаяСтруктура - Объект, из которого необходимо прочитать значение ключа.
//   Ключ - Строка - Имя свойства структуры, для которого необходимо прочитать значение.
//   ЗначениеПоУмолчанию - Произвольный - Необязательный. Возвращается когда в структуре нет значения по указанному
//                                        ключу.
//       Для скорости рекомендуется передавать только быстро вычисляемые значения (например примитивные типы),
//       а инициализацию более тяжелых значений выполнять после проверки полученного значения (только если это
//       требуется).
//
// Возвращаемое значение:
//   Произвольный - Значение свойства структуры. ЗначениеПоУмолчанию если в структуре нет указанного свойства.
//
Функция СвойствоСтруктуры(Структура, Ключ, ЗначениеПоУмолчанию = Неопределено) Экспорт
	
	Если Структура = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат = ЗначениеПоУмолчанию;
	Если Структура.Свойство(Ключ, Результат) Тогда
		Возврат Результат;
	Иначе
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#КонецОбласти