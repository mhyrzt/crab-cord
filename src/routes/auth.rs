use axum::{Router, routing::post};

use crate::app::AppState;
use crate::handlers::auth;

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/register", post(auth::register))
        .route("/login", post(auth::login))
        .route("/logout", post(auth::logout))
}
