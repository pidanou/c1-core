
PRAGMA foreign_keys = ON;

CREATE TABLE plugins (
  name TEXT PRIMARY KEY NOT NULL DEFAULT '',
  source TEXT NOT NULL DEFAULT '',
  uri TEXT NOT NULL DEFAULT '',
  install_command TEXT NOT NULL DEFAULT '',
  update_command TEXT NOT NULL DEFAULT '',
  command TEXT NOT NULL
);

CREATE TABLE accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plugin TEXT NOT NULL REFERENCES plugins (name) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  options TEXT NOT NULL DEFAULT ''
);

CREATE TABLE data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id INTEGER NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
  remote_id TEXT NOT NULL DEFAULT '',
  plugin TEXT NOT NULL REFERENCES plugins (name) ON DELETE CASCADE,
  resource_name TEXT NOT NULL DEFAULT '',
  uri TEXT NOT NULL DEFAULT '',
  metadata TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT ''
);
