# ATM11 Server Installer

Professional automated server installer for **All The Mods 11 (ATM11)** - optimized for Crafty Controller on Linux.

**Best of both worlds:** FTB's polish + lightweight scriptable design

## Features

- ✅ **Interactive version selection** with pretty UI
- ✅ **Java 21+ validation** (prevents runtime errors)
- ✅ **Colored output** with progress indicators
- ✅ **Automated CurseForge downloads** with fallback
- ✅ **Automatic backup** of old configurations
- ✅ **Auto-accept EULA** for headless setup
- ✅ **Startup script** with JVM optimization
- ✅ **Version tracking** (installed vs latest)
- ✅ **Manual update triggers** (no auto-updates)
- ✅ **Crafty Controller integration**
- ✅ **Scriptable/automation-friendly** (CLI flags)

## Requirements

**Linux system with:**
- `bash`
- `curl`
- `unzip`
- **Java 21+** (installer validates this)

## Quick Start

### 1. Clone/Download this installer
```bash
cd /path/to/your/servers
git clone https://github.com/henkoe/atm11-installer.git
cd atm11-installer
chmod +x *.sh
```

### 2. Run the interactive installer
```bash
./install.sh
```

**Interactive mode:**
```
╔════════════════════════════════════════╗
║     ATM11 Server Installer             ║
╚════════════════════════════════════════╝

✓ All prerequisites found
✓ Java 21.0.1 detected
ℹ Fetching available versions from CurseForge...

ℹ Available ATM11 versions:
  1) 26.2.0 (latest)
  2) 26.1.2
  3) 26.1.1

Select version (default 1): 1
✓ Selected version: 26.2.0
✓ Downloaded
✓ Backed up to backup-1719244800/
✓ Extracted
✓ Created server.properties
✓ Created start.sh
✓ EULA accepted
✓ Version saved

✓ Installation Complete!
```

This automatically:
- ✓ Validates Java 21+ installed
- ✓ Lists all available versions
- ✓ Downloads selected version
- ✓ Backs up old files
- ✓ Sets up server.properties
- ✓ Auto-accepts EULA
- ✓ Creates startup script

### 3. Customize configuration
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

## Usage Modes

### Interactive (default)
For manual setup with version selection:
```bash
./install.sh
```

### Non-interactive (automation/CI)
For scripting or CI/CD pipelines:
```bash
INTERACTIVE=false VERSION_SELECT=26.1.2 ./install.sh
```

Or specify version as argument:
```bash
./install.sh 26.1.2
```

### Simple wrapper
One-command install with auto-detection:
```bash
./install-simple.sh
```

## Version Management

### Check installed version
```bash
./get-version.sh
# ✓ Installed ATM11 version: v26.1.2
```

Or view the file directly:
```bash
cat version.txt
```

### Check for available updates
```bash
./check-updates.sh
```

Output:
```
╔════════════════════════════════════════╗
║     ATM11 Update Checker               ║
╚════════════════════════════════════════╝

✓ Currently installed: v26.1.2
ℹ Checking CurseForge for latest version...
✓ Latest available:    v26.2.0

⚠ Update available!

To update to v26.2.0, run:
  ./update.sh
```

### Update to latest version
```bash
./update.sh
```

Automatically:
- ✓ Shows current vs latest version
- ✓ Skips if already up-to-date
- ✓ Stops server gracefully (if using systemd)
- ✓ Downloads new version
- ✓ Backs up old files
- ✓ Updates version.txt

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
