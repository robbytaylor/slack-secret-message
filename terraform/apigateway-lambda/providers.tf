provider "aws" {}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}
