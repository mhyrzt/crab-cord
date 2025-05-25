use anyhow::{Context, Result};
use std::{
    env,
    net::{IpAddr, Ipv4Addr, SocketAddr},
};
use tokio::net::TcpListener;

fn get_server_address() -> SocketAddr {
    let ip = IpAddr::V4(Ipv4Addr::UNSPECIFIED);
    let port: u16 = env::var("PORT")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(3000);
    
    SocketAddr::new(ip, port)
}

pub async fn create_tcp_listenr() -> Result<TcpListener> {
    let addr = get_server_address();
    TcpListener::bind(addr)
        .await
        .context(format!("Failed to bind to address: {}", addr))
}
