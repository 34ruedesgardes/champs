SYNC_TOLERANCE = .05
OMXPLAYER_WAIT = 2
VIDEO_FILENAME = synctest.mp4
OMXPLAYER_SYNC_MODE = slave

define SUPERVISOR_PROGRAM_MASTER
[program:omxplayer-sync-master]
command=/usr/local/bin/omxplayer-sync -muvb /var/lib/videos/$(VIDEO_FILENAME)
autostart=false
redirect_stderr=true
endef
export SUPERVISOR_PROGRAM_MASTER

define SUPERVISOR_PROGRAM_SLAVE
[program:omxplayer-sync-slave]
command=/usr/local/bin/omxplayer-sync -luvb /var/lib/videos/$(VIDEO_FILENAME)
autostart=false
redirect_stderr=true
endef
export SUPERVISOR_PROGRAM_SLAVE

all: bootstrap configure

bootstrap:
	apt update
	apt install -y fbset fonts-freefont-ttf gdebi-core libpcre3 libssh-4 python3-dbus supervisor
	wget -N http://omxplayer.sconde.net/builds/omxplayer_0.3.7~git20160713~66f9076_armhf.deb
	gdebi -n omxplayer_0.3.7~git20160713~66f9076_armhf.deb
	rm -f /usr/bin/omxplayer-sync
	wget -O- https://raw.githubusercontent.com/turingmachine/omxplayer-sync/master/omxplayer-sync > /usr/local/bin/omxplayer-sync
	chmod +x /usr/local/bin/omxplayer-sync

configure:
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

	# Configuration de supervisor
	echo "$$SUPERVISOR_PROGRAM_MASTER" > /etc/supervisor/conf.d/omxplayer-sync-master.conf
	echo "$$SUPERVISOR_PROGRAM_SLAVE" >> /etc/supervisor/conf.d/omxplayer-sync-slave.conf
	if [ "${OMXPLAYER_SYNC_MODE}" = "slave" ]; then sed -i "s/autostart=false/autostart=true/" /etc/supervisor/conf.d/omxplayer-sync-slave.conf; else sed -i "s/autostart=false/autostart=true/" /etc/supervisor/conf.d/omxplayer-sync-master.conf; fi
	service supervisor restart
	supervisorctl status
	service supervisor restart

clean:
	rm -f /etc/profile.d/omxplayer*
	rm -f /etc/supervisor/conf.d/omxplayer-sync*.conf
