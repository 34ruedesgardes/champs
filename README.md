# Usage

## Installation

```bash
sudo apt update && sudo apt install -y git make
git clone https://github.com/34ruedesgardes/champs.git
cd ~/champs
sudo make bootstrap clean
```

## Usage

### Variables

```
SYNC_TOLERANCE : Tolérance de sync pour omxplayer-sync (défaut: .05)
OMXPLAYER_WAIT = Durée d'attente du lancement de omxplayer par omxplayer-sync (défaut: 2)
VIDEO_FILENAME = Nom du fichier vidéo à jouer. Il doit se situer dans le répertoire /var/lib/videos/ sur tous les périphériques (défaut: synctest.mp4)
OMXPLAYER_SYNC_MODE = Mode de omxplayer-sync. master ou slave (défaut: slave)
OMXPLAYER_SYNC_MASTER_STARTUP_DELAY = Délai avant le démarrage de omxplayer-sync sur le master (défaut: 5)
OMXPLAYER_VERBOSITY = Verbosité de omxplayer. "v"=verbeux, ""=standard  (défaut: v)
```

### Exemples

#### Configuration d'un master avec des valeurs par défaut et un fichier vidéo particulier

```bash
cd ~/champs
sudo make configure OMXPLAYER_SYNC_MODE=master OMXPLAYER_WAIT=20 VIDEO_FILENAME=mavideo.mov
```
