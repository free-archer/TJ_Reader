#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПутьКЖурналуНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)
	 СтандартнаяОбработка = ЛОЖЬ;
    
    Режим = РежимДиалогаВыбораФайла.ВыборКаталога; 
    ДиалогОткрытия = Новый ДиалогВыбораФайла(Режим); 
    ДиалогОткрытия.Каталог = "";  
    ДиалогОткрытия.Заголовок = "Выберите каталог записи журнала"; 
        
    Параметр = "";
    Оповещение = Новый ОписаниеОповещения("ВыборКаталогаЗавершение", ЭтотОбъект, Параметр );
    ДиалогОткрытия.Показать(Оповещение);
КонецПроцедуры

&НаКлиенте
Процедура ВыборКаталогаЗавершение(Результат, Параметр) Экспорт
    
    Если Результат = Неопределено Тогда
         Сообщить("Каталог не выбран");
         Возврат;
    КонецЕсли;
    
    ПутьКЖурналу = Результат[0];
    
КонецПроцедуры

&НаКлиенте
Процедура ЗамерПриИзменении(Элемент)
	ОбновитьНаКлиента();
КонецПроцедуры

&НаКлиенте
Процедура ДатаНачалаПриИзменении(Элемент)
	ОбновитьНаКлиента();
КонецПроцедуры

&НаКлиенте
Процедура ДатаОкончанияПриИзменении(Элемент)
	ОбновитьНаКлиента();
КонецПроцедуры

&НаКлиенте
Процедура СТекстомЗапросаПриИзменении(Элемент)
	ОбновитьНаКлиента();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура НовыйЗамер(Команда)
	Оповещение = Новый ОписаниеОповещения("ВводСтрокиЗавершение", ЭтотОбъект);
	ПоказатьВводСтроки(Оповещение, "", "Имя замера", 20, Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ВводСтрокиЗавершение(Результат, ДопПараметры) Экспорт
	Если Не ПустаяСтрока(Результат) Тогда
		Замер = СоздатьЗамер(Результат);
		
		ОбновитьНаКлиента();
	КонецЕсли; 
КонецПроцедуры
	
&НаКлиенте
Процедура Очистить(Команда)
	ОчиститьЖурнал(Замер);
	
	ОбновитьНаКлиента();
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьТЖ(Команда)
	ПрочитатьТЖНаСервере();
	
	ОбновитьНаКлиента();
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьНаКлиента();
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбновитьНаКлиента()
	УстановитьОтбор();
	
	Элементы.Список.Обновить();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтбор()
	
	Список.Отбор.Элементы.Очистить();
	
	Если ЗначениеЗаполнено(Замер) Тогда
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Замер");
		ЭлементОтбора.ПравоеЗначение = Замер;
		ЭлементОтбора.Использование = Истина;		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДатаНачала) Тогда
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.БольшеИлиРавно;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДатаЗаписи");
		ЭлементОтбора.ПравоеЗначение = ДатаНачала;
		ЭлементОтбора.Использование = Истина;		
	КонецЕсли;
		
	Если ЗначениеЗаполнено(ДатаОкончания) Тогда
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.МеньшеИлиРавно;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ДатаЗаписи");
		ЭлементОтбора.ПравоеЗначение = ДатаОкончания;
		ЭлементОтбора.Использование = Истина;		
	КонецЕсли;
			
	Если СТекстомЗапроса Тогда
		ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
		ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Sql");
		ЭлементОтбора.Использование = Истина;		
	КонецЕсли;	
			
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоздатьЗамер(Наименование)
		НовыйЗамер = Справочники.Замеры.СоздатьЭлемент();
		НовыйЗамер.Наименование = Наименование;
		НовыйЗамер.Записать();
		
		Возврат НовыйЗамер.Ссылка;
КонецФункции

&НаСервереБезКонтекста
Процедура ОчиститьЖурнал(Замер)
	НаборЗаписей = РегистрыСведений.Журнал.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Замер.Установить(Замер);
	НаборЗаписей.Прочитать();
	НаборЗаписей.Очистить();
	НаборЗаписей.Записать();	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьТЖНаСервере()
	Если Очищать Тогда
		ОчиститьЖурнал(Замер);
	КонецЕсли;
	
	Если Не ПустаяСтрока(usr) Или Не ПустаяСтрока(DataBase) Или ТолькоСSQL Тогда
		Фильтры = Новый Структура;
		Фильтры.Вставить("Usr", usr);
		Фильтры.Вставить("DataBase", DataBase);
		Фильтры.Вставить("ТолькоСSQL", ТолькоСSQL);
	КонецЕсли;
	
	ТЖСервер.ПрочитатьЖурнал(ПутьКЖурналу, Замер, Фильтры);
КонецПроцедуры

#КонецОбласти
