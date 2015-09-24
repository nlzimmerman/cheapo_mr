class cheapo_mr::spark(
  $spark_master="172.17.0.10",
  $spark_workers=["172.17.0.11", "172.17.0.12"],
  $spark_version = "spark-1.5.0-bin-hadoop2.6"
  ) {

  $spark_tarball_location = "/home/${username}/${spark_version}.tgz"

  package {'java-1.8.0-openjdk': ensure => present, }
  # Could just update the alternatives. :)
  package {'java-1.7.0-openjdk': ensure => absent, }
  package {'wget': ensure => present }
  file { '/opt/spark':
    ensure => 'directory',
    owner => $username,
    group => $username,
    mode => '0644',
  }
  exec { 'download_spark_tarball':
    require => Package['wget'],
    command => "wget -q -O ${spark_tarball_location} http://d3kbcqa49mib13.cloudfront.net/${spark_version}.tgz",
    path => ['/usr/bin'],
    creates => $spark_tarball_location
  } ~>
  exec { 'extract_spark_tarball':
    require => File['/opt/spark'],
    command => "tar -C /opt/spark -xf ${spark_tarball_location}",
    path => ['/bin'],
    creates => "/opt/spark/${spark_version}/bin/pyspark",
  } ~>
  exec { 'chown_spark_dir':
    command => "chown -R ${username}:${username} /opt/spark/*",
    path => ['/bin'],
    refreshonly => true,
  }
  file { "/opt/spark/${spark_version}/conf/spark-env.sh":
    subscribe => Exec['chown_spark_dir'],
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0644',
    content => template("cheapo_mr/spark-env.sh.erb")
  }
  file{ "/opt/spark/${spark_version}/conf/slaves":
    subscribe => Exec['chown_spark_dir'],
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0644',
    content => template("cheapo_mr/spark_workers.erb")
  }
  file{ "/opt/spark/${spark_version}/conf/spark-defaults.conf":
    subscribe => Exec['chown_spark_dir'],
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0644',
    content => template("cheapo_mr/spark-defaults.conf.erb")
  }
  file { "/opt/spark/${spark_version}/conf/log4j.properties" :
    subscribe => Exec['chown_spark_dir'],
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0644',
    source => "puppet:///modules/cheapo_mr/log4j.properties"
  }
  file_line { "spark_home":
    path => "/home/${username}/.bashrc",
    ensure => present,
    line => "export SPARK_HOME=/opt/spark/${spark_version}",
    match => "^export SPARK_HOME=.*",
    replace => true,
  }
  file_line { "python_path":
    path => "/home/${username}/.bashrc",
    ensure => present,
    line => "export PYTHONPATH=/opt/spark/${spark_version}:/opt/spark/${spark_version}/python:/opt/spark/${spark_version}/python/lib/py4j-0.8.2.1-src.zip:\$PYTHONPATH",
    match => "^export PYTHONPATH=.*",
    replace => true,
  }
  file_line { "spark_path":
    path => "/home/${username}/.bashrc",
    ensure => present,
    line => "export PATH=/opt/spark/${spark_version}/bin:\$PATH",
    match => "^export PATH=.*spark.*",
    replace => true,
  }
}
