# Youth Center – AR & Live Projects

Application Flutter pour un centre de jeunesse, avec :

- **Réalité augmentée (AR)** pour afficher des modèles 3D interactifs.
- **Projets “live”** avec caméra, micro et chat temps-réel.
- Intégration **Supabase** pour les données et la messagerie.

## Fonctionnalités principales

- **AR View** (`ArViewScreen`)
  - Chargement de modèles 3D (GLB) depuis les assets.
  - Détection de plans et placement du modèle sur la surface.
  - Zoom par pincement (pinch to zoom).
  - Déplacement du modèle avec les doigts.
  - Bouton d’**assistant AI**:
    - Toggle ON/OFF (bouton rond en haut à droite).
    - Panneau d’assistance avec commande **vocale** (speech-to-text).

- **Page Live** (`LivePage`)
  - Affichage de la caméra (Live).
  - Chat texte lié à un projet (`projectTitle`).
  - Rafraîchissement automatique des messages.
  - Gestion basique du micro / caméra.

## Démarrage du projet

### Prérequis

- Flutter installé (version compatible avec `sdk: ^3.7.2`).
- Android Studio / Xcode pour lancer sur émulateur ou appareil réel.

### Installation

```bash
flutter pub get
```

### Lancer l’app

```bash
flutter run
```

## AR – Notes techniques

- Plugin AR utilisé : `ar_flutter_plugin_engine`.
- Modèles GLB copiés dans le dossier documents de l’app à partir des assets.
- Interaction :
  - **Tap** sur un plan détecté → place un modèle 3D.
  - **Pinch** → change l’échelle du modèle.
  - **Glisser** → déplace le modèle sur le plan.

## Assistant AI vocal

- Basé sur le package `speech_to_text`.
- Texte reconnu transmis à un handler (`_onSendAiMessage`) qui pourra être relié à un backend AI.
- Animation du bouton micro (effet d’ondes) pendant l’écoute.

## Backend & AI services

- **`ai next_verse`** : sous-projet Python pour les services AI (FastAPI + DeepSeek/Gemini).
  - Nouveau module **MindSpore** (`ai next_verse/MindSpore.py`) pour expérimenter des réseaux neuronaux avec MindSpore.
  - L’installation de MindSpore dépend de votre plateforme (CPU / GPU) – voir la doc officielle : https://www.mindspore.cn/install

## Structure rapide

- `lib/screens/ar/ar_view_screen.dart` : écran AR + assistant AI.
- `lib/screens/projects/live_page.dart` : page live avec caméra/chat.
- `lib/config/` : configuration UI et autres utilitaires.
- `ai next_verse/` : backend AI + module MindSpore pour l’expérimentation ML.

## License

Projet privé – usage interne au centre de jeunesse (adapter si nécessaire).
