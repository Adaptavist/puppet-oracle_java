define oracle_java::java_install($alt_names, $ensure = 'present') {
    
    if ($name == '6' and $::operatingsystem == 'ubuntu' and $::operatingsystemrelease == '14.04') {
        $package_name='sun-java6-jre'
        package { $package_name:
            ensure  => $ensure,
        }
    } elsif ($::osfamily == 'Debian') {
        file { "/tmp/java${$name}.preseed":
            content => "oracle-java${$name}-installer shared/accepted-oracle-license-v1-1 select true oracle-java${$name}-installer shared/accepted-oracle-license-v1-1 seen true",
            mode    => '0600',
            backup  => false,
        }
        $package_name = "oracle-java${$name}-installer"
        package { $package_name:
            responsefile => "/tmp/java${$name}.preseed",
            require      => [Apt::Ppa['ppa:webupd8team/java'], File["/tmp/java${$name}.preseed"]],
        }
    } else {
        $package_name=$name
        java::oracle { $package_name :
          ensure  => $ensure,
          version => $name,
          java_se => 'jdk',
        }
    }

    if $::osfamily == 'RedHat'{
        $alt_name = $alt_names[$name]
        $alt_cmd_java="alternatives --install /usr/bin/java java /usr/java/$(ls /usr/java/ | grep jdk1.${name} | sort | tail -1)/bin/java 200000"
        $alt_cmd_javac="alternatives --install /usr/bin/javac javac /usr/java/$(ls /usr/java/ | grep jdk1.${name} | sort | tail -1)/bin/javac 200000"
        exec { "Install alternatives for java ${name}":
            command  => $alt_cmd_java,
            provider => shell,
            require  => Java::Oracle[$package_name],
        } ->
        exec { "Install alternatives for javac ${name}":
            command  => $alt_cmd_javac,
            provider => shell,
        }
        exec { "Create symlink for jdk in /var/lib/jvm/jdk${name}":
            command  => "ln -sf /usr/java/$(ls /usr/java/ | grep jdk1.${name} | sort | tail -1) /usr/lib/jvm/jdk${name}",
            provider => shell,
            require  => [Java::Oracle[$package_name], File['/usr/lib/jvm']]
        }
    }
}
