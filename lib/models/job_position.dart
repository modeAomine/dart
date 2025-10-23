enum JobPosition {
  driver('Водитель мусоровоза', 'Управление спецтехникой, вывоз ТКО'),
  worker('Рабочий по вывозу ТКО', 'Погрузка/разгрузка мусора, работа на объектах'),
  dispatcher('Диспетчер', 'Координация заказов, работа с клиентами');

  const JobPosition(this.title, this.description);
  final String title;
  final String description;
}