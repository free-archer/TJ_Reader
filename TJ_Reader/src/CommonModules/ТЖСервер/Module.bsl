#Область ПрограммныйИнтерфейс

// Прочитать журнал.
// 
// Параметры:
//  ПутьКЖурналу - Строка - Путь к папке журнала
Процедура ПрочитатьЖурнал(ПутьКЖурналу, Замер=Неопределено, Фильтры=Неопределено) Экспорт
	
	Если Фильтры = Неопределено Тогда
		Фильтры = Новый Структура;
	КонецЕсли;
		
	МассивФайлов = ФайлыЖурнала(ПутьКЖурналу);

	ТЗЖурнала = СоздатьТаблицуДляЗаписи();
		
	Для Каждого ФайлЖурнала Из МассивФайлов Цикл
		ДатаЗаписи = РазобратьФайл(ФайлЖурнала, ТЗЖурнала, Замер, Фильтры);
	КонецЦикла;
	
	НаборЗаписей = РегистрыСведений.Журнал.СоздатьНаборЗаписей();
	НаборЗаписей.Загрузить(ТЗЖурнала);
	НаборЗаписей.Записать(Истина);
	
	Если Замер <> Неопределено Тогда
		ЗамерОбъект = Замер.ПолучитьОбъект();
		ЗамерОбъект.ДатаПоследнейЗаписи = ДатаЗаписи;
		ЗамерОбъект.ПутьКЖурналу = ПутьКЖурналу;
		ЗамерОбъект.Записать();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Файлы журнала.
// 
// Параметры:
//  ПутьКЖурналу - Строка - Путь к папке журнала
// 
// Возвращаемое значение:
// Массив Из Строка - Список файлов 
Функция ФайлыЖурнала(ПутьКЖурналу) Экспорт
	МассивФайлов = НайтиФайлы(ПутьКЖурналу, "*.log", Ложь);
	
	Возврат МассивФайлов;
КонецФункции

// Разобрать файл.
// 
// Параметры:
//  ФайлЖурнала - Строка - Файл журнала
// 
// Возвращаемое значение:
//  
// Массив из Строка
Функция РазобратьФайл(ФайлЖурнала, ТЗЖурнала, Замер, Фильтры)
	ШаблонСклейкиСтрок = "\d{2}:\d{2}.\d{6}-\d";
	
	ДатаПоследнейЗаписи = Дата(1, 1, 1);		
	Если ЗначениеЗаполнено(Замер) Тогда
		ДатаПоследнейЗаписи = Замер.ДатаПоследнейЗаписи;
	КонецЕсли;	
	
	//Склеим строки
	Чтение = Новый ЧтениеТекста(ФайлЖурнала.ПолноеИмя, КодировкаТекста.UTF8, , , );
	
	МассивСтрокТЖ = Новый Массив;
	СтрокаСклейки = "";
	
	СтрокаТЖ = Чтение.ПрочитатьСтроку();
	Пока СтрокаТЖ <> Неопределено Цикл
		РезультатПоиска  = СтрНайтиПоРегулярномуВыражению(СтрокаТЖ, ШаблонСклейкиСтрок);
		
		Если РезультатПоиска.НачальнаяПозиция <> 0 Тогда
			Если Не ПустаяСтрока(СтрокаСклейки) Тогда
				МассивСтрокТЖ.Добавить(СтрокаСклейки);
			КонецЕсли;
			
			СтрокаСклейки = СтрокаТЖ;
		
		Иначе
			
			СтрокаСклейки = СтрокаСклейки + "-#-" + СтрокаТЖ;
			
		КонецЕсли;
				
		СтрокаТЖ = Чтение.ПрочитатьСтроку();
		
	КонецЦикла;
	
	//Разберем файл
	ИмяФайла = ФайлЖурнала.Имя;
	Год = Сред(ИмяФайла, 1, 2);
	Месяц = Сред(ИмяФайла, 3, 2);
	День = Сред(ИмяФайла, 5, 2);
	Час = Сред(ИмяФайла, 7, 2);
	
	МассивСтрок = Новый Массив;
	
	Для Каждого СтрокаТЖ Из МассивСтрокТЖ Цикл
		Минута = Сред(СтрокаТЖ, 1, 2);
		Секунда = Сред(СтрокаТЖ, 4, 2);
		ДолиСекунда = Сред(СтрокаТЖ, 6, 6);

		ДатаЗаписи = Дата(Год, Месяц, День, Час, Минута, Секунда);
		
		//Проверка ограничений
		Если ДатаЗаписи < ДатаПоследнейЗаписи Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ПроверитьФильтр(СтрокаТЖ, Фильтры) Тогда
			Продолжить;
		КонецЕсли;		
		
		//Новая строка
		СтруктураСтроки = СтруктураСтроки();	
		
		НоваяСтрока = ТЗЖурнала.Добавить();
		НоваяСтрока.Замер = Замер;
		
		СтруктураСтроки.ДатаЗаписи = ДатаЗаписи;
		НоваяСтрока.ДатаЗаписи = ДатаЗаписи;
		
		КлючЗаписи = ИмяФайла+Сред(СтрокаТЖ, 1, 12); 
		СтруктураСтроки.КлючЗаписи = КлючЗаписи;
		НоваяСтрока.КлючЗаписи = КлючЗаписи;
			
		//Длительность
		РезультатПоиска  = СтрНайтиПоРегулярномуВыражению(СтрокаТЖ, "-\d+");
		Если РезультатПоиска.НачальнаяПозиция <> 0 Тогда
			Длительность = Сред(РезультатПоиска.Значение, 2, РезультатПоиска.Длина-1);
			Длительность = Число(Длительность);
			ДлительностьСек = Длительность/1000000;
			ДлительностьМилиСек = Длительность/1000;
			
			СтруктураСтроки.Длительность = Длительность;
			СтруктураСтроки.ДлительностьСек = ДлительностьСек;
			СтруктураСтроки.ДлительностьМилиСек = ДлительностьМилиСек;
			
			НоваяСтрока.Длительность = Длительность;
			НоваяСтрока.ДлительностьСек = ДлительностьСек;
			НоваяСтрока.ДлительностьМилиСек = ДлительностьМилиСек;
		КонецЕсли;
		
		//Сбор свойств
		Патерны = ШаблоныПатернов();
		
		Для Каждого Патерн Из Патерны Цикл	
			Ключ = Патерн.Ключ;
			Шаблон = Патерн.Значение;
				
			Результат = "";
			ПоложениеРавно = СтрНайти(Шаблон, "=");
							
			РезультатПоиска  = СтрНайтиПоРегулярномуВыражению(СтрокаТЖ, Шаблон);
			
			Если РезультатПоиска.НачальнаяПозиция <> 0 Тогда
				Результат = РезультатПоиска.Значение;
				
				Результат = Сред(Результат, ПоложениеРавно+1, РезультатПоиска.Длина-1);
				
				УбратьКрайниеКовычки(Результат);
				
				Если СтрНайти(Результат, "-#-") > 0 Тогда
					ДобавитьПереносыСтрок(Результат);
				КонецЕсли;
			КонецЕсли;

			СтруктураСтроки[Ключ] = СокрЛП(Результат);
			НоваяСтрока[Ключ] = СокрЛП(Результат);
			
		//РезультатПоиска = RegExp(Шаблон, СтрокаТЖ, Ложь, Ложь, Истина, Истина);//Оставил для сравнения скорости работы		
		КонецЦикла;

		МассивСтрок.Добавить(СтруктураСтроки);
	КонецЦикла;
	
	Возврат ДатаЗаписи;
	
КонецФункции


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ШаблоныПатернов()
	Шаблоны = Новый Структура;
//	Шаблоны.Вставить("Sql", "Sdbl='[^']+");
//	Шаблоны.Вставить("Sql", "Sql=""[^""]+");
//	Шаблоны.Вставить("Sql", "Sql='[^']+");
//	Шаблоны.Вставить("Context", "Context='[^']+");
//	Шаблоны.Вставить("usr", "usr=[^,]+");
//	Шаблоны.Вставить("DataBase", "DataBase=[^,]+");
//	Шаблоны.Вставить("Rows", "Rows=\d+");
//	Шаблоны.Вставить("Rows", "RowsAffected=\d+");

	Шаблоны.Вставить("Sql", "Sdbl='[^']+|Sql=""[^""]+|Sql='[^']+|Sql=[^,]+");
	Шаблоны.Вставить("Context", "Context='[^']+");
	Шаблоны.Вставить("Usr", "Usr=[^,]+");
	Шаблоны.Вставить("DataBase", "DataBase=[^,]+");
	Шаблоны.Вставить("Rows", "Rows=\d+|RowsAffected=\d+");

	Возврат Шаблоны;
КонецФункции

Функция СтруктураСтроки()
	Шаблоны = ШаблоныПатернов();
	Шаблоны.Вставить("Замер", Справочники.Замеры.ПустаяСсылка());
	Шаблоны.Вставить("КлючЗаписи", "");
	Шаблоны.Вставить("ДатаЗаписи", Дата(1, 1, 1));
	Шаблоны.Вставить("Длительность", 0);
	Шаблоны.Вставить("ДлительностьСек", 0);
	Шаблоны.Вставить("ДлительностьМилиСек", 0);

	Возврат Шаблоны;
КонецФункции

Процедура УбратьКрайниеКовычки(Результат)
		Если ПустаяСтрока(Результат) Тогда
			Возврат;
		КонецЕсли;
	
		Если СтрНачинаетсяС(Результат, """") Тогда
			Результат = Прав(Результат, СтрДлина(Результат)-1);
		КонецЕсли;

		Если СтрЗаканчиваетсяНа(Результат, """") Тогда
			Результат = Лев(Результат, СтрДлина(Результат)-1);
		КонецЕсли;
		
		Если СтрНачинаетсяС(Результат, "'") Тогда
			Результат = Прав(Результат, СтрДлина(Результат)-1);
		КонецЕсли;

		Если СтрЗаканчиваетсяНа(Результат, "'") Тогда
			Результат = Лев(Результат, СтрДлина(Результат)-1);
		КонецЕсли;		
				
КонецПроцедуры				

Функция СоздатьТаблицуДляЗаписи()
	СтруктураСтроки = СтруктураСтроки();
	
	ТЗ = Новый ТаблицаЗначений;
	
	Для Каждого Колонка Из СтруктураСтроки Цикл	
			Ключ = Колонка.Ключ;
			Имя = Колонка.Значение;
			
			ТЗ.Колонки.Добавить(Ключ);
	КонецЦикла;
	
	Возврат ТЗ;
КонецФункции

Процедура ДобавитьПереносыСтрок(Результат)
	Результат = СтрЗаменить(Результат, "-#-", Символы.ПС);
КонецПроцедуры

Функция ПроверитьФильтр(СтрокаТЖ, Фильтры)
	Если Фильтры.Количество() = 0 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если Фильтры.Свойство("usr") И Не ПустаяСтрока(Фильтры.usr) Тогда
			ЕстьСтрока = СтрНайти(СтрокаТЖ, Фильтры.usr);
			Если ЕстьСтрока > 0 Тогда
				Возврат Истина;
			КонецЕсли;
	КонецЕсли;
	
	Если Фильтры.Свойство("DataBase") И Не ПустаяСтрока(Фильтры.DataBase) Тогда
			ЕстьСтрока = СтрНайти(СтрокаТЖ, Фильтры.DataBase);
			Если ЕстьСтрока > 0 Тогда
				Возврат Истина;
			КонецЕсли;
	КонецЕсли;	
	
	Если Фильтры.Свойство("ТолькоСSQL") И Фильтры.ТолькоСSQL Тогда
			ЕстьСтрока = СтрНайти(СтрокаТЖ, "Sql=");
			Если ЕстьСтрока > 0 Тогда
				Возврат Истина;
			КонецЕсли;
			ЕстьСтрока = СтрНайти(СтрокаТЖ, "Sdbl=");
			Если ЕстьСтрока > 0 Тогда
				Возврат Истина;
			КонецЕсли;
	КонецЕсли;	
	
	Возврат Ложь;			
КонецФункции	
#КонецОбласти

#Область RegExp

Функция RegExp(Шаблон, Текст, Global = Ложь, MultiLine = Ложь, IgnoreCase = Истина, ВозвращатьМассив=Ложь) Экспорт
	Перем RegExp;
	
	Если RegExp = Неопределено Тогда //Нужна инициализация
		RegExp = Новый COMОбъект("VBScript.RegExp");    // создаем объект для работы с регулярными выражениями
	КонецЕсли;
	
	//Заполняем данные
	RegExp.MultiLine = MultiLine;                  // истина — текст многострочный, ложь — одна строка
	RegExp.Global = Не Global;   // истина — поиск по всей строке, ложь — до первого совпадения
	RegExp.IgnoreCase = IgnoreCase;        // истина — игнорировать регистр строки при поиске
	RegExp.Pattern = Шаблон;                        // шаблон (регулярное выражение)
	
	РезультатАнализаСтроки = RegExp.Execute(Текст);
	
	МассивВыражений = Новый Массив;
	Для Каждого Выражение Из РезультатАнализаСтроки Цикл
		СтруктураВыражение = Новый Структура ("Начало, Длина, Значение, ПодВыражения", Выражение.FirstIndex, Выражение.Length, Выражение.Value);
		
		//Обработка подвыражений
		МассивПодВыражений = Новый Массив;
		Для Каждого ПодВыражение Из Выражение.SubMatches Цикл
			МассивПодВыражений.Добавить(ПодВыражение);
		КонецЦикла;
		СтруктураВыражение.ПодВыражения = МассивПодВыражений;
		
		МассивВыражений.Добавить(СтруктураВыражение);
	КонецЦикла; 
	
	Если МассивВыражений.Количество() > 0 Тогда
		Если ВозвращатьМассив Тогда
			Возврат МассивВыражений;
		Иначе
			Возврат МассивВыражений[0].Значение;
		КонецЕсли;
	КонецЕсли;
	
	Возврат "";
КонецФункции

#КонецОбласти
