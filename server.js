const express = require('express');
const fs = require('fs');
const path = require('path');
const os = require('os');
const app = express();
const PORT = 49210;

const DATA_DIR = path.join(__dirname, 'data');
const DATA_FILE = path.join(DATA_DIR, 'planner_data.json');
const BACKUP_DIR = path.join(DATA_DIR, 'backups');

// Ensure directories exist
if (!fs.existsSync(DATA_DIR)) fs.mkdirSync(DATA_DIR);
if (!fs.existsSync(BACKUP_DIR)) fs.mkdirSync(BACKUP_DIR);

app.use(express.json({ limit: '10mb' }));
app.use(express.static(__dirname));

// Initialize data if not exists
if (!fs.existsSync(DATA_FILE)) {
    const initialData = { 
        tasks: [], 
        categories: [
            { name: 'Personal', color: '#8b5cf6' },
            { name: 'Work', color: '#ef4444' },
            { name: 'Home', color: '#10b981' }
        ] 
    };
    fs.writeFileSync(DATA_FILE, JSON.stringify(initialData, null, 2));
}

// Get all data
app.get('/api/data', (req, res) => {
    try {
        const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
        res.json(data);
    } catch (err) {
        console.error('Read Error:', err);
        res.status(500).json({ error: 'Failed to read data' });
    }
});

// Save all data with automatic backups
app.post('/api/data', (req, res) => {
    try {
        const dataStr = JSON.stringify(req.body, null, 2);
        
        // Save main file
        fs.writeFileSync(DATA_FILE, dataStr);
        
        // Create a rotating backup (keep last 5)
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
        const backupFile = path.join(BACKUP_DIR, `backup-${timestamp}.json`);
        fs.writeFileSync(backupFile, dataStr);
        
        const backups = fs.readdirSync(BACKUP_DIR).sort();
        if (backups.length > 5) {
            fs.unlinkSync(path.join(BACKUP_DIR, backups[0]));
        }

        res.json({ success: true });
    } catch (err) {
        console.error('Save Error:', err);
        res.status(500).json({ error: 'Failed to save data' });
    }
});

// Upload and replace app icon
app.post('/api/upload-icon', (req, res) => {
    try {
        const { image } = req.body;
        if (!image) return res.status(400).json({ error: 'Nihče ni poslal slike' });

        // More robust base64 parsing (handles various data URL formats)
        const base64Parts = image.split(';base64,');
        const base64Data = base64Parts.length > 1 ? base64Parts[1] : base64Parts[0];
        const buffer = Buffer.from(base64Data, 'base64');
        
        // Ensure we are writing to the correct path
        const iconPath = path.join(__dirname, 'icon.png');
        fs.writeFileSync(iconPath, buffer);

        // Update manifest with cache bust
        const manifestPath = path.join(__dirname, 'manifest.json');
        if (fs.existsSync(manifestPath)) {
            try {
                let manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
                const v = Date.now();
                if (manifest.icons) {
                    manifest.icons.forEach(ico => {
                        ico.src = ico.src.split('?')[0] + '?v=' + v;
                    });
                }
                fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
            } catch (manifestErr) {
                console.error('Manifest Update Error:', manifestErr);
                // We still succeed icon upload even if manifest update fails
            }
        }

        res.json({ success: true });
    } catch (err) {
        console.error('Upload Error:', err);
        res.status(500).json({ error: 'Napaka na strežniku: ' + err.message });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 Our Planner Server Running`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`💾 Data: ${DATA_FILE}\n`);
});
