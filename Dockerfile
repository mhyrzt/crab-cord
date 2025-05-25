# Use the official Rust image as the build environment
FROM rust:1.77 as builder

WORKDIR /app

# Cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copy source code
COPY . .

# Build the actual project
RUN cargo build --release

# Use a minimal base image for the final artifact
FROM debian:bookworm-slim

# Install needed system dependencies (if any)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/target/release/discord-rst /app/discord-rst

# Set the startup command
CMD ["./discord-rst"]