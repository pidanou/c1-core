CREATE TABLE connectors (
  name TEXT PRIMARY KEY NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  source TEXT NOT NULL DEFAULT '',
  uri TEXT NOT NULL DEFAULT '',
  install_command TEXT NOT NULL DEFAULT '',
  update_command TEXT NOT NULL DEFAULT '',
  command TEXT NOT NULL
);

CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  connector TEXT NOT NULL REFERENCES connectors (name) ON DELETE SET NULL,
  name TEXT NOT NULL DEFAULT '',
  options TEXT NOT NULL DEFAULT '{}'
);

CREATE TABLE data (
  id SERIAL PRIMARY KEY,
  account_id INTEGER NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
  remote_id TEXT NOT NULL DEFAULT '',
  resource_name TEXT NOT NULL DEFAULT '',
  uri TEXT NOT NULL DEFAULT '',
  metadata TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  last_synced_at TEXT NOT NULL DEFAULT now(),
  UNIQUE (account_id, remote_id)
);

CREATE TABLE sync_info (
  id SERIAL PRIMARY KEY,
  connector TEXT NOT NULL REFERENCES connectors (name) ON DELETE CASCADE,
  account_id INTEGER NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
  metadata TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT now(),
  success BOOLEAN NOT NULL DEFAULT TRUE
)
