import 'package:chatify/resources/app_theme/theme_provider.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:chatify/widgets/long_button.dart';
import 'package:chatify/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late AuthProvider _authProvider;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeProvider provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: ChangeNotifierProvider<AuthProvider>.value(
              value: AuthProvider.instance,
              child: Align(child: _loginPageUI(provider))),
        );
      },
    );
  }

  Widget _loginPageUI(ThemeProvider provider) {
    return LayoutBuilder(
      builder: (context, cons) {
        _authProvider = Provider.of<AuthProvider>(context);
        debugPrint('Login User: ${_authProvider.user}');
        return Container(
          padding: EdgeInsets.symmetric(horizontal: cons.maxWidth * 0.05),
          alignment: Alignment.center,
          height: cons.maxHeight * 0.60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(cons),
              _inputForm(cons),
              _longButton(cons),
              _registerText()
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget(BoxConstraints cons) {
    debugPrint('Login: Heading Widget Built');
    return SizedBox(
      height: cons.maxHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            'Please Login To your Account',
            style: Theme.of(context).textTheme.headlineMedium,
          )
        ],
      ),
    );
  }

  Widget _inputForm(BoxConstraints cons) {
    return SizedBox(
      height: cons.maxHeight * 0.22,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _emailTextField(),
            const SizedBox(
              height: 15,
            ),
            _passwordTextField()
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return MyTextFormField(
      controller: _emailController,
      labelText: 'Email',
      prefixIcon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
      validator: (input) {
        input ?? '';

        return input!.isEmpty
            ? 'Please Enter a Email'
            : input.length < 3 || !input.contains('@')
                ? 'Provide a valid email'
                : null;
      },
      onSaved: (input) {
        debugPrint(_emailController.text);
      },
    );
  }

  Widget _passwordTextField() {
    return MyTextFormField(
      controller: _passwordController,
      forPassword: true,
      labelText: 'Password',
      validator: (input) {
        input ?? '';
        return input!.isEmpty
            ? 'Enter a Password with 8 or more characters'
            : input.length < 8
                ? 'Enter a Password with 8 or more characters'
                : null;
      },
      onSaved: (input) {
        debugPrint(_passwordController.text);
      },
    );
  }

  Widget _longButton(BoxConstraints cons) {
    return _authProvider.status == AuthStatus.authenticating
        ? const Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : LongButton(
            height: cons.maxHeight * 0.06,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                //Login User
                _formKey.currentState!.save();
                _authProvider.loginUserWithEmailandPassword(
                    _emailController.text, _passwordController.text);
              }
            },
            text: 'LOGIN',
          );
  }

  Widget _registerText() {
    return Row(
      children: [
        Text("Don't Have an Account? ",
            style: Theme.of(context).textTheme.displaySmall!),
        GestureDetector(
          onTap: () {
            NavigationService.navigateTo('signup');
          },
          child: Text(
            'REGISTER',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
