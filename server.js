const express = require('express');
const fs = require('fs');
const path = require('path');
const os = require('os');
const app = express();
const PORT = 49210;

const DATA_FILE = path.join(__dirname, 'data.json');

app.use(express.json());
app.use(express.static(__dirname));

// Ensure data file exists
if (!fs.existsSync(DATA_FILE)) {
    fs.writeFileSync(DATA_FILE, JSON.stringify({ tasks: [], categories: [
        { name: 'Personal', color: '#8b5cf6' },
        { name: 'Work', color: '#ef4444' },
        { name: 'Urgent', color: '#10b981' }
    ] }, null, 2));
}

// Get all data
app.get('/api/data', (req, res) => {
    try {
        const data = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
        res.json(data);
    } catch (err) {
        res.status(500).json({ error: 'Failed to read data' });
    }
});

// Save all data
app.post('/api/data', (req, res) => {
    try {
        fs.writeFileSync(DATA_FILE, JSON.stringify(req.body, null, 2));
        res.json({ success: true });
    } catch (err) {
        res.status(500).json({ error: 'Failed to save data' });
    }
});

// System Stats Endpoint
app.get('/api/stats', (req, res) => {
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;
    
    // CPU usage is complex for a one-shot, but we can give load average as a proxy
    const loadAvg = os.loadavg(); 
    
    res.json({
        ram: {
            total: (totalMem / 1024 / 1024 / 1024).toFixed(2) + ' GB',
            used: (usedMem / 1024 / 1024 / 1024).toFixed(2) + ' GB',
            percent: ((usedMem / totalMem) * 100).toFixed(0) + '%'
        },
        cpu: {
            load: loadAvg[0].toFixed(2), // 1 minute load average
            model: os.cpus()[0].model,
            cores: os.cpus().length
        },
        uptime: (os.uptime() / 3600).toFixed(1) + ' hours'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Our Planner Server running on port ${PORT}`);
});
