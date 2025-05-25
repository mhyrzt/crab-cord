use axum::extract::Path;

pub async fn get_me() -> &'static str {
    todo!();
}

pub async fn update_me() -> &'static str {
    todo!();
}

pub async fn search_users() -> &'static str {
    todo!();
}

pub async fn get_user_by_id(Path(user_id): Path<String>) -> String {
    todo!();
}
