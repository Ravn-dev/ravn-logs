# Ravn Logs

Ravn Logs is an open source FiveM logging resource for tracking player activity and server events. It helps server owners and admins see what’s happening in the game, whether for moderation or development.

## Creator: Ravn
https://github.com/Ravn-dev

## GitHub Repository:
https://github.com/Ravn-dev/ravn-logs

## Version:
v1.0.0
- Added independent NDJSON, Discord, and optional MySQL/MariaDB logging sinks.
- Improved NDJSON write performance with append-based logging and removed shell-based retention cleanup.
- Added a read-only Svelte in game log viewer with paginated database search and filters.
- Added configurable ACE and Discord role access checks for the viewer.
- Added a validated server side SubmitLog export for custom events.
- Hardened death, weapon fire, F8, and viewer event handling with input validation and rate limits.
- Corrected Discord rate limit retry timing and stopped exposing webhook URLs in logs.
- Fixed the death respawn latch’s undefined variable reference while retaining its health-based reset behavior.

## Supported Frameworks:
Ravn Logs uses FiveM Natives which should allow the resource to function on all frameworks.
- Qbox
- QBcore
- ESX (Untested, community feedback would be appreciated)

## Prerequisites:
- FiveM Artifact: 25770 or higher
- GTA Game Build: 3258 or higher
- Tx Admin

## Features:

### Full Player Death Logging
Tracks multiple types of player deaths:
- Player vs Player (PVP) kills
- NPC combat
- Vehicle related deaths (can distinguish if the killer was a player or NPC)
- Self inflicted deaths
- Environmental deaths
		
### Weapon Fire Logging
- Logs each time a player fires a weapon
- Log includes:
    - Player’s FiveM screen name
    - Server ID and identifiers
    - Weapon name (or hash for custom weapons)
    - Coordinates of where the shot was fired

### Explosion Event Logging
- Logs when an explosion occurs in the world. 
- Log includes: 
    - Type of explosion
    - Coordinates of where the explosion occurred.

### Chat Message Logging
- Logs specific commands in player chat (e.g., /ooc, /me, /scene) along with the player’s message
- Log includes:
    - Player’s FiveM screen name
    - Server ID and identifiers
    - Displays the type of command used
    - Displays the message the player sent

### F8 Console Logging
- Logs specific F8 console entries
    - Player’s FiveM screen name
    - Server ID and identifiers
    - Displays the command the player used
**NOTE: Some of the FiveM native F8 console commands are unable to be intercepted and logged such as the "quit" and "disconnect" command. (I tried :/)

### Player Joined Logs
- Logs each time a player connects to the server.
- Log includes:
    - Player’s FiveM screen name
    - Server ID and identifiers

### Player Disconnect Logs
- Logs each time a player disconnects from the server.
- Log includes:
    - Player’s FiveM screen name
    - Server ID and identifiers
    - Disconnect reason, pulled from TxAdmin. 

### Database Support and In-Game Log Viewer
- Optional: MySQL/MariaDB storage is supported through oxmysql. Start oxmysql before ravn-logs and enable database storage in `Config.Sinks`.
- The read-only viewer opens with `/ravnlogs`. It searches logs stored in the database; it does not search NDJSON files or Discord messages. Search by event type, player, time range, or text. Results are paginated.
- The viewer is available only when database storage is enabled and oxmysql is running.
- Set `Config.LogViewer.accessMode` to `ace`, `discord`, `either`, or `both`:
  - `ace`: requires the ACE permission configured in `Config.LogViewer.acePermission`.
  - `discord`: requires the configured Discord guild role.
  - `either`: grants access if the player passes either check.
  - `both`: requires the player to pass both checks.
- Example ACE grant: `add_ace group.admin ravnlogs.view allow`
- For Discord role checks, configure the guild and role IDs in `Config.LogViewer` and add the bot token as a server-only convar:
  `set ravn_logs_discord_bot_token "YOUR_BOT_TOKEN"`
  Do not use `setr`, which replicates the convar to clients. The bot must be a member of the configured guild. Missing credentials or a failed Discord check denies access.
- Discord webhook logging is separate from the bot-based role check.

### Discord Logging
- Send configured server logs to Discord channels using webhooks.
- Handles Discord rate limits and retries queued messages after temporary failures.
- Configure webhook URLs in `server/discord.lua`.

### NDJSON Logging
- Writes logs to NDJSON files inside the ravn-logs resource using append-based writes.
- Rotates files daily and removes old files according to `Config.LogRetentionDays`.
- Timestamps use ISO 8601 in UTC.
- Output is formatted for Promtail log ingestion.

### Integration with Other Resources

Other server resources can submit structured log entries with the `SubmitLog` export:

```lua
exports['ravn-logs']:SubmitLog('custom_event', { key = 'value' })

## Known Limitations:

### Car Explosion Coordinates:
Explosion Event logs for explosion type "Car Explosion" display inaccurate coordinates.
- This is a limitation of the game engine and does not have a perfect solution

### Vehicle Kill Edge Case: 
If a player is hit by an NPC vehicle and killed instantly, the death may sometimes log as an environmental death.
- This logger will store the last damage delt to the player, if a player is killed by a vehicle, sometimes the last damage tick will be from bleed thus overwriting the vehicle damage. I have spent an enormous amount of time on this and have yet to find a reliable solution. 

### Weapon Fire Log Edge Case:
If a player holds a granade until detonation, the weapon fired log reports the weapon as the Weapon_Unarmed hash.
- This occurs because the game engine reports the weapon hash as -1569615261 which is Weapon_Unarmed. I have yet to find a reliable solution.

## License
Ravn Logs is licensed under the GNU General Public License v3 (GPLv3).  
See the LICENSE file for details: ravn-logs/LICENSE.txt

This project is open source. If you redistribute it, you must comply with the GPLv3 license, including providing source code.

# Installation Guide:
To install and configure Ravn Logs for first time use, follow these steps:

1. Click the green "Code" button in the top right of the Github repository page (https://github.com/Ravn-dev/ravn-logs) for this project, then click Download ZIP. Alternatively you can clone the respoitory with the web URL (https://github.com/Ravn-dev/ravn-logs.git) directly to your FiveM server resource folder.

2. Extract all files from the .ZIP to your FiveM server resource folder. If you chose to clone the respository, you can skip this step.

3. Edit `ravn-logs/config.lua` to choose which log types and output sinks to enable. NDJSON and Discord are enabled by default; database storage is disabled by default.

4. To send logs to Discord, replace the placeholder URLs in the `DISCORD_WEBHOOKS` table in `ravn-logs/server/discord.lua`. Configure each log type with the webhook you want it to use. To disable Discord delivery entirely, set `Config.Sinks.discord = false`.

    4a. Obtain your Discord webhook url. 
    Here is a resource to help you create a Discord webhook url: https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks  
    **NOTE: NEVER SHARE YOUR DISCORD WEBHOOK URL WITH ANYONE.**

    4b. Navigate to ravn-logs/server/discord.lua, then paste the Discord webhook url into lines 5 though 15. (This step is REQUIRED for Discord logging to function)

    4c. Then on line 22, replace `"SET DISCORD WEBHOOK URL HERE"` with your Discord webhook url. (This step is REQUIRED for Discord logging to function)
	
    4d. Save the discord.lua file after you have made the changes from steps 4b and 4c.

5. To enable database logging and the in game viewer: [Required for ingame log viewer to work]
   5a. Install and start oxmysql before ravn-logs.
   5b. Set `Config.Sinks.database = true` in `config.lua`.
   5c. Configure `Config.LogViewer`. The viewer opens with `/ravnlogs`.
   5d. For ACE access, grant the configured permission, for example: `add_ace group.admin ravnlogs.view allow`.
   5e. For Discord role access, configure the guild and role IDs and set the bot token as a server-only convar, for example: `set ravn_logs_discord_bot_token "YOUR_BOT_TOKEN"`. Do not use `setr`.

    Note: If you change the in game menu’s files in web/src, rebuild the menu before starting the server. Open a terminal in the ravn-logs folder and run:
    `pnpm install`
    `pnpm build`

6. Add the `ensure ravn-logs` line in your server.cfg file. If a database is configured, make sure `ensure oxmysql` appears before `ensure ravn-logs`.

6. Start your server, With NDJSON enabled, if you see the following lines in the live console: 

    `       [resources] Started resource ravn-logs` 
    `[script:ravn-logs] [ravn-logs] Logging to logs/server-yyyymmdd.ndjson`

You are all set.

### TIPs:
- You can locate logs written to the NDJSON file by navigating to ravn-logs/logs
- NDJSON file retention is by default set to 7 days in the config.lua, no need to manually delete NDJSON files.
- A new NDJSON file is created everyday at midnight server time.
- If you manually delete the current NDJSON file the resource is writing to, you must either, restart the resource or restart the server for a new NDJSON file to be generated.

### Useful Reference Docs
- Discord API Rate Limits: https://docs.discord.com/developers/topics/rate-limits

## Support the Project
If you find this resource useful and would like to support me in my development endeavours, 
you can buy me a coffee! 

https://ko-fi.com/ravndev

Support is optional and greatly appreciated.

## Help & Troubleshooting
- Ask questions or get help troubleshooting Ravn Logs in the Github repository [Discussions](https://github.com/Ravn-dev/ravn-logs/discussions/categories/q-a).
- NOTE: Support is limited to issues directly related to Ravn Logs. Issues with third-party resources should be directed to their respective developer.

## Contributing & Feedback
Community contributions are welcomed and appreciated!

### Ways to Contribute:
- Report bugs through [Issues](https://github.com/Ravn-dev/ravn-logs/issues).
- Suggest new features or improvements in [Discussions](https://github.com/Ravn-dev/ravn-logs/discussions/categories/ideas-feedback).
- Submit Pull Requests for bug fixes or enhancements.

### Before submitting a Pull Request:
- Match the existing code style, naming conventions, and file structure to keep the project consistent and maintainable.
- Keep changes focused on a single feature, fix, or improvement, and include a clear description of what was changed and why.
- Test your changes to ensure they work as expected and do not introduce new issues.

IMPORTANT: Pull Requests must be submitted to the Ravn Logs `dev` branch. Any PRs made against `main` will be closed.

## Project Inspiration
The Ravn Logs project started when I encountered a problem. I wanted to use Grafana to create a dashboard displaying all of my Qbox server data. After some research I found that I could use Promtail to scrape the data, then ship the data to Grafana using Loki. There was one issue, how am I going to generate the data I want to use? Thus starting a 3 month journey of learning, building and many cups of coffee resulting in the Ravn Logs project. From the beginning I intended this resource to be open source and free to use for anyone wanting to be able to obtain insights into how their players are interacting with the GTA world. While building Ravn Logs, I kept roleplay as the focus when developing the logic for the logs so server owners and moderators can know exactly what happened and have the crucial data they need when handling incidents. 

## Changelog History:
For a full history of changes prior to v0.9.0, see ravn-logs/changelog.md
