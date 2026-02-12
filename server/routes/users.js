const express = require('express');
const router = express.Router();
const db = require('../db');

// POST - Create a new user
router.post('/', async (req, res) => {
    const { first_name, last_name, age, email, phone_number } = req.body;

    if (!first_name || !last_name || !email) {
        return res.status(400).json({ error: 'Missing required fields: first_name, last_name, or email' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO users (first_name, last_name, age, email, phone_number) VALUES (?, ?, ?, ?, ?)',
            [first_name, last_name, age, email, phone_number]
        );

        res.status(201).json({ id: result.insertId, message: 'User created successfully' });
    } catch (err) {
        console.error('Error creating user:', err);
        res.status(500).json({ error: 'Database error while creating user' });
    }
});

// GET - Retrieve all users
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM users ORDER BY id DESC');
        res.json(rows);
    } catch (err) {
        console.error('Error fetching users:', err);
        res.status(500).json({ error: 'Database error while retrieving users' });
    }
});

module.exports = router;
