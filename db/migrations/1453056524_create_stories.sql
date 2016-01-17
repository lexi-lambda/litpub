CREATE TABLE stories (
  id serial NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  draft boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (id)
);
