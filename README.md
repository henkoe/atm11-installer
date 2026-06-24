# ATM11 Server Installer

Automated server installer for **All The Mods 11 (ATM11)** - configurable for Crafty Controller on Linux.

## Features

- ✅ Automated download of latest ATM11 ServerFiles from CurseForge
- ✅ Automatic backup of old configurations
- ✅ Auto-accept EULA for headless setup
- ✅ Startup script with configurable JVM args (NeoForge)
- ✅ Manual trigger updates (no auto-updates)
- ✅ Crafty Controller compatible

## Requirements

**Linux system with:**
- `bash`
- `curl`
- `unzip`
- Java 21+ (for running the server)

## Quick Start

### 1. Clone/Download this installer
```bash
cd /path/to/your/servers
git clone <repo-url> atm11-installer
cd atm11-installer
```

### 2. Run the installer
```bash
./install.sh
```

This will:
- Download latest ATM11 ServerFiles
- Extract to current directory
- Backup old files to `backup-<timestamp>/`
- Create `server.properties` with defaults
- Auto-accept EULA (`eula.txt`)
- Generate `start.sh` startup script

### 3. Customize configuration
Edit `server.properties`:
```bash
nano server.properties
```

Common settings:
- `max-players=20` - player limit
- `difficulty=2` - 0=peaceful, 1=easy, 2=normal, 3=hard
- `view-distance=10` - chunk render distance
- `server-port=25565` - port

### 4. Start the server
```bash
./start.sh
```

Or add to Crafty Controller and manage via web UI.

## Checking for Updates

To see if updates are available:
```bash
./check-updates.sh
```

This shows:
- Currently installed version
- Latest available version
- Whether you need to update

## Updating

To update to a new ATM11 version:
```bash
./update.sh
```

This will:
- Show currently installed vs latest version
- Skip update if already on latest
- Backup current world/configs
- Download latest ServerFiles
- Extract new mods/configs
- Preserve `server.properties`
- Update version file

## Integration with Crafty Controller

1. Add your server directory as a new server in Crafty
2. Set startup command to: `./start.sh`
3. Crafty will handle logging, backups, player management
4. Use `./update.sh` to manually trigger version updates

## Manual Updates via Crafty

Alternatively, directly update through Crafty's file manager:
1. Upload new `ServerFiles-X.X.X.zip` to server directory
2. Extract it (will overwrite mods/config)
3. Restart server

## Troubleshooting

### Server won't start
- Check Java version: `java -version` (need 21+)
- Increase RAM in `start.sh`: change `-Xmx6G` to `-Xmx8G` etc.
- Check server logs: `tail -f logs/latest.log`

### Download fails
- Check CurseForge is reachable
- Manual download: Visit [ATM11 on CurseForge](https://www.curseforge.com/minecraft/modpacks/all-the-mods-11)
- Download `ServerFiles-X.X.X.zip` and run `unzip` manually

### Crafty won't recognize server
- Ensure `eula.txt` exists with `eula=true`
- Check file permissions: `chmod +x start.sh`
- Verify Java is in PATH: `which java`

## Configuration

### JVM Arguments
Edit `start.sh` to tune performance:
```bash
JVM_ARGS="-Xmx6G -Xms6G -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

- `-Xmx6G` - Max RAM (adjust for your server)
- `-Xms6G` - Min RAM (should match -Xmx)
- `-XX:+UseG1GC` - Garbage collector for better performance

### Server Properties Reference

Full reference: [Minecraft Server Properties](https://minecraft.wiki/w/Server.properties)

Key settings for ATM11:
```properties
server-port=25565          # Port (default 25565)
max-players=20             # Player limit
difficulty=2               # 0-3 (peaceful to hard)
gamemode=0                 # 0=survival, 1=creative, 3=adventure
view-distance=10           # Chunks rendered (6-32)
enable-rcon=false          # Remote console (security risk if enabled)
spawn-protection=16        # Spawn area protection radius
```

## Directory Structure

After installation:
```
.
├── mods/                  # Modpack mods (regenerated on update)
├── config/                # Mod configurations
├── world/                 # Server world save
├── logs/                  # Server logs
├── server.properties      # Server configuration (preserved on update)
├── version.txt           # Currently installed version (auto-updated)
├── eula.txt              # EULA acceptance
├── start.sh              # Startup script
├── install.sh            # This installer
├── update.sh             # Update script
├── check-updates.sh      # Check for available updates
└── backup-<timestamp>/   # Backups from previous versions
```

## Development & Contributing

To improve this installer:
1. Test on clean Linux systems
2. Update download logic if CurseForge changes
3. Add support for other platforms if needed

## License

Public domain - use freely.

## Support

Issues? Check:
1. ATM11 Official: https://www.curseforge.com/minecraft/modpacks/all-the-mods-11
2. Crafty Controller: https://gitlab.com/crafty-controller/crafty-4
3. NeoForge: https://neoforged.net
