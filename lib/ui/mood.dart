import 'package:flutter/material.dart';

import '../l10n.dart';

/// Stimmungssymbole von 0 (sehr schlecht) bis 4 (sehr gut).
/// Es werden Icons statt Emojis genutzt, damit sie auf jedem System gleich aussehen.
const moodIcons = <IconData>[
  Icons.sentiment_very_dissatisfied,
  Icons.sentiment_dissatisfied,
  Icons.sentiment_neutral,
  Icons.sentiment_satisfied,
  Icons.sentiment_very_satisfied,
];

List<String> moodLabels(S s) =>
    [s.moodTerrible, s.moodBad, s.moodOkay, s.moodGood, s.moodGreat];
