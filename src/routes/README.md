# Routes

## **1. User Routes**

### **Authentication & User Management**

| Method  | Endpoint             | Description                    | Parameters/Body                       |
| ------- | -------------------- | ------------------------------ | ------------------------------------- |
| `POST`  | `/api/auth/register` | Register a new user            | `{ username, email, password }`       |
| `POST`  | `/api/auth/login`    | Log in a user                  | `{ email, password }`                 |
| `POST`  | `/api/auth/logout`   | Log out the current user       | (Requires Auth)                       |
| `GET`   | `/api/users/me`      | Get current user's profile     | (Requires Auth)                       |
| `PATCH` | `/api/users/me`      | Update current user's profile  | `{ username?, avatar_url?, status? }` |
| `GET`   | `/api/users/:userId` | Get a user's public profile    | `userId` (URL param)                  |
| `GET`   | `/api/users/search`  | Search users by username/email | `query` (Query param)                 |

## **2. Server (Guild) Routes**

### **Server Management**

| Method   | Endpoint                         | Description                | Parameters/Body            |
| -------- | -------------------------------- | -------------------------- | -------------------------- |
| `POST`   | `/api/servers`                   | Create a new server        | `{ name, icon_url? }`      |
| `GET`    | `/api/servers/:serverId`         | Get server details         | `serverId` (URL param)     |
| `PATCH`  | `/api/servers/:serverId`         | Update server (name, icon) | `{ name?, icon_url? }`     |
| `DELETE` | `/api/servers/:serverId`         | Delete a server            | `serverId` (URL param)     |
| `GET`    | `/api/servers/:serverId/members` | List server members        | `serverId` (URL param)     |
| `POST`   | `/api/servers/:serverId/invites` | Generate invite link       | `{ expiresAt?, maxUses? }` |

## **3. Channel Routes**

### **Text/Voice/DM Channels**

| Method   | Endpoint                            | Description         | Parameters/Body                         |
| -------- | ----------------------------------- | ------------------- | --------------------------------------- |
| `POST`   | `/api/servers/:serverId/channels`   | Create a channel    | `{ name, type, topic?, position? }`     |
| `GET`    | `/api/channels/:channelId`          | Get channel details | `channelId` (URL param)                 |
| `PATCH`  | `/api/channels/:channelId`          | Update channel      | `{ name?, topic?, position? }`          |
| `DELETE` | `/api/channels/:channelId`          | Delete a channel    | `channelId` (URL param)                 |
| `GET`    | `/api/channels/:channelId/messages` | List messages       | `limit?, before? (pagination)`          |
| `POST`   | `/api/channels/:channelId/messages` | Send a message      | `{ content, parentMessageId? (reply) }` |

## **4. Message Routes**

### **Message Operations**

| Method   | Endpoint                                    | Description      | Parameters/Body         |
| -------- | ------------------------------------------- | ---------------- | ----------------------- |
| `GET`    | `/api/messages/:messageId`                  | Get a message    | `messageId` (URL param) |
| `PATCH`  | `/api/messages/:messageId`                  | Edit a message   | `{ content }`           |
| `DELETE` | `/api/messages/:messageId`                  | Delete a message | `messageId` (URL param) |
| `POST`   | `/api/messages/:messageId/reactions/:emoji` | Add reaction     | `emoji` (URL param)     |
| `DELETE` | `/api/messages/:messageId/reactions/:emoji` | Remove reaction  | `emoji` (URL param)     |

## **5. Role & Permission Routes**

### **Role Management**

| Method   | Endpoint                                               | Description   | Parameters/Body                   |
| -------- | ------------------------------------------------------ | ------------- | --------------------------------- |
| `POST`   | `/api/servers/:serverId/roles`                         | Create a role | `{ name, color, permissions }`    |
| `PATCH`  | `/api/servers/:serverId/roles/:roleId`                 | Update role   | `{ name?, color?, permissions? }` |
| `DELETE` | `/api/servers/:serverId/roles/:roleId`                 | Delete a role | `roleId` (URL param)              |
| `POST`   | `/api/servers/:serverId/members/:userId/roles/:roleId` | Assign role   | `userId`, `roleId`                |
| `DELETE` | `/api/servers/:serverId/members/:userId/roles/:roleId` | Remove role   | `userId`, `roleId`                |

## **6. DM & Group DM Routes**

### **Direct Messaging**

| Method   | Endpoint                         | Description             | Parameters/Body       |
| -------- | -------------------------------- | ----------------------- | --------------------- |
| `POST`   | `/api/dms`                       | Start a DM with a user  | `{ userId }`          |
| `POST`   | `/api/group-dms`                 | Create a group DM       | `{ name, userIds[] }` |
| `POST`   | `/api/group-dms/:groupId/invite` | Invite user to group DM | `{ userId }`          |
| `DELETE` | `/api/group-dms/:groupId/leave`  | Leave a group DM        | `groupId` (URL param) |

## **7. Voice Channel Routes**

### **Voice Chat Management**

| Method | Endpoint                             | Description             | Parameters/Body         |
| ------ | ------------------------------------ | ----------------------- | ----------------------- |
| `POST` | `/api/voice/join`                    | Join a voice channel    | `{ channelId }`         |
| `POST` | `/api/voice/leave`                   | Leave voice channel     | (Requires Auth)         |
| `GET`  | `/api/voice/:channelId/participants` | List voice participants | `channelId` (URL param) |

## **8. Invite Routes**

### **Invite Management**

| Method   | Endpoint                    | Description        | Parameters/Body    |
| -------- | --------------------------- | ------------------ | ------------------ |
| `GET`    | `/api/invites/:code`        | Get invite details | `code` (URL param) |
| `POST`   | `/api/invites/:code/accept` | Accept an invite   | `code` (URL param) |
| `DELETE` | `/api/invites/:code`        | Revoke an invite   | `code` (URL param) |
