import 'package:algoriza_team_6_realestate_app/styles/colors.dart';
import 'package:algoriza_team_6_realestate_app/widgets/default_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../business_logic/cubit/profile_cubit/profile_cubit.dart';
import '../../constants/constant_methods.dart';
import '../../constants/constants.dart';
import '../../data/di/di.dart';
import '../../views/edit_profile/profile_picture_dialog.dart';
import '../../widgets/default_cached_network_image.dart';
import '../../widgets/default_form_field.dart';
import '../../widgets/default_material_button.dart';
import '../../widgets/default_text.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key,}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  late ProfileCubit cubit;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
     cubit = sl<ProfileCubit>();
  }

  @override
  Widget build(BuildContext context) {

    final nameController = TextEditingController(text: cubit.auth.data.name);
    final emailController = TextEditingController(text: cubit.auth.data.email);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if(state is UpdateProfileSuccessState){
            showToastMsg(
              msg: 'Updating Profile Data Succeeded',
              toastState: ToastStates.SUCCESS,
            );
            cubit.getProfileInfo();
            Navigator.pop(context);
          }else if(state is UpdateProfileFailureState){
            showToastMsg(
              msg: state.errorMessage,
              toastState: ToastStates.ERROR,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        alignment: AlignmentDirectional.bottomEnd,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: defaultAppWhiteColor.withOpacity(0.1),
                            ),
                            child: DefaultCachedNetworkImage(
                              height: 25.h,
                              imageUrl: cubit.auth.data.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => ImagePickerDialog(
                                      cameraOnTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.camera)
                                            .then((image) {
                                          if (image != null) {
                                            cubit.updateProfile(
                                              name: cubit.auth.data.name,
                                              email: cubit.auth.data.email,
                                              profilePicture: image,
                                            );
                                          }
                                        });
                                      },
                                      galleryOnTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.gallery)
                                            .then((image) {
                                          if (image != null) {
                                            cubit.updateProfile(
                                              name: cubit.auth.data.name,
                                              email: cubit.auth.data.email,
                                              profilePicture: image,
                                            );
                                          }
                                        });
                                      },
                                    ));
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                size: 30.sp,
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                      child: DefaultFormField(
                        labelText: 'Name',
                        validator: (value){
                          if(nameController.text.isEmpty){
                            return "Name can't be empty.";
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.person),
                        controller: nameController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w,).copyWith(bottom: 4.h),
                      child: DefaultFormField(
                        labelText: 'E-mail',
                        validator: (value){
                          if(emailController.text.isEmpty){
                            return "E-mail can't be empty.";
                          }
                          return null;
                        },
                        prefixIcon: const Icon(Icons.email),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    state is UpdateProfileLoadingState ?
                    const DefaultLoadingIndicator()
                        : DefaultMaterialButton(
                      margin: EdgeInsets.symmetric(horizontal: 5.w,),
                      radius: 25.sp,
                      onPressed: () {
                        if(formKey.currentState!.validate()){
                          cubit.updateProfile(
                              name: nameController.text,
                              email: emailController.text,
                          );
                        }
                      },
                      child: DefaultText(
                        text: 'Apply',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
