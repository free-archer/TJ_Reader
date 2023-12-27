#Область ПрограммныйИнтерфейс

Процедура ОбработатьЗаписи(Замер) Экспорт
	НаборЗаписей = РегистрыСведений.Журнал.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Замер.Установить(Замер);
	НаборЗаписей.Прочитать();

	Для Каждого Запись Из НаборЗаписей Цикл
		Запись.Запрос1С =  РазобратьТекстЗапроса(Запись.Замер, Запись.Sql);
	КонецЦикла;
	
	НаборЗаписей.Записать(Истина);
КонецПроцедуры	

Функция РазобратьТекстЗапроса(Замер, Знач ТекстЗапроса) Экспорт
	Если Не ЗначениеЗаполнено(Замер) Тогда
		Сообщить("Не задан Замер");
		
		Возврат "";
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Замер.База) Тогда
		Сообщить("Не задана База");
		
		Возврат "";
	КонецЕсли;	
	
	ТаблицаСоответствия= Новый ТаблицаЗначений();
	ТаблицаСоответствия.Колонки.Добавить("ТаблицаSQL");
	ТаблицаСоответствия.Колонки.Добавить("Таблица1С");
	ТаблицаСоответствия.Колонки.Добавить("ПсевдонимSQL");	
	
	//Ищем таблицы в тексте
	ШаблоныТаблиц = ШаблоныПоискаТаблиц();
	Для Каждого Шаблон Из ШаблоныТаблиц Цикл

		РезультатПоиска  = СтрНайтиПоРегулярномуВыражению(ТекстЗапроса, Шаблон.Патерн);
		Если РезультатПоиска.НачальнаяПозиция <> 0 Тогда
			СтрокаТаблицыSQL = СокрЛП(Сред(РезультатПоиска.Значение, Шаблон.Длина, РезультатПоиска.Длина - 1));
			
			Имена = СтрРазделить(СтрокаТаблицыSQL, " ");
			
			Если Имена.Количество() = 2 Тогда
				ТаблицаSQL = Имена[0];
				ПсевдонимSQL = Имена[1];
			Иначе
				ТаблицаSQL = СтрокаТаблицыSQL;
				ПсевдонимSQL = "";
			КонецЕсли;
			
			Таблица1СИмя = "";
			Таблица1С= Справочники.Методанные1С.НайтиПоРеквизиту("ИмяТаблицыХранения", ТаблицаSQL, , Замер.База);
		
			НоваяСтрока = ТаблицаСоответствия.Добавить();
			НоваяСтрока.ТаблицаSQL = ТаблицаSQL;
			НоваяСтрока.Таблица1С = Таблица1С;
			НоваяСтрока.ПсевдонимSQL = ПсевдонимSQL;
		КонецЕсли;

	КонецЦикла;
	
	//Заменяем таблицы
	Для Каждого СоответствиеТаблиц Из ТаблицаСоответствия Цикл
		ТаблицаSQL = СоответствиеТаблиц.ТаблицаSQL;
		Таблица1С = СоответствиеТаблиц.Таблица1С;
		ПсевдонимSQL = СоответствиеТаблиц.ПсевдонимSQL;
		
		//Имена таблиц
		ТекстЗапроса= СтрЗаменить(ТекстЗапроса, ТаблицаSQL, Таблица1С.Метаданные);
		//Имена полей
		ЗаменитьПоляSQL(ТекстЗапроса, ТаблицаСоответствия);
		//Имена псевдонимов
		ТекстЗапроса= СтрЗаменить(ТекстЗапроса, ПсевдонимSQL, "КАК "+ Таблица1С.Наименование);
	КонецЦикла;
	
	
	
	Возврат ТекстЗапроса;
КонецФункции


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ШаблоныПоискаТаблиц()
	Шаблоны = Новый Массив();
	Шаблоны.Добавить(Новый Структура("Патерн,Длина","FROM \w+ T\d", 5));
	Шаблоны.Добавить(Новый Структура("Патерн,Длина","JOIN \w+ T\d", 5));
	
	Возврат Шаблоны;
КонецФункции

Процедура ЗаменитьПоляSQL(Текст1С, ТаблицаСоответствия)
	Для Каждого стрСоответствия ИЗ ТаблицаСоответствия Цикл
		Таблица1С= стрСоответствия.Таблица1С;
		ПсевдонимSQL= стрСоответствия.ПсевдонимSQL;

		Выборка= Справочники.Поля.Выбрать(, Таблица1С);
		Пока Выборка.Следующий() Цикл                          
			Если Не ПустаяСтрока(Выборка.Наименование) Тогда
				Текст1С= СтрЗаменить(Текст1С, ПсевдонимSQL+"."+Выборка.ИмяХранения, Таблица1С.Наименование+"."+Выборка.Наименование);
			КонецЕсли;
		КонецЦикла; 
	КонецЦикла;
КонецПроцедуры

#КонецОбласти
