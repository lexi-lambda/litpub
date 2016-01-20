CREATE TABLE user_feedback (
  id serial NOT NULL,
  ip inet NOT NULL,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id)
);
