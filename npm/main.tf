terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "2.16.0"
    }

    dreampoc = {
      source  = "novopattern.com/dream/dreampoc"
      version = "0.0.1"
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.2.0"
    }
  }
}

provider "docker" {}

provider "dreampoc" {
  // cwd will be set from env var DREAM_CWD
}

provider "random" {}

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

resource "dreampoc_env" "env" {
  id   = "mongo"
  vars = [
    {
      key   = "url"
      value = "mongodb://localhost:${docker_container.mongo.ports[0].external}/${random_pet.dbname.id}"
    },
    {
      key   = "dbname"
      value = random_pet.dbname.id
    }
  ]
}

resource "dreampoc_npm" "pkgs" {
  packages = [
    {
      name    = "mongoose"
      version = "^6.3.3"
    },
    {
      name    = "@novodream/dream-mongo-poc"
      version = "^0.2.0"
    }
  ]
}

