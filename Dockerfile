# Используем официальный образ Node.js
FROM node:18 AS build

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и устанавливаем зависимости
COPY package.json package-lock.json ./

RUN npm install

# Копируем весь проект и собираем Angular-приложение
COPY . .
RUN npm run build -- --configuration=production --output-path=dist

# Используем Nginx для сервинга приложения
FROM nginx:alpine
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/browser /usr/share/nginx/html

# Открываем порт 80
EXPOSE 80
