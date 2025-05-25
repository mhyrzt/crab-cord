use anyhow::{Context, Ok, Result};
use sqlx::{PgPool, postgres::PgPoolOptions};
use std::env;

pub async fn create_pool() -> Result<PgPool> {
    let db_url =
        env::var("DATABASE_URL")
        .context("DATABASE_URL must be set in .env file or environment")?;

    PgPoolOptions::new()
        .max_connections(5)
        .connect(&db_url)
        .await
        .context("Failed to create database pool")
}


pub async fn db_health_check(pool: &PgPool) -> Result<()> {
    sqlx::query("SELECT 1")
        .execute(pool)
        .await
        .context("Database health check failed")?;

    Ok(())
}
