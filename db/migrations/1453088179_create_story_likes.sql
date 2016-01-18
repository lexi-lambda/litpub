CREATE TABLE story_likes (
  id serial NOT NULL,
  story_id integer NOT NULL REFERENCES stories ON DELETE CASCADE,
  ip inet NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id),
  UNIQUE (story_id, ip)
);
