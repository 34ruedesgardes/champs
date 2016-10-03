SYNC_TOLERANCE = .05
OMXPLAYER_WAIT = 2
VIDEO_FILENAME = synctest.mp4
OMXPLAYER_SYNC_MODE = slave

configure:
	sudo rm -f /usr/bin/omxplayer-sync
	wget -O- https://raw.githubusercontent.com/turingmachine/omxplayer-sync/master/omxplayer-sync | sudo tee /usr/local/bin/omxplayer-sync
	sudo sed -i "s/^SYNC_TOLERANCE = \..*/SYNC_TOLERANCE = ${SYNC_TOLERANCE}/" /usr/local/bin/omxplayer-sync
	sudo sed -i "s/sleep(.*) # wait for omxplayer to appear on dbus/sleep(${OMXPLAYER_WAIT}) # wait for omxplayer to appear on dbus/" /usr/local/bin/omxplayer-sync
	sudo chmod +x /usr/local/bin/omxplayer-sync
	if [ "${OMXPLAYER_SYNC_MODE}" = "slave" ]; then echo "/usr/local/bin/omxplayer-sync -luvb /var/lib/videos/${VIDEO_FILENAME}" | sudo tee /etc/profile.d/omxplayer-sync-launch.sh; else echo "/usr/local/bin/omxplayer-sync -muvb /var/lib/videos/${VIDEO_FILENAME}" | sudo tee /etc/profile.d/omxplayer-sync-launch.sh; fi 

