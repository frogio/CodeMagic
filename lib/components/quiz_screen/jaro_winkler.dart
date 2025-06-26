double jaroWinkler(String s1, String s2) {
  if (s1 == s2) return 1.0;

  int len1 = s1.length;
  int len2 = s2.length;
  if (len1 == 0 || len2 == 0) return 0.0;

  int matchDistance = (len1 > len2 ? len1 : len2) ~/ 2 - 1;

  List<bool> s1Matches = List.filled(len1, false);
  List<bool> s2Matches = List.filled(len2, false);

  int matches = 0;
  for (int i = 0; i < len1; i++) {
    int start = (i - matchDistance).clamp(0, len2);
    int end = (i + matchDistance + 1).clamp(0, len2);
    for (int j = start; j < end; j++) {
      if (s2Matches[j]) continue;
      if (s1[i] != s2[j]) continue;
      s1Matches[i] = true;
      s2Matches[j] = true;
      matches++;
      break;
    }
  }

  if (matches == 0) return 0.0;

  int t = 0;
  int k = 0;
  for (int i = 0; i < len1; i++) {
    if (!s1Matches[i]) continue;
    while (!s2Matches[k]) k++;
    if (s1[i] != s2[k]) t++;
    k++;
  }

  double m = matches.toDouble();
  double jaro = ((m / len1) + (m / len2) + ((m - t / 2) / m)) / 3.0;

  // Jaro-Winkler adjustment
  int prefix = 0;
  for (int i = 0; i < [len1, len2, 4].reduce((a, b) => a < b ? a : b); i++) {
    if (s1[i] == s2[i]) {
      prefix++;
    } else {
      break;
    }
  }

  return jaro + prefix * 0.1 * (1 - jaro);
}
