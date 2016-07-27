DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,

  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_id INTEGER,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Yasin', 'Hosseinpur'),
  ('Davin', 'Kim');



INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Why?', 'Why am I doing this?', (SELECT id FROM users WHERE fname = 'Yasin')),
  ('What?', 'What am I doing?', (SELECT id FROM users WHERE fname = 'Davin'));



INSERT INTO
  question_follows(question_id, follower_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'What?'), (SELECT id FROM users WHERE fname = 'Yasin')),
  ((SELECT id FROM questions WHERE title = 'Why?'), (SELECT id FROM users WHERE fname = 'Davin'));



INSERT INTO
  replies(question_id, user_id, body, parent_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Why?'),
    (SELECT id FROM users WHERE fname = 'Davin'),
    'I don''t know.', NULL
  ),
  ((SELECT id FROM questions WHERE title = 'Why?'),
    (SELECT id FROM users WHERE fname = 'Yasin'),
    'You should know.', 1
  );



INSERT INTO
  question_likes(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Why?'), (SELECT id FROM users WHERE fname = 'Davin')),
  ((SELECT id FROM questions WHERE title = 'What?'), (SELECT id FROM users WHERE fname = 'Yasin'));
