import 'package:flutter/material.dart';

import '../resources/constants/styles.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;

  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final bool forPassword;
  final String? labelText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final bool showOutlineBorder;
  final void Function(String)? onFieldSubmitted;
  const MyTextFormField(
      {super.key,
      this.controller,
      this.maxLines = 1,
      this.validator,
      this.onSaved,
      this.prefixIcon,
      this.forPassword = false,
      this.suffixIcon,
      this.labelText,
      this.keyboardType = TextInputType.text,
      this.onChanged,
      this.showOutlineBorder = true,
      this.onFieldSubmitted});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> obscureText = ValueNotifier<bool>(true);
    return ValueListenableBuilder(
      valueListenable: obscureText,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          enabled: true,

          autofocus: false,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: forPassword ? obscureText.value : false,
          maxLines: forPassword ? 1 : maxLines,
          enableSuggestions: forPassword ? false : true,
          style: Styles.displayMedNormalStyle,
          decoration: InputDecoration(
              fillColor: Styles.scaffoldBackgroundColor,
              filled: true,
              prefixIcon: forPassword ? const Icon(Icons.lock) : prefixIcon,
              suffixIcon: forPassword
                  ? IconButton(
                      onPressed: () {
                        obscureText.value = !obscureText.value;
                      },
                      icon: obscureText.value
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    )
                  : suffixIcon,
              border: showOutlineBorder
                  ? const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    )
                  : InputBorder.none,
              // isCollapsed: true,

              focusColor: Styles.primaryColor,
              hintStyle: Styles.displaySmNormalStyle,
              hintText: labelText ?? 'Enter a value',
              floatingLabelBehavior: FloatingLabelBehavior.never),

          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          cursorColor: Styles.primaryTextColor,
          // Add any additional properties or configurations here
        );
      },
    );
  }
}
