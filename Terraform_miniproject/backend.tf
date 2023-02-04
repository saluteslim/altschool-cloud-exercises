terraform {
  backend "s3" {
    bucket = "teslim-s3terra"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}
