use axum::Router;

use crate::app::AppState;

mod auth;
mod channels;
mod messages;
mod servers;
mod users;

pub fn app_router() -> Router<AppState> {
    Router::new()
        .nest("/users", users::routes())
        .nest("/auth", auth::routes())
}
