# Puppet module for Java installation

* Allows installation of multiple versions of Java (defaults to oracle-7-jdk, supports sun-6-jdk also)
* Uses Adaptavist repo
* Can specify default Java version (defaults to the first version installed)

Make sure you register repository where oracle java packages are located.

# Java 6

Ubuntu 14.04 has a new package 'apt' which is specified as (breaking)[http://debian-handbook.info/browse/stable/sect.package-meta-information.html] sun-java6-jdk.

It is therefore not possible to install sun-java6-jdk successfully on Ubuntu 14.04, and instead, sun-java6-jre will be installed.

# Examples

```
class { 'oracle_java':
  versions => [6, 7]
}

class { 'oracle_java':
  versions    => [6, 7, 8],
  default_ver => 8
}
```
