SYNC_TOLERANCE = .05
OMXPLAYER_WAIT = 2
OMXPLAYER_SYNC_MASTER_STARTUP_DELAY = 5
VIDEO_FILENAME = synctest.mp4
OMXPLAYER_SYNC_MODE = slave
OMXPLAYER_VERBOSITY = v

define SUPERVISOR_PROGRAM_MASTER
[program:omxplayer-sync-master]
command=bash -c 'sleep $(OMXPLAYER_SYNC_MASTER_STARTUP_DELAY) && /usr/local/bin/omxplayer-sync -mu$(OMXPLAYER_VERBOSITY)b /var/lib/videos/$(VIDEO_FILENAME)'
autostart=false
redirect_stderr=true
killasgroup=true
stopasgroup=true
startsecs=5
endef
export SUPERVISOR_PROGRAM_MASTER

define SUPERVISOR_PROGRAM_SLAVE
[program:omxplayer-sync-slave]
command=/usr/local/bin/omxplayer-sync -lu$(OMXPLAYER_VERBOSITY)b /var/lib/videos/$(VIDEO_FILENAME)
autostart=false
redirect_stderr=true
killasgroup=true
stopasgroup=true
startsecs=5
endef
export SUPERVISOR_PROGRAM_SLAVE

define SSH_KEYS
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBtkxRXehGPwJ0KKcyrXq9o2/hfEt06vjcZLakRWHMaJD0WTJrKNNn1Mq+bKf6wJkTW2CWDnjiTMFcqQaTUQfn0bcNhnPgZ6zyYFd/SiC2kZRuvnVYP2kV7MZMvgnEQjrpxCd7mxOmhih1gv68SSk94MmEVXBhjQEVZsFJHyBaNp++NY2+JsjYyuFwPURH+3XcJS3H8QEyVOnnFzJ7ZOo/egk3FoQMmbljgSHMg/jgrIQIAMtFS2PFa0oLUH6+nAZpbS4mNufN7L6T5iwgMAkbrO3Ff/1tQIOu3t/bHKUtwmeUMuKdAz0m2Hu/LImcJBz45u1vsr6ED3qLEEbk9yfx trivoallan@trivoallan-Latitude-E6430
endef
export SSH_KEYS

all: bootstrap configure

bootstrap:
	# Installation des clés SSH autorisées
	rm -f ~pi/.ssh/id_rsa*
	sudo -u pi ssh-keygen -N "" -f ~pi/.ssh/id_rsa
	echo $$SSH_KEYS > ~pi/.ssh/authorized_keys

	# Installation des dépendances
	apt update
	apt install -y fbset fonts-freefont-ttf gdebi-core libpcre3 libssh-4 python3-dbus supervisor

	# Installation de la dernière version de omxplayer
	wget -N http://omxplayer.sconde.net/builds/omxplayer_0.3.7~git20160713~66f9076_armhf.deb
	gdebi -n omxplayer_0.3.7~git20160713~66f9076_armhf.deb
	rm -f /usr/bin/omxplayer-sync

	# Installation de la dernière version de omxplayer-sync
	wget -O- https://raw.githubusercontent.com/turingmachine/omxplayer-sync/master/omxplayer-sync > /usr/local/bin/omxplayer-sync
	chmod +x /usr/local/bin/omxplayer-sync

	# Désactivation du wifi et du bluetooth
	ifdown wlan0
	echo "blacklist brcmfmac" > /etc/modprobe.d/raspi-blacklist.conf
	echo "blacklist brcmutil" >> /etc/modprobe.d/raspi-blacklist.conf
	echo "blacklist btbcm" >> /etc/modprobe.d/raspi-blacklist.conf
	echo "blacklist hci_uart" >> /etc/modprobe.d/raspi-blacklist.conf

	# Mise à jour des valeurs en dur dans omxplayer-sync
	sed -i "s/^SYNC_TOLERANCE = \
	..*/SYNC_TOLERANCE = ${SYNC_TOLERANCE}/" /usr/local/bin/omxplayer-sync
	sed -i "s/sleep(.*) # wait for omxplayer to appear on dbus/sleep(${OMXPLAYER_WAIT}) # wait for omxplayer to appear on dbus/" /usr/local/bin/omxplayer-sync

	# Désactivation du sauveur d'écran
	sed -i "s/#\?xserver-command=.\+/xserver-command=X -s 0 -dpms/" /etc/lightdm/lightdm.conf

configure:
	# Configuration de supervisor
	echo "$$SUPERVISOR_PROGRAM_MASTER" > /etc/supervisor/conf.d/omxplayer-sync-master.conf
	echo "$$SUPERVISOR_PROGRAM_SLAVE" > /etc/supervisor/conf.d/omxplayer-sync-slave.conf
	if [ "${OMXPLAYER_SYNC_MODE}" = "slave" ]; then sed -i "s/autostart=false/autostart=true/" /etc/supervisor/conf.d/omxplayer-sync-slave.conf; else sed -i "s/autostart=false/autostart=true/" /etc/supervisor/conf.d/omxplayer-sync-master.conf; fi
	supervisorctl update

clean:
	rm -f /etc/profile.d/omxplayer*
	rm -f /etc/supervisor/conf.d/omxplayer-sync*.conf
