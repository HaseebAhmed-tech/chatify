import 'dart:io';

import 'package:chatify/providers/auth_provider.dart';
import 'package:chatify/services/cloud_Storage_Service.dart';
import 'package:chatify/services/media_service.dart';
import 'package:chatify/services/navigation_service.dart';
import 'package:chatify/widgets/long_button.dart';
import 'package:chatify/widgets/textformfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../resources/app_theme/theme_provider.dart';
import '../../services/database_service.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;
  final ValueNotifier<File?> _image = ValueNotifier<File?>(null);
  late AuthProvider _authProvider;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ThemeProvider provider, child) {
        return WillPopScope(
          onWillPop: () {
            NavigationService.goBack();
            return Future.value(false);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: ChangeNotifierProvider<AuthProvider>.value(
              value: AuthProvider.instance,
              child: Align(
                child: _sinupPageUI(),
              ),
            ),
          ),
        );
      },
    );
  }

  _sinupPageUI() {
    return LayoutBuilder(builder: (context, cons) {
      _authProvider = Provider.of<AuthProvider>(context);
      debugPrint('Signup User: ${_authProvider.user}');
      return Container(
        padding: EdgeInsets.symmetric(horizontal: cons.maxWidth * 0.05),
        height: cons.maxHeight * 0.95,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingWidget(cons),
              _inputForm(cons),
              _bottomWidget(cons),
            ],
          ),
        ),
      );
    });
  }

  _headingWidget(BoxConstraints cons) {
    return Builder(builder: (context) {
      return SizedBox(
        height: cons.maxHeight * 0.12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's Get Going",
                style: Theme.of(context).textTheme.headlineLarge!),
            Text(
              'Please Enter your Details',
              style: Theme.of(context).textTheme.headlineMedium,
            )
          ],
        ),
      );
    });
  }

  _inputForm(BoxConstraints cons) {
    return SizedBox(
      height: cons.maxHeight * 0.72,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSelector(cons),
            _usernameTextField(),
            _emailTextField(),
            _passwordTextField(),
            _confirmPasswordTextField(),
          ],
        ),
      ),
    );
  }

  _emailTextField() {
    return MyTextFormField(
      controller: _emailController,
      labelText: 'Email',
      validator: (input) {
        input ?? '';

        return input!.isEmpty
            ? 'Please Enter an Email'
            : input.length < 3 || !input.contains('@')
                ? 'Provide a valid email'
                : null;
      },
      prefixIcon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
    );
  }

  _usernameTextField() {
    debugPrint('Signup: Username Text Field built');
    return MyTextFormField(
      controller: _usernameController,
      labelText: 'Username',
      validator: (input) {
        input ?? '';

        return input!.isEmpty
            ? 'Please Enter a Username'
            : input.length < 3
                ? 'Username should be more than 3 characters'
                : null;
      },
      prefixIcon: const Icon(Icons.person),
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

  _confirmPasswordTextField() {
    return MyTextFormField(
      controller: _confirmPasswordController,
      forPassword: true,
      labelText: 'Confirm Password',
      validator: (input) {
        input ?? '';
        return input!.isEmpty
            ? 'Kindly Confirm your Password'
            : input != _passwordController.text
                ? 'Password does not match'
                : null;
      },
      onSaved: (input) {
        debugPrint(_passwordController.text);
      },
    );
  }

  _bottomWidget(BoxConstraints cons) {
    debugPrint('Signup: Bottom Widget built');
    return LongButton(
      height: cons.maxHeight * 0.06,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // if (_image.value == null) {
          //   SnackBarService.instance
          //       .showSnackBar('Error', 'Please Select an Image');
          //   return;
          // }
          _authProvider.registerUserWithEmailandPassword(
            _emailController.text,
            _passwordController.text,
            _usernameController.text,
            (String uid) async {
              debugPrint('Signup: User Created in DB');

              UploadTask? task = _image.value != null
                  ? await CloudStorageService.instance
                      .uploadUserImage(uid, _image.value!)
                  : await CloudStorageService.instance.uploadDefaultUserImage(
                      uid,
                      'https://images.pexels.com/photos/19583366/pexels-photo-19583366/free-photo-of-parrot-with-red-feathers.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1');
              final imageUrl = await task?.snapshot.ref.getDownloadURL() ??
                  'https://images.pexels.com/photos/19583366/pexels-photo-19583366/free-photo-of-parrot-with-red-feathers.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
              if (task != null) {
                debugPrint('Signup: Image Uploaded');
                await DatabaseService.instance.createUserInDB(uid,
                    _usernameController.text, _emailController.text, imageUrl);
                debugPrint('Signup: User Created in DB');
              } else {
                debugPrint('Signup: Image Upload Failed');
              }
            },
          );
          debugPrint('Signup:Validated');
          _formKey.currentState!.save();
        } else {
          debugPrint('Signup: Not Validated');
        }
      },
      text: 'Signup',
    );
  }

  _imageSelector(BoxConstraints cons) {
    return ValueListenableBuilder(
      valueListenable: _image,
      builder: (context, value, child) {
        return Align(
          child: GestureDetector(
            onTap: () async {
              debugPrint('Image Selector');
              File? imageFile =
                  await MediaService.instance.getImageFromLibrary();
              _image.value = imageFile;
              debugPrint(' Signup: ${imageFile.toString()}');
            },
            child: Stack(
              children: [
                Container(
                  height: cons.maxHeight * 0.14,
                  width: cons.maxHeight * 0.14,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _image.value != null
                              ? Image.file(_image.value!).image
                              : const NetworkImage(
                                  'https://images.pexels.com/photos/19583366/pexels-photo-19583366/free-photo-of-parrot-with-red-feathers.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                          fit: BoxFit.cover)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: cons.maxHeight * 0.04,
                    width: cons.maxHeight * 0.04,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
