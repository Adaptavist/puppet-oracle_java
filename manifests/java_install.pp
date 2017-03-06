define oracle_java::java_install(
    $alt_names,
    $ensure = 'present',
    ) {

    if ($name == '6' and $::operatingsystem == 'ubuntu' and $::operatingsystemrelease == '14.04') {
        $package_name='sun-java6-jre'
        package { $package_name:
            ensure  => $ensure,
        }
    } elsif ($::osfamily == 'Debian') {
        $package_name = "oracle-java${$name}-installer"
        package { $package_name:
            require => [Apt::Ppa[$oracle_java::deb_ppa_repo], Exec['set-licence-selected'], Exec['set-licence-seen']],
        }
    } else {
        $package_name=$name
        # get version defaults to pass to the oracle class
        $java_version_details = $oracle_java::version_details[$name]

        java::oracle { $package_name :
          ensure        => $ensure,
          version       => $name,
          java_se       => 'jdk',
          version_major => "${name}u${java_version_details['update_version']}",
          version_minor => "b${java_version_details['version_minor']}",
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
