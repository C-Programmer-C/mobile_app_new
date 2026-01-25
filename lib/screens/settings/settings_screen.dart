import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Настройки')),
      body: ListView(
        children: [
          _buildSectionHeader('Уведомления'),
          SwitchListTile(
            title: Text('Push-уведомления'),
            subtitle: Text('Получать уведомления о заказах и акциях'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          SwitchListTile(
            title: Text('Email-уведомления'),
            subtitle: Text('Получать уведомления на email'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          SwitchListTile(
            title: Text('SMS-уведомления'),
            subtitle: Text('Получать уведомления по SMS'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          Divider(),
          _buildSectionHeader('Приложение'),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Язык'),
            subtitle: Text('Русский'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Тема оформления'),
            subtitle: Text('Светлая'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          SwitchListTile(
            title: Text('Биометрическая авторизация'),
            subtitle: Text('Использовать отпечаток пальца или Face ID'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          Divider(),
          _buildSectionHeader('Безопасность'),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Изменить пароль'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          SwitchListTile(
            title: Text('Двухфакторная аутентификация'),
            subtitle: Text('Дополнительная защита аккаунта'),
            value: false,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          Divider(),
          _buildSectionHeader('Данные'),
          ListTile(
            leading: Icon(Icons.download),
            title: Text('Экспорт данных'),
            subtitle: Text('Скачать все ваши данные'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Удалить аккаунт', style: TextStyle(color: Colors.red)),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          Divider(),
          _buildSectionHeader('О приложении'),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Версия приложения'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Условия использования'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Политика конфиденциальности'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Функция будет доступна в будущем')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
