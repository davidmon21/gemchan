CREATE TABLE boards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    upath TEXT,
    name TEXT,
    number_threads INTEGER,
    description TEXT
);
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT,
    password_hash BLOB,
    perms INTEGER
);
CREATE TABLE ops (
    post_id INTEGER,
    number_posts INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject TEXT,
    name TEXT,
    content TEXT,
    media TEXT,
    op_id      INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    board_id      INTEGER NOT NULL,
    FOREIGN KEY (board_id)
       REFERENCES boards (id)
);
CREATE TABLE newsposts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject TEXT,
    name TEXT,
    content TEXT,
    media TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
.exit

