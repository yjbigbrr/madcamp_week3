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
                        onPressed: () async {
                          await viewModel.searchUser(viewModel.searchController.text);

                          // Show a snack bar if the user was not found
                          if (viewModel.searchedUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('User not found'),
                              ),
                            );
                          }
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
                        if (_isRequestButtonEnabled(viewModel)) {
                          viewModel.sendFriendRequest(userId, viewModel.searchedUser!.id);
                        }
                      },
                      color: _isRequestButtonEnabled(viewModel) ? null : Colors.grey,
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
              ],
            );
          },
        ),
        floatingActionButton: Consumer<FriendViewModel>(
          builder: (context, viewModel, child) {
            return FloatingActionButton(
              onPressed: () {
                _showFriendRequestsDialog(context, viewModel);
              },
              child: Stack(
                children: [
                  Icon(Icons.person),
                  if (viewModel.friendRequests.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFriendRequestsDialog(BuildContext context, FriendViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Friend Requests'),
          content: viewModel.friendRequests.isEmpty
              ? Text('No friend requests')
              : Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
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
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          viewModel.rejectFriendRequest(userId, request.senderId);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to determine if the request button should be enabled
  bool _isRequestButtonEnabled(FriendViewModel viewModel) {
    if (viewModel.searchedUser == null) {
      return false;
    }

    final searchedUserId = viewModel.searchedUser!.id;

    // Check if the searched user is already a friend or has a pending request
    final isFriend = viewModel.friends.any((friend) => friend.id == searchedUserId);
    final hasPendingRequest = viewModel.friendRequests.any((request) => request.senderId == searchedUserId);

    return !isFriend && !hasPendingRequest;
  }
}
