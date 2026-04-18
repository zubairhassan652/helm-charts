# Use a lightweight Python base image
FROM python:3.12-slim

# Set a working directory for the app
WORKDIR /app

# Prevent Python from writing pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies needed for Django and package installation
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency definitions and install Python packages
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy the entire project into the image
COPY . /app

# Expose the default Django port
EXPOSE 8000

# Use Gunicorn to serve the Django app
CMD ["gunicorn", "helm_charts.wsgi:application", "--bind", "0.0.0.0:8000"]
