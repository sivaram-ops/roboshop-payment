# Stage 1: Build dependencies
FROM python:3.9.18-alpine3.19 AS builder
WORKDIR /build-dir

# Install build dependencies
RUN apk add --no-cache python3-dev build-base linux-headers pcre-dev
COPY requirements.txt .

# Install python packages
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final runtime image
FROM python:3.9.18-alpine3.19

# Add standard OCI labels for better image maintainability 
LABEL org.opencontainers.image.title="roboshop-payment" \
      org.opencontainers.image.description="Payment microservice for RoboShop"

WORKDIR /payment

# Install runtime dependencies and create a specific non-root user (UID/GID 1001)
RUN apk add --no-cache pcre && \
    addgroup -g 1001 roboshop && \
    adduser -S -u 1001 -G roboshop roboshop

# Copy compiled libraries from builder
COPY --from=builder /usr/local /usr/local

# Copy application code
COPY src .

# Set proper ownership for the app directory
RUN chown -R roboshop:roboshop /payment

# Enforce running as the non-root user via UID (better for K8s security contexts)
USER 1001

# Prevent Python from buffering stdout/stderr (crucial for accurate container logging)
ENV PYTHONUNBUFFERED=1

EXPOSE 8080

CMD ["uwsgi", "--ini", "payment.ini"]