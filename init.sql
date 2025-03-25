CREATE SCHEMA api;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Users Table
CREATE TABLE api.users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts Table
CREATE TABLE api.posts (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid(),
    user_id INT REFERENCES api.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE api.categories (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255)
);

-- Many-to-Many: Posts & Categories
CREATE TABLE api.post_categories (
    post_id INT REFERENCES api.posts(id) ON DELETE CASCADE,
    category_id INT REFERENCES api.categories(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, category_id)
);

-- Comments Table
CREATE TABLE api.comments (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT gen_random_uuid(),
    post_id INT REFERENCES api.posts(id) ON DELETE CASCADE,
    user_id INT REFERENCES api.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO api.users (username, email, password_hash) VALUES
('johndoe', 'john@example.com', 'hashedpassword123'),
('janedoe', 'jane@example.com', 'hashedpassword456');

INSERT INTO api.categories (name, description) VALUES
('Tech', 'Technology news and articles'),
('Lifestyle', 'Daily life and wellness');

INSERT INTO api.posts (user_id, title, content) VALUES
(1, 'First Post', 'This is the content of the first blog post.'),
(2, 'Second Post', 'Another post with some interesting content.');

INSERT INTO api.post_categories (post_id, category_id) VALUES
(1, 1), (2, 2);

INSERT INTO api.comments (post_id, user_id, content) VALUES
(1, 2, 'Great post!'),
(2, 1, 'Interesting thoughts.');

-- Permissions
CREATE ROLE web_anon NOLOGIN;
GRANT USAGE ON SCHEMA api TO web_anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON api.posts, api.categories, api.users, api.comments TO web_anon;
GRANT USAGE ON SEQUENCE api.posts_id_seq, api.users_id_seq, api.categories_id_seq, api.comments_id_seq TO web_anon;

CREATE ROLE authenticator NOLOGIN;
GRANT web_anon TO authenticator;
