# MyTunnel

**Simple SSH tunnel manager for Linux**

## Dependencies

- **RPM:** `gtk2`, `openssh`, `sshpass`, `systemd`
- **DEB:** `libgtk2.0-0`, `openssh-client`, `sshpass`, `systemd`

**Configuration files:** ~/.config/mytunnel

![MyTunnel screenshot](./Screenshot1.png)

## About

MyTunnel is a simple graphical SSH tunnel manager for Linux.

It allows you to create and manage SSH local port forwarding to access services running on a remote server.

For example, MyTunnel can be used to securely access the **3x-ui web panel** hosted on a remote VPS without exposing the panel port to the public Internet.

The application establishes an SSH connection and forwards a local port to the remote service. You can then access the panel through your local web browser.

MyTunnel uses systemd user services to manage the SSH tunnel and supports automatic startup at system boot.

Connection settings are straightforward and intuitive. No additional instructions are required — simply fill in the connection fields and start the tunnel.

**Useful information:** [Accessing the 3x-ui panel through an SSH tunnel (Russian)](https://github.com/AKotov-dev/SReality/blob/main/doc/hide_3x-ui.md)
