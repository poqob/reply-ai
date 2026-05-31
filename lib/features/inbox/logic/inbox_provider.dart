import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/data/models/email_message.dart';
import 'package:replai/features/accounts/logic/account_provider.dart';

final inboxProvider =
    FutureProvider.family.autoDispose<List<EmailMessage>, String>((ref, accountId) async {
  final repo = ref.read(emailRepositoryProvider);

  final accountsAsync = await ref.read(accountsProvider.future);
  if (accountsAsync.isEmpty) {
    throw Exception('No accounts configured');
  }

  final account = accountsAsync.firstWhere(
    (a) => a.id == accountId,
    orElse: () => throw Exception('Account not found'),
  );

  final password = await repo.getPassword(account.id);
  if (password == null) {
    throw Exception('Password not found for account');
  }

  await repo.connectToImap(account, password);

  try {
    return repo.fetchInbox();
  } catch (e) {
    await repo.disconnectFromImap();
    rethrow;
  }
});
