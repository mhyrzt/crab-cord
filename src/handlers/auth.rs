use axum::{
    extract::{Json, State},
    http::StatusCode,
    response::IntoResponse,
};

use crate::{app::AppState, services::{user::create_user, utils::verify_password}};
use crate::{
    models::auth::{
        LoginError, LoginRequest, LoginResponse, RegisterError, RegisterRequest, RegisterResponse,
    },
    services::user::get_user_password_hash,
};

pub async fn register(
    State(state): State<AppState>,
    Json(payload): Json<RegisterRequest>,
) -> Result<impl IntoResponse, RegisterError> {
    create_user(
        &state.db,
        &payload.username,
        &payload.email,
        &payload.password,
    )
    .await?;

    Ok((
        StatusCode::CREATED,
        Json(RegisterResponse {
            message: "User Created Sucessfully".to_string(),
        }),
    ))
}

pub async fn login(
    State(state): State<AppState>,
    Json(paylod): Json<LoginRequest>,
) -> Result<impl IntoResponse, LoginError> {
    let hashed = get_user_password_hash(&state.db, &paylod.identifier).await?;

    if !verify_password(&paylod.password, &hashed) {
        return  Err(LoginError::InvalidCredntials);
    }
    let access_token = "access_token".to_string();
    let refresh_token = "refresh_token".to_string();

    Ok((
        StatusCode::OK,
        Json(LoginResponse {
            message: "Authenticated Successfully".to_string(),
            access_token: Some(access_token),
            refresh_token: Some(refresh_token),
        }),
    ))
}

pub async fn logout() {}
