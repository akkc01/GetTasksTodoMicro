FROM python:3.9-slim

WORKDIR /app

COPY . .

# Install required tools
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    unixodbc \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft GPG key (modern method)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Add repo (auto-detect Debian version)
RUN echo "deb [arch=arm64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Install ODBC driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Install Python deps
RUN pip install --no-cache-dir -r requirements.txt

# Run app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]