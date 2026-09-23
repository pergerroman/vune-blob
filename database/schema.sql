-- Vune Blob - baseline MariaDB 10.6+
-- Ejecutar sobre una base exclusiva, con la conexión configurada en UTC.

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET time_zone = '+00:00';

CREATE TABLE schema_migrations (
    version VARCHAR(100) NOT NULL,
    applied_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL,
    email_normalized VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    last_login_at DATETIME(6) NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email_normalized (email_normalized),
    KEY idx_users_status (status),
    CONSTRAINT chk_users_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_sessions (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    user_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    session_token_hash BINARY(32) NOT NULL,
    csrf_token_hash BINARY(32) NOT NULL,
    ip_address VARBINARY(16) NULL,
    user_agent VARCHAR(500) NULL,
    last_seen_at DATETIME(6) NOT NULL,
    expires_at DATETIME(6) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    revoked_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_user_sessions_token_hash (session_token_hash),
    KEY idx_user_sessions_user_active (user_id, revoked_at, expires_at),
    KEY idx_user_sessions_expiry (expires_at),
    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE projects (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(160) NOT NULL,
    code VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    description TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    storage_limit_bytes BIGINT UNSIGNED NOT NULL,
    storage_used_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
    storage_reserved_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
    file_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
    folder_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    deleted_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    purge_after DATETIME(6) NULL,
    active_slot TINYINT UNSIGNED NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_projects_active_code (code, active_slot),
    KEY idx_projects_status (status, deleted_at),
    KEY idx_projects_created_by (created_by),
    CONSTRAINT fk_projects_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT fk_projects_deleted_by FOREIGN KEY (deleted_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_projects_code CHECK (code REGEXP '^[A-Z0-9]{2,12}$'),
    CONSTRAINT chk_projects_status CHECK (status IN ('active', 'archived', 'deleted')),
    CONSTRAINT chk_projects_active_slot CHECK (
        (deleted_at IS NULL AND active_slot = 1) OR
        (deleted_at IS NOT NULL AND active_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_members (
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    user_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (project_id, user_id),
    KEY idx_project_members_user (user_id, role),
    CONSTRAINT fk_project_members_project FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT fk_project_members_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT chk_project_members_role CHECK (role IN ('owner', 'admin', 'editor', 'viewer'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE storage_providers (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    driver VARCHAR(40) NOT NULL,
    name VARCHAR(120) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    configuration_reference VARCHAR(255) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_storage_providers_name (name),
    KEY idx_storage_providers_driver_status (driver, status),
    CONSTRAINT chk_storage_providers_driver CHECK (driver IN ('local', 's3', 'r2', 'backblaze')),
    CONSTRAINT chk_storage_providers_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE blobs (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    storage_provider_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(160) NOT NULL,
    name_key VARCHAR(160) NOT NULL,
    code VARCHAR(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    description TEXT NULL,
    visibility VARCHAR(20) NOT NULL DEFAULT 'private',
    storage_limit_bytes BIGINT UNSIGNED NULL,
    storage_used_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
    storage_reserved_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
    file_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
    folder_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    deleted_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    purge_after DATETIME(6) NULL,
    active_slot TINYINT UNSIGNED NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_blobs_id_project (id, project_id),
    UNIQUE KEY uq_blobs_active_name (project_id, name_key, active_slot),
    UNIQUE KEY uq_blobs_active_code (project_id, code, active_slot),
    KEY idx_blobs_project_status (project_id, status, deleted_at),
    KEY idx_blobs_provider (storage_provider_id),
    CONSTRAINT fk_blobs_project FOREIGN KEY (project_id) REFERENCES projects (id),
    CONSTRAINT fk_blobs_provider FOREIGN KEY (storage_provider_id) REFERENCES storage_providers (id),
    CONSTRAINT fk_blobs_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT fk_blobs_deleted_by FOREIGN KEY (deleted_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_blobs_visibility CHECK (visibility IN ('public', 'private')),
    CONSTRAINT chk_blobs_status CHECK (status IN ('active', 'archived', 'deleted')),
    CONSTRAINT chk_blobs_active_slot CHECK (
        (deleted_at IS NULL AND active_slot = 1) OR
        (deleted_at IS NOT NULL AND active_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE folders (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    blob_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    parent_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    parent_scope VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin
        GENERATED ALWAYS AS (IFNULL(parent_id, 'ROOT')) STORED,
    name VARCHAR(160) NOT NULL,
    name_key VARCHAR(160) NOT NULL,
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    deleted_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    purge_after DATETIME(6) NULL,
    active_slot TINYINT UNSIGNED NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_folders_id_blob (id, blob_id),
    UNIQUE KEY uq_folders_active_name (blob_id, parent_scope, name_key, active_slot),
    KEY idx_folders_parent (blob_id, parent_id, deleted_at),
    KEY idx_folders_purge (purge_after),
    CONSTRAINT fk_folders_blob FOREIGN KEY (blob_id) REFERENCES blobs (id),
    CONSTRAINT fk_folders_parent_blob FOREIGN KEY (parent_id, blob_id) REFERENCES folders (id, blob_id),
    CONSTRAINT fk_folders_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT fk_folders_deleted_by FOREIGN KEY (deleted_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_folders_not_self CHECK (parent_id IS NULL OR parent_id <> id),
    CONSTRAINT chk_folders_active_slot CHECK (
        (deleted_at IS NULL AND active_slot = 1) OR
        (deleted_at IS NOT NULL AND active_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_sequences (
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    asset_type VARCHAR(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    next_value BIGINT UNSIGNED NOT NULL DEFAULT 1,
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (project_id, asset_type),
    CONSTRAINT fk_project_sequences_project FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT chk_project_sequences_type CHECK (asset_type IN ('IMG', 'VID', 'AUD', 'DOC', 'ARC', 'OTH')),
    CONSTRAINT chk_project_sequences_next CHECK (next_value > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE assets (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    blob_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    folder_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    folder_scope VARCHAR(30) CHARACTER SET ascii COLLATE ascii_bin
        GENERATED ALWAYS AS (IFNULL(folder_id, 'ROOT')) STORED,
    reference_code VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    name_key VARCHAR(255) NOT NULL,
    asset_type VARCHAR(20) NOT NULL,
    visibility VARCHAR(20) NOT NULL DEFAULT 'private',
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    current_version_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    updated_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    deleted_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    purge_after DATETIME(6) NULL,
    active_slot TINYINT UNSIGNED NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_assets_reference (reference_code),
    UNIQUE KEY uq_assets_active_name (blob_id, folder_scope, name_key, active_slot),
    KEY idx_assets_folder (blob_id, folder_id, status, updated_at),
    KEY idx_assets_type (blob_id, asset_type, status, updated_at),
    KEY idx_assets_visibility (blob_id, visibility, status),
    KEY idx_assets_current_version (current_version_id),
    KEY idx_assets_purge (purge_after),
    CONSTRAINT fk_assets_blob FOREIGN KEY (blob_id) REFERENCES blobs (id),
    CONSTRAINT fk_assets_folder_blob FOREIGN KEY (folder_id, blob_id) REFERENCES folders (id, blob_id),
    CONSTRAINT fk_assets_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT fk_assets_updated_by FOREIGN KEY (updated_by) REFERENCES users (id),
    CONSTRAINT fk_assets_deleted_by FOREIGN KEY (deleted_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_assets_type CHECK (asset_type IN ('image', 'video', 'audio', 'document', 'archive', 'other')),
    CONSTRAINT chk_assets_visibility CHECK (visibility IN ('public', 'private')),
    CONSTRAINT chk_assets_status CHECK (status IN ('pending', 'ready', 'failed', 'deleted')),
    CONSTRAINT chk_assets_active_slot CHECK (
        (deleted_at IS NULL AND active_slot = 1) OR
        (deleted_at IS NOT NULL AND active_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE asset_versions (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    asset_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    version_number INT UNSIGNED NOT NULL,
    storage_provider_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    storage_key VARCHAR(500) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    content_disposition_name VARCHAR(255) NOT NULL,
    extension VARCHAR(20) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    declared_mime_type VARCHAR(150) NULL,
    detected_mime_type VARCHAR(150) NOT NULL,
    size_bytes BIGINT UNSIGNED NOT NULL,
    checksum_sha256 BINARY(32) NOT NULL,
    etag VARCHAR(255) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    purge_after DATETIME(6) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_asset_versions_number (asset_id, version_number),
    UNIQUE KEY uq_asset_versions_storage_key (storage_provider_id, storage_key),
    KEY idx_asset_versions_checksum (checksum_sha256),
    KEY idx_asset_versions_status (status, created_at),
    KEY idx_asset_versions_purge (purge_after),
    CONSTRAINT fk_asset_versions_asset FOREIGN KEY (asset_id) REFERENCES assets (id),
    CONSTRAINT fk_asset_versions_provider FOREIGN KEY (storage_provider_id) REFERENCES storage_providers (id),
    CONSTRAINT fk_asset_versions_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT chk_asset_versions_number CHECK (version_number > 0),
    CONSTRAINT chk_asset_versions_status CHECK (status IN ('pending', 'ready', 'failed', 'deleted'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE assets
    ADD CONSTRAINT fk_assets_current_version FOREIGN KEY (current_version_id) REFERENCES asset_versions (id);

CREATE TABLE tags (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(80) NOT NULL,
    slug VARCHAR(100) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    deleted_at DATETIME(6) NULL,
    active_slot TINYINT UNSIGNED NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_tags_active_slug (project_id, slug, active_slot),
    CONSTRAINT fk_tags_project FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
    CONSTRAINT chk_tags_active_slot CHECK (
        (deleted_at IS NULL AND active_slot = 1) OR
        (deleted_at IS NOT NULL AND active_slot IS NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE asset_tags (
    asset_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    tag_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (asset_id, tag_id),
    KEY idx_asset_tags_tag (tag_id, asset_id),
    CONSTRAINT fk_asset_tags_asset FOREIGN KEY (asset_id) REFERENCES assets (id) ON DELETE CASCADE,
    CONSTRAINT fk_asset_tags_tag FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE access_tokens (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    blob_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(120) NOT NULL,
    description TEXT NULL,
    prefix VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    secret_hash VARCHAR(255) NOT NULL,
    environment VARCHAR(20) NOT NULL DEFAULT 'live',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_by CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    last_used_at DATETIME(6) NULL,
    expires_at DATETIME(6) NULL,
    revoked_at DATETIME(6) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_access_tokens_prefix (prefix),
    KEY idx_access_tokens_blob_status (blob_id, status),
    KEY idx_access_tokens_expiry (expires_at),
    CONSTRAINT fk_access_tokens_blob FOREIGN KEY (blob_id) REFERENCES blobs (id),
    CONSTRAINT fk_access_tokens_created_by FOREIGN KEY (created_by) REFERENCES users (id),
    CONSTRAINT chk_access_tokens_environment CHECK (environment IN ('live', 'test')),
    CONSTRAINT chk_access_tokens_status CHECK (status IN ('active', 'expired', 'revoked'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE token_scopes (
    token_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    scope VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    PRIMARY KEY (token_id, scope),
    CONSTRAINT fk_token_scopes_token FOREIGN KEY (token_id) REFERENCES access_tokens (id) ON DELETE CASCADE,
    CONSTRAINT chk_token_scopes_scope CHECK (scope IN (
        'files:read', 'files:create', 'files:update', 'files:delete',
        'folders:read', 'folders:create', 'folders:update', 'folders:delete',
        'metadata:read', 'metadata:update'
    ))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE upload_sessions (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    user_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    token_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    blob_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    folder_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    idempotency_key_hash BINARY(32) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    expected_size_bytes BIGINT UNSIGNED NOT NULL,
    detected_size_bytes BIGINT UNSIGNED NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    temporary_storage_key VARCHAR(500) CHARACTER SET ascii COLLATE ascii_bin NULL,
    final_asset_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    error_code VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NULL,
    error_message VARCHAR(500) NULL,
    expires_at DATETIME(6) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_upload_idempotency_user (user_id, idempotency_key_hash),
    UNIQUE KEY uq_upload_idempotency_token (token_id, idempotency_key_hash),
    KEY idx_upload_sessions_status_expiry (status, expires_at),
    KEY idx_upload_sessions_project (project_id, created_at),
    CONSTRAINT fk_upload_sessions_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT fk_upload_sessions_token FOREIGN KEY (token_id) REFERENCES access_tokens (id) ON DELETE SET NULL,
    CONSTRAINT fk_upload_sessions_project FOREIGN KEY (project_id) REFERENCES projects (id),
    CONSTRAINT fk_upload_sessions_blob_project FOREIGN KEY (blob_id, project_id) REFERENCES blobs (id, project_id),
    CONSTRAINT fk_upload_sessions_folder_blob FOREIGN KEY (folder_id, blob_id) REFERENCES folders (id, blob_id),
    CONSTRAINT fk_upload_sessions_asset FOREIGN KEY (final_asset_id) REFERENCES assets (id),
    CONSTRAINT chk_upload_actor CHECK ((user_id IS NOT NULL) <> (token_id IS NOT NULL)),
    CONSTRAINT chk_upload_status CHECK (status IN ('pending', 'uploading', 'processing', 'completed', 'failed', 'cancelled', 'expired'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE idempotency_records (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    actor_user_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    actor_token_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    route_key VARCHAR(160) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    idempotency_key_hash BINARY(32) NOT NULL,
    request_hash BINARY(32) NOT NULL,
    state VARCHAR(20) NOT NULL DEFAULT 'in_progress',
    response_status SMALLINT UNSIGNED NULL,
    response_json LONGTEXT NULL,
    resource_type VARCHAR(40) NULL,
    resource_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
    expires_at DATETIME(6) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_idempotency_user (actor_user_id, route_key, idempotency_key_hash),
    UNIQUE KEY uq_idempotency_token (actor_token_id, route_key, idempotency_key_hash),
    KEY idx_idempotency_expiry (expires_at),
    CONSTRAINT fk_idempotency_user FOREIGN KEY (actor_user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_idempotency_token FOREIGN KEY (actor_token_id) REFERENCES access_tokens (id) ON DELETE CASCADE,
    CONSTRAINT chk_idempotency_actor CHECK ((actor_user_id IS NOT NULL) <> (actor_token_id IS NOT NULL)),
    CONSTRAINT chk_idempotency_state CHECK (state IN ('in_progress', 'completed', 'failed')),
    CONSTRAINT chk_idempotency_response_json CHECK (response_json IS NULL OR JSON_VALID(response_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE activity_logs (
    id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    request_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    actor_type VARCHAR(20) NOT NULL,
    actor_user_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    actor_token_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    project_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    blob_id CHAR(30) CHARACTER SET ascii COLLATE ascii_bin NULL,
    resource_type VARCHAR(40) NULL,
    resource_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL,
    action VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    result VARCHAR(20) NOT NULL,
    ip_address VARBINARY(16) NULL,
    user_agent VARCHAR(500) NULL,
    metadata_json LONGTEXT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_activity_project_date (project_id, created_at),
    KEY idx_activity_blob_date (blob_id, created_at),
    KEY idx_activity_action_date (action, created_at),
    KEY idx_activity_user_date (actor_user_id, created_at),
    KEY idx_activity_token_date (actor_token_id, created_at),
    KEY idx_activity_resource (resource_type, resource_id, created_at),
    CONSTRAINT fk_activity_user FOREIGN KEY (actor_user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT fk_activity_token FOREIGN KEY (actor_token_id) REFERENCES access_tokens (id) ON DELETE SET NULL,
    CONSTRAINT fk_activity_project FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE SET NULL,
    CONSTRAINT fk_activity_blob FOREIGN KEY (blob_id) REFERENCES blobs (id) ON DELETE SET NULL,
    CONSTRAINT chk_activity_actor_type CHECK (actor_type IN ('user', 'token', 'system')),
    CONSTRAINT chk_activity_result CHECK (result IN ('success', 'failure')),
    CONSTRAINT chk_activity_metadata_json CHECK (metadata_json IS NULL OR JSON_VALID(metadata_json))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rate_limit_counters (
    bucket_key_hash BINARY(32) NOT NULL,
    bucket_name VARCHAR(80) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    window_started_at DATETIME(6) NOT NULL,
    attempts INT UNSIGNED NOT NULL DEFAULT 0,
    blocked_until DATETIME(6) NULL,
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (bucket_key_hash, bucket_name),
    KEY idx_rate_limit_cleanup (window_started_at, blocked_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('0001_baseline');
