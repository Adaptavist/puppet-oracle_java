define oracle_java::java_install($available, $alt_names, $ensure = 'latest') {
    $package_name=$available[$name]
    if has_key($available, $name) {
        if ($name == '6' and $::operatingsystem == 'ubuntu' and $::operatingsystemrelease == '14.04') {
            package { 'sun-java6-jre':
                ensure  => installed,
            }
        } else {
            package {
                $package_name:
                    ensure => $ensure,
            }
        }

        if $::osfamily == 'RedHat'{
            $alt_name = $alt_names[$name]
            $alt_cmd_java="alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.${name})/bin/java 200000"
            $alt_cmd_javac="alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.${name})/bin/javac 200000"
            exec { "Install alternatives for java ${name}":
                command  => $alt_cmd_java,
                provider => shell,
                require  => Package[$package_name],
            } ->
            exec { "Install alternatives for javac ${name}":
                command  => $alt_cmd_javac,
                provider => shell,
            }
            exec { "Create symlink for jdk in /var/lib/jvm/jdk${name}":
                command  => "ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.${name}) /usr/lib/jvm/jdk${name}",
                provider => shell,
                require  => Package[$package_name],
            }
        }

    } else {
        warn("Could not find available version '${name}' for installation.")
    }
}
