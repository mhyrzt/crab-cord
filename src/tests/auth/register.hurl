# User Registration API Tests
# Run with: hurl --test src/tests/auth/auth/register.hurl --name @name



### 1. Test Successful Registration
# @name register_success
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "testuser3",
  "email": "test3@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 201
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.message" == "User Created Sucessfully"

### 2. Test Missing Required Fields
# @name register_missing_fields
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "",
  "email": "",
  "password": ""
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" exists

### 3. Test Invalid Email Format
# @name register_invalid_email
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "not-an-email",
  "password": "securePassword123!"
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" contains "email"

### 4. Test Weak Password
# @name register_weak_password
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "123"
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" contains "password"

### 5. Test Duplicate Username
# First create a user
# @name setup_duplicate_user
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "duplicate_user",
  "email": "unique1@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 201

# Then try to create another user with same username
# @name register_duplicate_username
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "duplicate_user",
  "email": "unique2@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" contains "username"

### 6. Test Duplicate Email
# First create a user
# @name setup_duplicate_email
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "unique_user1",
  "email": "duplicate@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 201

# Then try to create another user with same email
# @name register_duplicate_email
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "unique_user2",
  "email": "duplicate@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" contains "email"

### 7. Test Long Username
# @name register_long_username
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "thisusernameiswaytoolongandshouldberejectedbythevalidationlogic",
  "email": "test@example.com",
  "password": "securePassword123!"
}

HTTP/1.1 400
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.error" contains "username"

### 8. Test Successful Registration with Different Cases
# @name register_success_different_cases
POST http://localhost:3000/auth/register
Content-Type: application/json

{
  "username": "TestUser123",
  "email": "TEST@example.com",
  "password": "SecurePassword123!"
}

HTTP/1.1 201
[Asserts]
header "Content-Type" contains "application/json"
jsonpath "$.message" == "User Created Sucessfully"