# Projeto Full Stack - Gerenciamento de Usuários

Este repositório contém uma aplicação completa (CRUD) desenvolvida para integrar um Backend em Node.js, um Banco de Dados PostgreSQL (via Docker) e um Frontend em Flutter Web.

## Tecnologias e Dependências

### **Backend (Node.js)**
- **Express:** Framework para rotas e middleware.
- **pg (node-postgres):** Driver de conexão com o PostgreSQL.
- **cors:** Permite que o Flutter Web acesse a API.
- **swagger-ui-express & swagger-jsdoc:** Documentação interativa da API.
- **Docker & Docker Compose:** Containerização do banco de dados.

### **Frontend (Flutter)**
- **http:** Pacote para consumo de APIs REST.
- **Material Design 3:** Interface moderna e responsiva.

---

## Arquitetura e Fluxo de Dados

O sistema funciona através de uma arquitetura de microserviços local:
1. **Docker** sobe o banco de dados PostgreSQL na porta `5432`.
2. **Node.js** conecta no banco e disponibiliza a API na porta `3000`.
3. **Flutter Web** consome a API através de requisições HTTP (GET, POST, PUT, DELETE).

---

## Como Executar o Projeto

### 1. Preparar o Banco (Docker)
Dentro da pasta do backend, execute o comando abaixo para subir o container:
```bash
docker compose up -d
2. Iniciar o Servidor (Backend)
Ainda na pasta do backend, instale as dependências e inicie o serviço:

Bash
npm install
npm run dev
Acesse a documentação Swagger em: http://localhost:3000/api-docs

3. Iniciar o Aplicativo (Frontend)
Abra um novo terminal na pasta do projeto Flutter e execute:

Bash
flutter pub get
flutter run -d chrome

Funcionalidades Implementadas
[x] Cadastro de Usuário (POST): Envio de nome e e-mail via formulário.

[x] Listagem de Usuários (GET): Exibição dinâmica de dados do banco.

[x] Atualização (PUT): Rota para editar informações de usuários.

[x] Exclusão (DELETE): Rota para remover registros do sistema.

[x] Tratamento de CORS: Integração total entre Web e API.

Desenvolvido por: Felipe Salazar 