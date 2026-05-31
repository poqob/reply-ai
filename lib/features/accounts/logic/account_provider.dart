import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:replai/data/models/mail_account.dart';
import 'package:replai/data/repositories/email_repository.dart';

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return EmailRepository();
});

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<MailAccount>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<MailAccount>> {
  @override
  Future<List<MailAccount>> build() async {
    final repo = ref.read(emailRepositoryProvider);
    return repo.loadAccounts();
  }

  Future<void> addAccount(MailAccount account, String password) async {
    final repo = ref.read(emailRepositoryProvider);
    final current = state.value ?? [];
    await repo.savePassword(account.id, password);

    final updated = [...current];
    if (account.isDefault) {
      for (var i = 0; i < updated.length; i++) {
        if (updated[i].isDefault) {
          updated[i] = updated[i].copyWith(isDefault: false);
        }
      }
    }
    updated.add(account);
    await repo.saveAccounts(updated);
    state = AsyncData(updated);
  }

  Future<void> updateAccount(MailAccount account) async {
    final repo = ref.read(emailRepositoryProvider);
    final current = state.value ?? [];
    final updated = current.map((a) => a.id == account.id ? account : a).toList();
    await repo.saveAccounts(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteAccount(MailAccount account) async {
    final repo = ref.read(emailRepositoryProvider);
    await repo.deleteAccount(account);
    final current = state.value ?? [];
    state = AsyncData(current.where((a) => a.id != account.id).toList());
  }
}
