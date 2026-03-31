const express = require('express');
const cors = require('cors');
const pool = require('./db');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const app = express();
app.use(cors());
app.use(express.json());

// --- CONFIGURAÇÃO DO SWAGGER ---
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Sistema de Gerenciamento de Usuários (DEBUG MODE)',
      version: '1.2.0',
      description: 'API Node.js - Verifique o terminal do VS Code para logs do banco',
    },
    paths: {
      '/users': {
        get: {
          summary: 'Lista todos os usuários',
          responses: { 200: { description: 'Sucesso' } }
        },
        post: {
          summary: 'Cria um novo usuário',
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    nome: { type: 'string', example: 'Felipe' },
                    email: { type: 'string', example: 'felipe@teste.com' }
                  }
                }
              }
            }
          },
          responses: { 201: { description: 'Criado' } }
        }
      },
      '/users/{id}': {
        put: {
          summary: 'Atualiza um usuário',
          parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    nome: { type: 'string' },
                    email: { type: 'string' }
                  }
                }
              }
            }
          },
          responses: { 200: { description: 'Atualizado' } }
        },
        delete: {
          summary: 'Deleta um usuário',
          parameters: [{ name: 'id', in: 'path', required: true, schema: { type: 'integer' } }],
          responses: { 200: { description: 'Removido' } }
        }
      }
    }
  },
  apis: [], 
};

const specs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// --- ROTAS DA API COM LOGS DE TESTE ---

// CREATE
app.post('/users', async (req, res) => {
  const { nome, email } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO users (nome, email) VALUES ($1, $2) RETURNING *',
      [nome, email]
    );
    console.log("📥 NOVO USUÁRIO CRIADO:", result.rows[0]);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("❌ ERRO NO POST:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ (Com teste de Console)
app.get('/users', async (req, res) => {
  try {
    console.log("🔍 BUSCANDO USUÁRIOS NO BANCO...");
    const result = await pool.query('SELECT * FROM users ORDER BY id ASC');
    
    // ESTE LOG É O MAIS IMPORTANTE:
    console.log("📊 QUANTIDADE ENCONTRADA NO BANCO:", result.rows.length);
    console.log("📝 LISTA DE DADOS:", result.rows);
    
    res.json(result.rows);
  } catch (err) {
    console.error("❌ ERRO NO GET:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE
app.put('/users/:id', async (req, res) => {
  const { id } = req.params;
  const { nome, email } = req.body;
  try {
    const result = await pool.query(
      'UPDATE users SET nome = $1, email = $2 WHERE id = $3 RETURNING *',
      [nome, email, id]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: "Não encontrado" });
    console.log(`🆙 USUÁRIO ${id} ATUALIZADO`);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE
app.delete('/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM users WHERE id = $1 RETURNING *', [id]);
    if (result.rowCount === 0) return res.status(404).json({ error: "Não encontrado" });
    console.log(`🗑️ USUÁRIO ${id} REMOVIDO`);
    res.json({ message: "Usuário removido!" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// --- INICIALIZAÇÃO ---
async function startApp() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        nome VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL
      );
    `);
    console.log("✅ BANCO CONECTADO E TABELA PRONTA.");
  } catch (err) {
    console.error("❌ ERRO AO INICIAR BANCO:", err.message);
  }
  app.listen(3000, () => {
    console.log('🚀 Servidor rodando em http://localhost:3000');
    console.log('📖 Documentação: http://localhost:3000/api-docs');
  });
}

startApp();