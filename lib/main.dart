import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/screens/auth/login_screen.dart';
import 'package:mobile_app/screens/auth/register_screen.dart';
import 'package:mobile_app/screens/home/home_screen.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class _SplashWrapper extends StatefulWidget {
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<_SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, authProvider, cartProvider, _) {
        if (!authProvider.isAuthenticated) {
          cartProvider.clearCart();
        }
        return authProvider.isAuthenticated ? HomeScreen() : LoginScreen();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, authProvider, cartProvider) {
            cartProvider ??= CartProvider();
            cartProvider.setAuthProvider(authProvider);
            return cartProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Магазин электроники',
        theme: ThemeData(
          primaryColor: Colors.red,
          primarySwatch: Colors.red,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            primary: Colors.red,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.red),
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            prefixIconColor: Colors.grey[700],
          ),
        ),
        home: _SplashWrapper(),
        routes: {
          '/register': (context) => RegisterScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
