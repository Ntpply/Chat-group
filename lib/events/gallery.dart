import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGalleryImages extends GalleryEvent {
  final String roomId;

  LoadGalleryImages({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}
