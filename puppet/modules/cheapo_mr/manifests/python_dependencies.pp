class cheapo_mr::python_dependencies {
  package { ['gcc', 'gcc-c++'] : ensure => present, } ->
  package { 'pandas':
    ensure => present,
    provider => pip
  }
}
