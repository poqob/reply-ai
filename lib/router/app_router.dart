import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:replai/features/accounts/ui/accounts_page.dart';
import 'package:replai/features/accounts/ui/add_account_page.dart';
import 'package:replai/features/composer/ui/composer_page.dart';
import 'package:replai/features/email_detail/ui/email_detail_page.dart';
import 'package:replai/features/inbox/ui/inbox_page.dart';
import 'package:replai/features/settings/ui/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AccountsPage(),
        routes: [
          GoRoute(
            path: 'accounts/add',
            builder: (context, state) => const AddAccountPage(),
          ),
          GoRoute(
            path: 'inbox/:accountId',
            builder: (context, state) {
              final accountId = state.pathParameters['accountId']!;
              return InboxPage(accountId: accountId);
            },
          ),
          GoRoute(
            path: 'email/:accountId/:messageId',
            builder: (context, state) {
              final accountId = state.pathParameters['accountId']!;
              final messageId = state.pathParameters['messageId']!;
              return EmailDetailPage(
                accountId: accountId,
                messageId: messageId,
              );
            },
          ),
          GoRoute(
            path: 'compose',
            builder: (context, state) {
              final to = state.uri.queryParameters['to'];
              final subject = state.uri.queryParameters['subject'];
              final body = state.uri.queryParameters['body'];
              return ComposerPage(to: to, subject: subject, body: body);
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
