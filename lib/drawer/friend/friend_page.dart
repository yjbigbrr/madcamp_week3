import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'friend_view_model.dart';
import 'friend_model.dart';

class FriendPage extends StatelessWidget {
  final String userId;

  FriendPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FriendViewModel()
        ..fetchFriends(userId)
        ..fetchFriendRequests(userId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Friends'),
        ),
        body: Consumer<FriendViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: viewModel.searchController,
                          decoration: InputDecoration(
                            labelText: 'Search by ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          viewModel.searchUser(viewModel.searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
                if (viewModel.searchedUser != null)
                  ListTile(
                    title: Text(viewModel.searchedUser!.nickname),
                    subtitle: Text(viewModel.searchedUser!.id),
                    trailing: IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () {
                        viewModel.sendFriendRequest(userId, viewModel.searchedUser!.id);
                      },
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.friends.length,
                    itemBuilder: (context, index) {
                      final friend = viewModel.friends[index];
                      return ListTile(
                        title: Text(friend.nickname),
                        subtitle: Text(friend.id),
                      );
                    },
                  ),
                ),
                Divider(),
                Text('Friend Requests'),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.friendRequests.length,
                    itemBuilder: (context, index) {
                      final request = viewModel.friendRequests[index];
                      return ListTile(
                        title: Text(request.senderId),
                        subtitle: Text(request.senderId),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                viewModel.acceptFriendRequest(userId, request.senderId);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                viewModel.rejectFriendRequest(userId, request.senderId);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}