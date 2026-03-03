# Ravn Logs

Ravn Logs is an open source FiveM logging resource for tracking player activity and server events. It helps server owners and admins see what’s happening in the game, whether for moderation or development.

## Creator: Ravn
https://github.com/Ravn-dev

## GitHub Repository:
https://github.com/Ravn-dev/ravn-logs

## Version:
v0.9.0
- Initial public beta release of Ravn Logs

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

### Discord Integration
- Ability to configure discord webhooks for Discord logging
- Built in safeguards to prevent Discord API rate limits and errors.

### NDJSON Logging
- Ability to log to NDJSON file locally within the resource folder.
- Configurable log file retention and automatic file cleanup.
- Each log timestamped in the ISO format (UTC).
- Intended to allow for Promtail data scraping.

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
See the LICENSE file for details: ravn_logs/LICENSE.txt`

This project is open source. If you redistribute it, you must comply with the GPLv3 license, including providing source code.

# Installation Guide:
To install and configure Ravn Logs for first time use, follow these steps:

1. Click the green "Code" botton in the top right of the Github page (https://github.com/Ravn-dev/ravn-logs) for this project, then click Download ZIP. Alternatively you can clone the respoitory with the web URL (https://github.com/Ravn-dev/ravn-logs.git) directly to your FiveM server resource folder.

2. Extract all files from the .ZIP to your FiveM server resource folder. If you chose to clone the respository, you can skip this step.

3. Within your FiveM server resource folder, navigate to ravn_logs/config.lua. Here you will set which logs you would like to collect. NOTE: Discord Logging is enabled by default.

4. If you wish to use the Discord logging function, you must set a Discord webhook url. (If you do not wish to use Discord logging, set all lines (73-83) under Config.DiscordLogs to false)

    4a. Obtain your Discord webhook url. Here is a resource to help you create a Discord webhook url: https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks  
    **NOTE: NEVER SHARE YOUR DISCORD WEBHOOK URL WITH ANYONE.**

    4b. Navigate to ravn_logs/server/discord.lua, then paste the Discord webhook url into lines 5 though 15. (This step is REQUIRED for Discord logging to function)

    4c. Then on line 22, replace `"SET DISCORD WEBHOOK URL HERE"` with your Discord webhook url. (This step is REQUIRED for Discord logging to function)
	
    4d. Save the discord.lua file after you have made the changes from steps 4b and 4c.

5. Add the `ensure ravn-logs` line in your server.cfg file.

6. Start your server, if you see the following lines in the live console: 
    `[           resources] Started resource ravn_logs`
    `[    script:ravn_logs] [ravn-logs] Logging to logs/server-yyyymmdd.ndjson`

You are all set.

### TIPs:
- You can locate logs written to the NDJSON file by navigating to ravn_logs/logs
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

## Contributing & Feedback
Community contributions are encouraged and appreciated.

### Ways to Contribute:
- Report bugs via Issues
- Suggest new features or improvements
- Submit Pull Requests for fixes or enhancements

### Before submitting a Pull Request:
- Match the existing code style, naming conventions, and file structure to keep the project consistent and maintainable
- Keep changes focused on a single feature, fix, or improvement, and include a clear description of what was changed and why.
- Test your changes to ensure they work as expected and do not introduce new issues

## Project Inspiration
The Ravn Logs project started when I encountered a problem. I wanted to use Grafana to create a dashboard displaying all of my Qbox server data. After some research I found that I could use Promtail to scrape the data, then ship the data to Grafana using Loki. There was one issue, how am I going to generate the data I want to use? Thus starting a 3 month journey of learning, building and many cups of coffee resulting in the Ravn Logs project. From the beginning I intended this resource to be open source and free to use for anyone wanting to be able to obtain insights into how their players are interacting with the GTA world. While building Ravn Logs, I kept roleplay as the focus when developing the logic for the logs so server owners and moderators can know exactly what happened and have the crucial data they need when handling incidents. 

## Changelog History:
For a full history of changes prior to v0.9.0, see ravnlogs/changelog.md