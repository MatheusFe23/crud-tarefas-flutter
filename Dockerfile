# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos de manifesto e baixar as dependências (melhora o cache do Docker)
COPY pubspec.* ./
RUN flutter pub get

# Copiar o restante dos arquivos da aplicação
COPY . .

# Fazer o build da versão web da aplicação
RUN flutter build web

# Stage 2: Servir a aplicação usando Nginx
FROM nginx:alpine

# Copiar os arquivos gerados no stage de build para a pasta padrão do Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expor a porta 80
EXPOSE 80

# Iniciar o servidor Nginx
CMD ["nginx", "-g", "daemon off;"]
