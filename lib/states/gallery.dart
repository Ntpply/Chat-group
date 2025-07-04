import 'package:equatable/equatable.dart';

class GalleryState extends Equatable {
  final List<Map<String, dynamic>> images;
  final bool isLoading;
  final String? errorMessage;

  const GalleryState({
    this.images = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  GalleryState copyWith({
    List<Map<String, dynamic>>? images,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GalleryState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [images, isLoading, errorMessage];
}
