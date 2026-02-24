const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
const usersRoutes = require('./routes/users');
app.use('/api/users', usersRoutes);

// Health Check
app.get('/', (req, res) => {
    res.send('Backend API Running');
});

// Start Server with Retry Logic
const startServer = async () => {
    try {
        const db = require('./db');
        const connection = await db.getConnection();
        console.log('Database connected successfully');
        connection.release();

        app.listen(port, () => {
            console.log(`Server running on port ${port}`);
        });
    } catch (err) {
        console.error('Database connection failed:', err.message);

        // If database doesn't exist, try to create it
        if (err.code === 'ER_BAD_DB_ERROR') {
            console.log('Database does not exist. Attempting to create...');
            try {
                const mysql = require('mysql2/promise');
                const tempConnection = await mysql.createConnection({
                    host: process.env.DB_HOST || 'localhost',
                    user: process.env.DB_USER || 'root',
                    password: process.env.DB_PASSWORD || '',
                });
                await tempConnection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'my_app_db'}\``);
                console.log('Database created successfully');
                await tempConnection.end();
                // Retry immediately
                return startServer();
            } catch (createErr) {
                console.error('Failed to create database:', createErr.message);
            }
        }

        console.log('Retrying in 5 seconds...');
        setTimeout(startServer, 5000);
    }
};

startServer();
