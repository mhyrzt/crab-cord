use crate::{
    app::AppState,
    handlers::users::{get_me, get_user_by_id, search_users, update_me},
};
use axum::{Router, routing::get};

pub fn routes() -> Router<AppState> {
    Router::new()
        .route("/me", get(get_me).patch(update_me))
        .route("/search", get(search_users))
        .route("/{user_id}", get(get_user_by_id))
}
