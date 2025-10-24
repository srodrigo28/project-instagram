-- =====================================================
-- 🧍‍♀️ 1. Tabela de Usuários
-- =====================================================
CREATE TABLE users (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY, -- Usando bigint para escalabilidade
  username TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() -- Usando timestamp com fuso horário
);

-- =====================================================
-- 🖼️ 2. Tabela de Posts
-- Um usuário pode ter vários posts.
-- =====================================================
CREATE TABLE posts (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE, -- Usando bigint para consistência
  image_url TEXT NOT NULL,
  caption TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ❤️ 3. Tabela de Likes (curtidas)
-- Relacionamento N:N entre users e posts.
-- PRIMARY KEY dupla impede duplicação de curtida.
-- =====================================================
CREATE TABLE likes (
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

-- =====================================================
-- 💬 4. Tabela de Comentários
-- Um comentário pertence a um post e a um usuário.
-- =====================================================
CREATE TABLE comments (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 📊 5. View para contar likes e comentários por post
-- Usando agregações COUNT() para mostrar métricas.
-- =====================================================
CREATE VIEW post_stats AS
SELECT
  p.id AS post_id,
  p.caption,
  p.image_url,
  p.user_id,
  COUNT(DISTINCT l.user_id) AS total_likes,
  COUNT(DISTINCT c.id) AS total_comments
FROM posts p
LEFT JOIN likes l ON l.post_id = p.id
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id, p.caption, p.image_url, p.user_id;

-- =====================================================
-- 📈 6. Exemplos de inserção de dados
-- =====================================================
INSERT INTO users (username) VALUES
  ('ana_dev'),
  ('joao_js'),
  ('maria_sql');

INSERT INTO posts (user_id, image_url, caption) VALUES
  (1, 'https://picsum.photos/200', 'Meu primeiro post!'),
  (2, 'https://picsum.photos/201', 'Aprendendo Supabase!'),
  (3, 'https://picsum.photos/202', 'SQL é top!');

INSERT INTO likes (user_id, post_id) VALUES
  (1, 2),
  (2, 1),
  (3, 1),
  (1, 3);

INSERT INTO comments (user_id, post_id, content) VALUES
  (2, 1, 'Show!'),
  (3, 1, '👏👏'),
  (1, 2, 'Muito bom!');

-- =====================================================
-- 🔍 7. Consultas úteis
-- =====================================================

-- 7.1. Feed com autor, legenda e contadores
SELECT
  p.id,
  u.username AS author,
  p.caption,
  ps.total_likes,
  ps.total_comments
FROM posts p
JOIN users u ON u.id = p.user_id
JOIN post_stats ps ON ps.post_id = p.id
ORDER BY p.created_at DESC;

-- 7.2. Ver quem curtiu um post
SELECT u.username
FROM likes l
JOIN users u ON u.id = l.user_id
WHERE l.post_id = 1;

-- 7.3. Ver comentários de um post
SELECT u.username, c.content
FROM comments c
JOIN users u ON u.id = c.user_id
WHERE c.post_id = 1
ORDER BY c.created_at;
