output "db_pass" {
  value = random_password.adminpassword.result[*]
}