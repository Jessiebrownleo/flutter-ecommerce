import 'package:eshop/core/constant/images.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/user/user.dart';
import '../../../../widgets/input_form_button.dart';
import '../../../../widgets/input_text_form_field.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController email = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.user.name;
    email.text = widget.user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: ListView(
          children: [
            Hero(
              tag: "C001",
              child: CircleAvatar(
                radius: 75.0,
                backgroundColor: Colors.grey.shade200,
                child: Image.asset(kUserAvatar),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            InputTextFormField(
              controller: nameController,
              hint: 'Name',
            ),
            const SizedBox(
              height: 12,
            ),
            InputTextFormField(
              controller: email,
              enable: false,
              hint: 'Email Address',
            ),
            const SizedBox(
              height: 12,
            ),
            // InputTextFormField(
            //   controller: firstNameController,
            //   hint: 'Contact Number',
            // ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: InputFormButton(
          onClick: () {},
          titleText: "Update",
          color: Colors.black87,
        ),
      )),
    );
  }
}
