$username = "ec2-user"
class { cheapo_mr::spark:
  spark_workers => ["172.17.0.11"]
}
class { cheapo_mr::hostname: hostname => "spark-master" }
class { cheapo_mr::python_dependencies: }
