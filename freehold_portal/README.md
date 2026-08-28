# Freehold Captive Portal — Home Assistant add-on

Hosts the Freehold captive WiFi portal on Home Assistant OS, on-prem at the
property. The portal renders the branded splash, reads its current capture
policy from Freehold, best-effort stores the guest's contact/consent, and
**always** authorizes the client onto the internet
via the local UniFi gateway (`UnifiControllerGuestAuth`). See
[`docs/adr/006-guest-wifi-capture-and-marketing.md`](../../../docs/adr/006-guest-wifi-capture-and-marketing.md).

The server is transport-agnostic (`src/handler.ts`); this add-on is just a host.
The same bundle runs anywhere Node runs.

## Build the bundle (required before deploy)

The add-on ships a single dependency-free file at
`rootfs/usr/src/portal-server.cjs`. It is generated from the monorepo, not
committed. Regenerate it before building/deploying:

```bash
pnpm --filter @freehold/portal bundle
```

## Install on Home Assistant OS

1. Copy this `addon/` directory to the HA host at `/addons/freehold_portal`
   (e.g. over the Samba/SSH add-on; requires root / protection-mode-off on the
   SSH add-on).
2. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Check for
   updates**, then open **Local add-ons → Freehold Captive Portal → Install**.
3. Configure options (Configuration tab):

   | Option | Meaning |
   |--------|---------|
   | `unifi_host` | UniFi gateway URL, e.g. `https://192.168.1.1` |
   | `unifi_site` | Controller site (usually `default`) |
   | `unifi_username` / `unifi_password` | A controller account that can authorize guests |
   | `unifi_verify_tls` | `false` for the gateway's self-signed cert |
   | `org_id` | Freehold org UUID |
   | `default_property_id` | Property used when SSID isn't in the map |
   | `ssid_map` | JSON `{ "SSID": "property-uuid" }` |
   | `authorize_minutes` | Authorization lifetime (default 1440) |
   | `property_name` / `primary_color` | Splash branding |
   | `capture_api_url` | Freehold's authenticated `/portal` cloud API base URL |
   | `capture_api_token` | Dedicated bearer token for policy reads and durable capture |

4. Start the add-on. It listens on `:8099`.

## Point the UniFi guest network at it

On the UniFi controller: **Settings → WiFi → (guest SSID) → enable Hotspot /
Guest Portal → External portal server** → the HA host IP `:8099`. Add the HA
host to the guest pre-authorization / walled-garden allow-list so the splash
loads before the client is authorized.

## Health

`GET /healthz` → `ok`.
