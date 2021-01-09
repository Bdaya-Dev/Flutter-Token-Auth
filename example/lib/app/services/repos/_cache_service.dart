import 'package:bdaya_repository_pattern/bdaya_repository_pattern.dart';
import 'package:bearer_example/app/data/user_model.dart';
import 'package:bearer_example/app/services/repos/user_repo.dart';

class CacheService extends CacheServiceInterface {
  UserRepo _userRepo;
  UserRepo get userRepo => _userRepo;

  @override
  Future<void> initRepos() async {
    await (_userRepo = UserRepo()).init();
  }

  @override
  void registerTypeAdapters() {
    Hive.registerAdapter(UserModelAdapter());
  }
}
