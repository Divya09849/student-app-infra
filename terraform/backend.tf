terraform {
  backend "s3" {
    bucket       = "student-app-tfstate-12345"
    key          = "student-gitops/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}