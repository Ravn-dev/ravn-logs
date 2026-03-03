# Ravn Logs

## Change Log History

### v0.8.5
[CHANGELOG.md]
- Created CHANGELOG Markdown file for version history prior to v0.9.0

[config.lua]
- Cleaned up formatting and added comments for each config line

[README.md]
- Converted README from .txt to .md
- Added documentation to README.md
- Changed text format to be GitHub Friendly
- Moved Change log history to CHANGELOG.md

[events.lua]
- Added WEAPON_UNARMED hash mapping for accurate unarmed death detection
- Updated F8 console logging to enforce per-command filtering via Config.F8ConsoleLogs.commands
- Improved documentation for the Extended Logging Module

### v0.8.4
[events.lua]
- Changed weaponNames table from hashes to GetHashKey (This allows the game to resolve the weapon names)

### v0.8.3
- GPLv3 License added.

### v0.8.2
[main.lua]
- Safe Identifiers filter now converts Discord IDs into mentions, allowing Discord logs to display the user’s @username. NDJSON still shows discord ID in numbers but with an @ symbol in front of it.

### v0.8.1
[client.lua]
- Fixed issue where when hit by car, then fall from building, client reports car damage data instead of fall damage data which miscategorized the log.

[event.lua]
- Added additional Hex for Grenade to weapons list. Please be the final time I have to do this.
- Removed damage scale from explosion Discord embed, useless info.

### v0.8.0
- Fixed PVP kills when attacker is in driver seat or passenger registers as a PVP kill and not a vehicle kill.
- Fixed issue with weapon names not registering for PVP Kills.
- Added new self death logs and logic to Death Resolver to determine if player death was self inflicted by vehicle or by self outside of vehicle.

### v0.7.8
[client.lua]
- Death logging resets only after a player is healed, preventing multiple logs during unconscious/downed states transitioning to bleedout/dead state.

### v0.7.7
[events.lua]
- Removed dead vehicle kill code block.
- Updated Discord embed Identifier lines to return tables instead of strings.

[main.lua]
- GetSafeIdentifiers function now whitelists identifiers instead of blacklisting. 

### v.0.7.6
- Removed sender name and sender identifiers from the explosions logs. Didnt log anything and is redundant combined with weapon fired and Death logs.

### v.0.7.5
- Attempted different method (remove loop) to detect weapon fire and get weapon name, this failed due to R* engine limitations. Moved weapon name table and function lookup to be global. Both weapon fires and PVP logging now resolves weapon name.  

### v.0.7.4
- Added ability to log F8 console custom commands to NDJSON and Discord webhooks. Is scalable to add multiple commands for logging. NOTE: cannot log "quit" or disconnect" commands.
NOTE: FiveM only allows logging of custom F8 commands registered by the resource. Built-in client commands like quit, disconnect, and other engine-level commands cannot be intercepted or logged.

### v.0.7.3
- Fixed PvP when player kills another player with a car, logs as environment
- Fixed PvP when player shoots from a car and kills another player, logs as environment

### v.0.7.2 
[discord.lua]
- Replaced immediate log sending with a queued, asynchronous system.
- Implemented rate-limiting awareness to avoid hitting Discord’s 30 messages per 60 seconds limit.
- Added 429 handling: detects when Discord rate-limits, waits for the suggested retry time, and retries messages.
- Introduced adaptive delays between messages based on Discord headers, including global rate-limit detection.
- Supports both embed logs and plain text logs without changing existing log formats.
- Ensures game events never block while logs are being sent.
- Safe under normal server load and prevents burst spamming of webhooks.

[events.lua]
- Readded Discord Embed for deaths (Vehicle Kills, Pvp Kills, Environmental Kills)

### v.0.7.1 
- Fixed instant vehicle kills send multiple death logs from client to server
- Moved resolving vehicle names from server (caused error due to GetDisplayNameFromVehicleModel not being a server function) to client.
- Fixed issue where when player is killed by being struck by a car, the client death logic would skip the vehicle death block and go to environment.
- Added more debugs and corrected existing debugs to include config toggle. (should probably make a config toggle for server and client, meh)
- Player death logic is pain.

### v.0.7 [Major Changes]
- Removed old PVP and player death logic. Rewrote player death logic, writes to NDJSON
- Added more debug lines in new client/server lua files.

### v.0.6
- Added shooter coordinates to weapon fired log. (Sent from Client to Server)
- Fixed victim coords not showing for player_killed_vehicle logs

### v.0.5
- Added player_killed_vehicle with logic. PVP kills logic determines if killer is in vehicle and if true, redirects to player_killed_vehicle logic.
- Various improvements to player_death, player_killed_vehicle, and player_killed logic.
- Discord embed message for player_klled_vehicle

### v0.4
- Privacy Improvements (Removed user IPs from logs)
- Each log event can send an embedded message to Discord via webhook.

### v0.3
- Added Iso timestamps (YYYY/MM/DD) to logs for easier reading (Default Time Format is UTC)
- Added chat logging for slash Me, Scene, and OOC commands including Loki friendly dynamic labeling
- Added Discord webhook integration with config.lua toggles
- Added and corrected weapon hashes in events.lua

### v0.2:
- Adds config.lua file to toggle specific event logging
- Config.lua file allows customizable file retention (Set how many days till NDJSON log files are deleted)
- Adds debug toggle and allows for server console view of logs (Weapon Fires logging in client console and server console only)

### Base Features v 0.1:
Logging:
- Players Joins to server
- Players Disconnecting from server with reason
- Player Deaths Suicide/PvP logging
- Weapon Fires along with type of weapon used
- Explosion events with vector3 coordinates

Additional Features:
- NDJSON file retention and daily file rotation.
- Labels to allow Promtail scrape 
- All logs are written to an NDJSON file (ravn_logs\logs) which rotates on a daily basis.(Meaning a new log file is created daily)