String normalizeUrl(String input) =>
    input.startsWith('http') ? input : 'https://$input';

String removeHttp(String url) => url.replaceFirst(RegExp(r'^https?://'), '');