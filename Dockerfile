# Stage 1: Build the Flutter web application
FROM debian:bullseye-slim AS build-env

# Instalar apenas dependências estritamente necessárias para a web (evita sobrecarregar o espaço em disco)
RUN apt-get update && \
    apt-get install -y curl git wget unzip ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clonar o repositório do Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable

# Configurar o path do Flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Habilitar suporte a web
RUN flutter config --enable-web

# Configurar o diretório de trabalho
WORKDIR /app

# Copiar os arquivos de manifesto e baixar as dependências
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
