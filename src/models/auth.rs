use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde::{Deserialize, Serialize};
use thiserror::Error;

// ---- REGISTER -----

#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub username: String,
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct RegisterResponse {
    pub(crate) message: String,
}

#[derive(Debug, Error)]
pub enum RegisterError {
    #[error("The email address is already in use. Please use a different email.")]
    EmailExists,

    #[error("The username is already taken. Please choose a different username.")]
    UsernameExists,

    #[error("The username is invalid. It may contain unsupported characters or be too short.")]
    BadUsername,

    #[error(
        "The password does not meet the required complexity. Please choose a stronger password."
    )]
    BadPassword,

    #[error("The email format is invalid. Please provide a valid email address.")]
    BadEmail,

    #[error("An unexpected internal error occurred: {0}")]
    InternalError(String),
}

impl IntoResponse for RegisterError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            RegisterError::BadUsername => (StatusCode::BAD_REQUEST, self.to_string()),
            RegisterError::BadPassword => (StatusCode::BAD_REQUEST, self.to_string()),
            RegisterError::BadEmail => (StatusCode::BAD_REQUEST, self.to_string()),
            RegisterError::InternalError(e) => {
                eprintln!("Internal Server Error: {}", e);
                (
                    StatusCode::INTERNAL_SERVER_ERROR,
                    "Internal Server Error".to_string(),
                )
            }
            RegisterError::EmailExists => (StatusCode::CONFLICT, self.to_string()),
            RegisterError::UsernameExists => (StatusCode::CONFLICT, self.to_string()),
        };

        (status, Json(RegisterResponse { message })).into_response()
    }
}

// ---- LOGIN ----

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub identifier: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub message: String,
    pub access_token: Option<String>,
    pub refresh_token: Option<String>,
}

#[derive(Debug, Error)]
pub enum LoginError {
    #[error("Invalid username or password")]
    InvalidCredntials,
    
    #[error("An unexpected internal error occurred: {0}")]
    InternalError(String),
}

impl IntoResponse for LoginError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            LoginError::InvalidCredntials => (StatusCode::UNAUTHORIZED, self.to_string()),
            LoginError::InternalError(_) => (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Internal Server Error".to_string(),
            ),
        };
        (
            status,
            Json(LoginResponse {
                message,
                access_token: None,
                refresh_token: None,
            }),
        )
            .into_response()
    }
}
