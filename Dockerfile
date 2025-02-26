# Используем официальный образ Node.js
FROM node:18 AS build

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и устанавливаем зависимости
COPY package.json package-lock.json ./

RUN npm install

# Install Chromium for running tests
RUN apt-get update && apt-get install -y chromium

# Set environment variable for Karma
ENV CHROME_BIN=/usr/bin/chromium

# Copy source code and run tests
COPY . .
RUN npm run test -- --no-watch --no-progress --browsers=ChromeHeadlessNoSandbox

# Копируем весь проект и собираем Angular-приложение
COPY . .
RUN npm run build -- --configuration=production --output-path=dist

# Используем Nginx для сервинга приложения
FROM nginx:alpine
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/browser /usr/share/nginx/html

# Открываем порт 80
EXPOSE 80
