import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const RegisterState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  RegisterState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RegisterState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isSuccess, errorMessage];
}
