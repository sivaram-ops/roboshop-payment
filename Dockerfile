FROM python:3.9.18-alpine3.19
WORKDIR /app
RUN apk add python3-dev build-base linux-headers pcre-dev
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop
COPY *.py /app/
COPY payment.ini /app/
EXPOSE 8080
CMD ["uwsgi", "--ini", "payment.ini"]

# Environment=CART_HOST=cart
# Environment=CART_PORT=8080
# Environment=USER_HOST=user
# Environment=USER_PORT=8080
# Environment=AMQP_HOST=rabbitmq
# Environment=AMQP_USER=roboshop
# Environment=AMQP_PASS=roboshop123