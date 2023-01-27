variable "name" {
    type = string
    default = "Devsecops"
}
variable "artifacts_bucket_name" {
    type = string
    default = "codepipelinedevsecopspoc"
}
variable "repository_branch" {
    type = string
    default = "master"
}
variable "repository_owner" {
    type = string
    default = "Devops"
}
variable "repository_name" {
    type = string
    default = "Devsecops"
}
variable "sonartoken" {
  description = "The token generated from sonarqube"
  type        = string
}
variable "sonarurl" {
  description = "Enter sonarqube url"
  type        = string
}
variable "protocol" {
  description = "ebs url protocol"
  default = "http://"
}
