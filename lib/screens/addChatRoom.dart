import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/addChatRoom.dart';
import '../events/addChatRoom.dart';
import '../states/addChatRoom.dart';

class AddChatRoomScreen extends StatelessWidget {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddChatRoomBloc()..add(FetchUserData()),
      child: Scaffold(
        appBar: AppBar(title: Text('สร้างห้องแชท')),
        body: BlocConsumer<AddChatRoomBloc, AddChatRoomState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.currentUsername == null) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: roomNameController,
                    decoration: InputDecoration(labelText: 'ชื่อห้องแชท'),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(hintText: 'เช่น pear123'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          context
                              .read<AddChatRoomBloc>()
                              .add(AddMember(usernameController.text));
                          usernameController.clear();
                        },
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: state.memberUsernames.map((username) {
                      return Chip(
                        label: Text(username),
                        deleteIcon: username == state.currentUsername
                            ? null
                            : Icon(Icons.close),
                        onDeleted: username == state.currentUsername
                            ? null
                            : () => context
                                .read<AddChatRoomBloc>()
                                .add(RemoveMember(username)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            context.read<AddChatRoomBloc>().add(
                                  CreateChatRoom(roomNameController.text),
                                );
                          },
                    icon: Icon(Icons.check),
                    label: Text(state.isLoading
                        ? 'กำลังสร้าง...'
                        : 'สร้างห้องแชท'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
