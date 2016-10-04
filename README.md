# Usage

## Installation 

```bash
apt update && apt install -y git make
git clone https://github.com/34ruedesgardes/champs.git
```

## Usage

### Variables

```
SYNC_TOLERANCE : Tolérance de sync pour omxplayer-sync (défaut: .05)
OMXPLAYER_WAIT = Durée d'attente du lancement de omxplayer par omxplayer-sync (défaut: 2)
VIDEO_FILENAME = Nom du fichier vidéo à jouer. Il doit se situer dans le répertoire /var/lib/videos/ sur tous les périphériques (défaut: synctest.mp4)
OMXPLAYER_SYNC_MODE = Mode de omxplayer-sync. master ou slave (défaut: slave)
```

### Exemples

#### Configuration d'un master avec des valeurs par défaut et un fichier vidéo particulier

```bash
cd champs
make OMXPLAYER_SYNC_MODE=master VIDEO_FILENAME=mavideo.mov
```
