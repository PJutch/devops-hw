resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx"

  ports {
    internal = 80
    external = var.host_port
  }

  volumes {
    host_path      = var.html_path
    container_path = "/usr/share/nginx/html/index.html"
  }

  networks_advanced {
    name = docker_network.nginx_net.name
  }
}

resource "docker_network" "nginx_net" {
  name = "nginx-net"
}

