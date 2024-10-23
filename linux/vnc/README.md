# Headless VNC
These are some scripts to install VNC (with dummy display) for headless linux devices. Such as ones on VPSs.

To install:
```bash
wget https://raw.githubusercontent.com/East-Helena-Public-Schools-IT/scripts/main/linux/vnc/install
chmod +x install
sudo su
./install
```

## Notes:
According to [this reddit page](https://www.reddit.com/r/linux4noobs/comments/hq7i1v/how_do_i_start_x11vnc_at_startup_and_keep_it/) you can launch into lightdm with vnc. Might do this later, but for now it just has a vnc password.
