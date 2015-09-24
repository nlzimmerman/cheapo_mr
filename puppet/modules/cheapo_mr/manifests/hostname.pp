class cheapo_mr::hostname(
  $hostname,
  $spark_master="172.17.0.10",
  $spark_workers=["172.17.0.11", "172.17.0.12"],
  ) {
  $lockfilename = "/var/run/hostname.set"
  file {'/etc/sysconfig/network':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => template("cheapo_mr/network.erb")
  }
  exec { 'set_hostname':
    command => "echo ${hostname} | tee /proc/sys/kernel/hostname",
    path => ['/bin','/usr/bin'],
    unless => "test -f ${lockfilename}"
  } ~>
  file {'hostname_set': path => $lockfilename, ensure => present}
  file { '/etc/hosts':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => template("cheapo_mr/hosts.erb")
  }
  file { "/home/${username}/.ssh/id_rsa" :
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0600',
    source => "puppet:///modules/cheapo_mr/internal_key"
  }
  file {"/home/${username}/.ssh/id_rsa.pub" :
    ensure => present,
    owner => $username,
    group => $username,
    mode => '0600',
    source => "puppet:///modules/cheapo_mr/internal_key.pub"
  }
  ssh_authorized_key { 'internal_key':
    ensure => present,
    user => $username,
    options => 'from="172.17.0.0/24"',
    type => "ssh-rsa",
    key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDTFxyX1MkRYXD7dQHgbwsCenKXdIrCTffYI3P8QKlVankGFHWsw2QadjoVEfcnDL+tGOoUu86TCo6vQ8bdj/9XYgAHDFBM3i+WVZtdkdhS6empbX+VIu9ac+Fxf/XGc1ktEAgtcZKi+D9r0eesQ23gwvAcNp6q/zj79M+pLQIFkkHxTA5yK5WFEOsY5rNXISPSLuwzAzIwR+rOil67V74nERRm3H8jzcn0QLqasxImSxJzf8ZwGP27FW7M7+zzrgDO1plyTwrEo916gZC6I01lpqJIISA+VckFucrhVeKFVRPU0bugKdcxjZXrvWH/NjWoxKSB96eOUp6eEimhTmAd"
  }
}
