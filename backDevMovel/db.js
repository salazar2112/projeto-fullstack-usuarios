const { Pool } = require('pg');

const pool = new Pool({
  user: 'user_admin',
  host: 'localhost',
  database: 'user_management',
  password: 'password123',
  port: 5432,
});

module.exports = pool;