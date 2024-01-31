import 'package:chatify/resources/constants/styles.dart';
import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final double height;
  final void Function()? onPressed;
  final String text;
  final Color? backgroundColor;

  const LongButton({
    super.key,
    required this.height,
    this.onPressed,
    this.text = 'Login',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Styles.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
