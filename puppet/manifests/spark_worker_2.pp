$username = "ec2-user"
class { cheapo_mr::spark: }
class { cheapo_mr::hostname: hostname => "spark-worker-2" }
class { cheapo_mr::python_dependencies: }
