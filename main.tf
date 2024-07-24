# main.tf

terraform {
  required_version = ">= 0.12"
  
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a Docker network
resource "docker_network" "app_network" {
  name = "app_network"
}

# Deploy MySQL container
resource "docker_container" "mysql" {
  name  = "mysql_db"
  image = "mysql:5.7"
  env = [
    "MYSQL_ROOT_PASSWORD=rootpassword",
    "MYSQL_DATABASE=mydatabase"
  ]
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Create a simple HTML page
resource "local_file" "index_html" {
  content = <<-EOF
  <html>
  <head><title>Welcome</title></head>
  <body><h1>Welcome to Terraform with Docker</h1></body>
  </html>
  EOF
  filename = "${path.module}/index.html"
}

# Deploy Nginx container
resource "docker_container" "nginx" {
  name  = "nginx_server"
  image = "nginx:latest"

  volumes {
    host_path      = abspath(local_file.index_html.filename)
    container_path = "/usr/share/nginx/html/index.html"
  }
  ports {
    internal = 80
    external = 8080
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
}

