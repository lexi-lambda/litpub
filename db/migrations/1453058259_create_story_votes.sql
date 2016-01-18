CREATE TYPE binary_vote AS ENUM ('up', 'down');

CREATE TABLE story_votes (
  id serial NOT NULL,
  story_id integer NOT NULL REFERENCES stories,
  ip inet NOT NULL,
  value binary_vote NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id),
  UNIQUE (story_id, ip)
);
