terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "2.16.0"
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.2.0"
    }
  }
}

provider "random" {}
provider "docker" {}

resource "random_pet" "dbname" {}

resource "docker_image" "mongo" {
  name         = "mongo:latest"
  keep_locally = false
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.latest
  name  = random_pet.dbname.id
  ports {
    internal = 27017
    external = 27017
  }
}

output "mongo_url" {
  sensitive = true
  value     = "mongodb://localhost:${docker_container.mongo.ports[0].external}/${random_pet.dbname.id}"
}

output "mongo_dbname" {
  sensitive = true
  value     = random_pet.dbname.id
}
