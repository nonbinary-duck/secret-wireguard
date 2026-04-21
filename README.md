# SecretWireguard

This project uses the LinuxServer WireGuard container and builds `udp2raw` to run WireGuard through a wrapped transport.

## Generating WireGuard keys with the LinuxServer container

You can use the container itself to generate WireGuard keys and print them to the console without installing WireGuard tools on your host.

This prints:

- server private key
- server public key
- client private key
- client public key
- WireGuard pre-shared key

```bash
docker run --rm --entrypoint /bin/sh -it lscr.io/linuxserver/wireguard:latest -lc '
umask 077

wg genkey | tee /tmp/server_private.key | wg pubkey > /tmp/server_public.key
wg genkey | tee /tmp/client_private.key | wg pubkey > /tmp/client_public.key
wg genpsk > /tmp/preshared.key

echo "SERVER_PRIVATE_KEY=$(cat /tmp/server_private.key)"
echo "SERVER_PUBLIC_KEY=$(cat /tmp/server_public.key)"
echo "CLIENT_PRIVATE_KEY=$(cat /tmp/client_private.key)"
echo "CLIENT_PUBLIC_KEY=$(cat /tmp/client_public.key)"
echo "PRESHARED_KEY=$(cat /tmp/preshared.key)"'
```

### Generate a cryptographically secure udp2raw password

```bash
echo "UDP2RAW_PASSWORD=$(head -c 32 /dev/urandom | base64)"
```
### Generate a cryptographically random udp2raw port above 1024

```bash
echo "UDP2RAW_PORT=$(( ( $(od -An -N2 -tu2 /dev/urandom) % 64511 ) + 1025 ))"
```

## Security notes

- Treat all private keys and pre-shared keys as secrets.
- Do not paste private keys into shell history on shared systems if you can avoid it.
- Prefer saving them into restricted files with `umask 077`.
- Never commit private keys or pre-shared keys into git.
- Public keys are safe to share with the corresponding peer.

## Example usage in config files

### Server `wg0.conf`

```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>
MTU = 1200

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
PresharedKey = <PRESHARED_KEY>
AllowedIPs = 10.8.0.2/32
```

### Client `wg0.conf`

```ini
[Interface]
Address = 10.8.0.2/32
PrivateKey = <CLIENT_PRIVATE_KEY>
MTU = 1200

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
PresharedKey = <PRESHARED_KEY>
AllowedIPs = 10.8.0.0/24
Endpoint = 127.0.0.1:51820
PersistentKeepalive = 20
```
