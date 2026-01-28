String userFriendlyErrorMessage(Object error) {
  final text = error.toString().toLowerCase();

  if (text.contains('unique') || text.contains('constraint')) {
    return 'Такие данные уже используются. Попробуйте другие.';
  }
  if (text.contains('database') || text.contains('sql')) {
    return 'Проблема с базой данных. Попробуйте ещё раз.';
  }
  if (text.contains('null') || text.contains('type')) {
    return 'Похоже, что заполнены не все данные. Проверьте поля и повторите.';
  }

  return 'Что-то пошло не так. Попробуйте ещё раз.';
}

