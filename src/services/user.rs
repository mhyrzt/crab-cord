use super::utils::hash_password;
use crate::models::auth::{LoginError, RegisterError};
use regex::Regex;
use sqlx::PgPool;

pub async fn check_user_exists(
    pool: &PgPool,
    username: &str,
    email: &str,
) -> Result<(), RegisterError> {
    let (email_exists, username_exists): (bool, bool) = sqlx::query_as(
        r#"
        SELECT 
            EXISTS(SELECT 1 FROM users WHERE email = $1) AS email_exists,
            EXISTS(SELECT 1 FROM users WHERE username = $2) AS username_exists
        "#,
    )
    .bind(email)
    .bind(username)
    .fetch_one(pool)
    .await
    .map_err(|e| RegisterError::InternalError(e.to_string()))?;

    if email_exists {
        return Err(RegisterError::EmailExists);
    }
    if username_exists {
        return Err(RegisterError::UsernameExists);
    }
    Ok(())
}

fn is_valid_password(password: &str) -> bool {
    password.len() >= 8
        && password.chars().any(|c| c.is_ascii_lowercase())
        && password.chars().any(|c| c.is_ascii_uppercase())
        && password.chars().any(|c| c.is_ascii_digit())
        && password.chars().any(|c| !c.is_alphanumeric())
}

fn is_valid_username(username: &str) -> bool {
    (3..=20).contains(&username.len())
        && username
            .chars()
            .next()
            .map(|c| c.is_ascii_alphabetic())
            .unwrap_or(false)
        && username
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '_')
}

fn is_valid_email(email: &str) -> bool {
    Regex::new(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
        .unwrap()
        .is_match(email)
}

fn validate_register_data(
    email: &str,
    username: &str,
    password: &str,
) -> Result<(), RegisterError> {
    if !is_valid_email(email) {
        return Err(RegisterError::BadEmail);
    }
    if !is_valid_username(username) {
        return Err(RegisterError::BadUsername);
    }
    if !is_valid_password(password) {
        return Err(RegisterError::BadPassword);
    }
    Ok(())
}

pub async fn create_user(
    pool: &PgPool,
    username: &str,
    email: &str,
    password: &str,
) -> Result<(), RegisterError> {
    validate_register_data(email, username, password)?;
    check_user_exists(pool, username, email).await?;

    sqlx::query!(
        r#"INSERT INTO users (username, email, password_hash) 
        VALUES ($1, $2, $3)
        "#,
        username,
        email,
        hash_password(password).map_err(|e| RegisterError::InternalError(e.to_string()))?
    )
    .execute(pool)
    .await
    .map_err(|e| RegisterError::InternalError(e.to_string()))?;

    Ok(())
}

pub async fn get_user_password_hash(pool: &PgPool, identifier: &str) -> Result<String, LoginError> {
    if !is_valid_email(identifier) && !is_valid_username(identifier) {
        Err(LoginError::InvalidCredntials)
    } else {
        let row = sqlx::query!(
            r#"
            SELECT password_hash FROM users
            WHERE email = $1 OR username = $1
            "#,
            identifier
        )
        .fetch_optional(pool)
        .await
        .map_err(|e| LoginError::InternalError(e.to_string()))?;

        if let Some(record) = row {
            Ok(record.password_hash)
        } else {
            Err(LoginError::InvalidCredntials)
        }
    }
}
