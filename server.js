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

app.use(express.json());
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


app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 Our Planner Server Running`);
    console.log(`📍 Port: ${PORT}`);
    console.log(`💾 Data: ${DATA_FILE}\n`);
});
