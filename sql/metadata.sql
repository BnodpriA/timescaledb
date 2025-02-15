-- This file and its contents are licensed under the Apache License 2.0.
-- Please see the included NOTICE for copyright information and
-- LICENSE-APACHE for a copy of the license.

CREATE OR REPLACE FUNCTION _timescaledb_functions.generate_uuid() RETURNS UUID
AS '@MODULE_PATHNAME@', 'ts_uuid_generate' LANGUAGE C VOLATILE STRICT;

-- Insert uuid and install_timestamp on database creation. Don't
-- create exported_uuid because it gets exported and installed during
-- pg_dump, which would cause a conflict.
INSERT INTO _timescaledb_catalog.metadata
SELECT 'uuid', _timescaledb_functions.generate_uuid(), TRUE ON CONFLICT DO NOTHING;
INSERT INTO _timescaledb_catalog.metadata
SELECT 'install_timestamp', now(), TRUE ON CONFLICT DO NOTHING;

-- Install catalog version on database installation and upgrade.
-- This allows us to detect catalog mismatches in dump/restore cycle.
INSERT INTO _timescaledb_catalog.metadata (key, value, include_in_telemetry)
SELECT 'timescaledb_version', '@PROJECT_VERSION_MOD@', FALSE ON CONFLICT (key) DO UPDATE SET value = excluded.value;

