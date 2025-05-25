-- ========================
-- UTILITY FUNCTIONS/TRIGGERS
-- ========================
-- Trigger function to update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
END;
$$ language 'plpgsql';
-- ========================
-- USERS TABLE
-- ========================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    -- To enforce case-insensitive comparison, use citext:
    -- username CITEXT NOT NULL UNIQUE,
    -- email CITEXT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    status VARCHAR(50) DEFAULT 'offline' CHECK (status IN ('online', 'offline', 'idle', 'dnd')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER update_users_updated_at BEFORE
UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
-- ========================
-- SERVERS (GUILDS)
-- ========================
CREATE TABLE servers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    owner_id BIGINT NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    icon_url TEXT,
    invite_code TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE TRIGGER update_servers_updated_at BEFORE
UPDATE ON servers FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
-- ========================
-- CHANNELS
-- ========================
CREATE TABLE channels (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(20) NOT NULL CHECK (
        type IN ('text', 'voice', 'dm', 'group_dm', 'thread')
    ),
    server_id BIGINT REFERENCES servers (id) ON DELETE CASCADE,
    topic TEXT,
    position INT,
    parent_channel_id BIGINT REFERENCES channels (id) ON DELETE
    SET NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- ========================
-- MESSAGES
-- ========================
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    user_id BIGINT REFERENCES users (id) ON DELETE
    SET NULL,
        channel_id BIGINT NOT NULL REFERENCES channels (id) ON DELETE CASCADE,
        parent_message_id BIGINT REFERENCES messages (id) ON DELETE
    SET NULL,
        thread_id BIGINT REFERENCES channels (id) ON DELETE
    SET NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        edited_at TIMESTAMP WITH TIME ZONE
);
-- For threads with parent message (circular dependency)
ALTER TABLE channels
ADD COLUMN parent_message_id BIGINT REFERENCES messages (id) ON DELETE
SET NULL;
-- ========================
-- REACTIONS
-- ========================
CREATE TABLE reactions (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages (id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    emoji VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (message_id, user_id, emoji)
);
-- ========================
-- ATTACHMENTS
-- ========================
CREATE TABLE attachments (
    id BIGSERIAL PRIMARY KEY,
    message_id BIGINT NOT NULL REFERENCES messages (id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- ========================
-- ROLES
-- ========================
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    server_id BIGINT NOT NULL REFERENCES servers (id) ON DELETE CASCADE,
    color CHAR(7),
    -- e.g., "#FFFFFF", nullable
    permissions BIGINT NOT NULL DEFAULT 0,
    position INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- ========================
-- USER-ROLE ASSIGNMENTS
-- ========================
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);
-- ========================
-- CHANNEL PERMISSION OVERWRITES
-- ========================
CREATE TABLE permission_overwrites (
    id BIGSERIAL PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES channels (id) ON DELETE CASCADE,
    target_type VARCHAR(10) NOT NULL CHECK (target_type IN ('user', 'role')),
    target_id BIGINT NOT NULL,
    allow_permissions BIGINT NOT NULL DEFAULT 0,
    deny_permissions BIGINT NOT NULL DEFAULT 0,
    UNIQUE (channel_id, target_type, target_id) -- NOTE: app must enforce target_id refers to the right table
);
-- ========================
-- SERVER MEMBERSHIP
-- ========================
CREATE TABLE server_members (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    server_id BIGINT NOT NULL REFERENCES servers (id) ON DELETE CASCADE,
    nickname VARCHAR(255),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, server_id)
);
-- ========================
-- DM PARTICIPANTS (for DMs, Group DMs, etc)
-- ========================
CREATE TABLE channel_users (
    channel_id BIGINT NOT NULL REFERENCES channels (id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (channel_id, user_id)
);
-- ========================
-- VOICE CHANNEL PARTICIPANTS
-- ========================
CREATE TABLE voice_participants (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    channel_id BIGINT NOT NULL REFERENCES channels (id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (user_id, channel_id)
);
-- ========================
-- INVITES
-- ========================
CREATE TABLE invites (
    code VARCHAR(100) PRIMARY KEY,
    server_id BIGINT NOT NULL REFERENCES servers (id) ON DELETE CASCADE,
    inviter_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    expires_at TIMESTAMP WITH TIME ZONE,
    max_uses INT,
    uses INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- ========================
-- USER CHANNEL SETTINGS
-- ========================
CREATE TABLE user_channel_settings (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    channel_id BIGINT NOT NULL REFERENCES channels (id) ON DELETE CASCADE,
    last_read_message_id BIGINT REFERENCES messages (id) ON DELETE
    SET NULL,
        muted BOOLEAN DEFAULT false,
        notification_preferences JSONB,
        PRIMARY KEY (user_id, channel_id)
);
-- Recommended: for querying notification prefs, if needed
CREATE INDEX idx_user_channel_settings_notification_prefs ON user_channel_settings USING GIN(notification_preferences);
-- ========================
-- USER RELATIONSHIPS (FRIENDS, BLOCKED)
-- ========================
CREATE TABLE user_relationships (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    related_user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('friend', 'block')),
    status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'accepted')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (user_id <> related_user_id)
);
-- ========================
-- RECOMMENDED INDEXES
-- ========================
-- Fast lookups for big/active tables (messages, etc)
CREATE INDEX idx_messages_channel_id ON messages(channel_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_server_members_server_id ON server_members(server_id);
CREATE INDEX idx_server_members_user_id ON server_members(user_id);
CREATE INDEX idx_roles_server_id ON roles(server_id);
CREATE INDEX idx_attachments_message_id ON attachments(message_id);
CREATE INDEX idx_reactions_message_id ON reactions(message_id);
CREATE INDEX idx_permission_overwrites_channel_id ON permission_overwrites(channel_id);
-- For searching users by status or username/email (helpful for admin/tools)
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
-- For search on channel_users (DM lookups)
CREATE INDEX idx_channel_users_user_id ON channel_users(user_id);
-- ========================
-- NOTES
-- ========================
-- For case-insensitive unique email/username, install the extension:
-- CREATE EXTENSION IF NOT EXISTS citext;
-- and then use CITEXT for those columns.
--
-- If you start to see `BIGINT` overkill for IDs, revert to `SERIAL` if you're *certain* you won't hit int32 limits.
-- Triggers are only set up for users/servers -- add to more tables if you want.
-- You can add more triggers for other tables if you wish to audit updated_at for them too!