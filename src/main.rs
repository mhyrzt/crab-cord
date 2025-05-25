mod app;
mod db;
mod handlers;
mod models;
mod routes;
mod server;
mod services;

use anyhow::{Context, Result};
use app::AppState;
use dotenvy::dotenv;
use routes::app_router;
use server::create_tcp_listenr;
use std::sync::Arc;

#[tokio::main]
async fn main() -> Result<()> {
    dotenv().ok();
    tracing_subscriber::fmt::init();

    let pool = db::pool::create_pool().await?;
    let app_state = AppState { db: Arc::new(pool) };
    let listener = create_tcp_listenr().await?;
    let app = app_router().with_state(app_state);
    println!("Started Listening @ http://localhost:3000");
    axum::serve(listener, app).await.context("Server Failed")?;
    Ok(())
}
