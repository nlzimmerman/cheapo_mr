output "primary_ip" {
  value = "${aws_instance.spark_master.public_ip}"
}
