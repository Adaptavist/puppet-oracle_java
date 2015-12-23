# Installs Oracle Java
class oracle_java(
    $versions = [ 7 ],
    $default_ver = undef
){

    validate_array($versions)

    case $::osfamily{
        RedHat: {
            $available = {
                6 => 'jdk-1.6*',
                7 => 'jdk-1.7*',
                8 => 'jdk1.8*'
            }

            $alt_names = {
                6 => 'jdk1.6',
                7 => 'jdk1.7',
                8 => 'jdk1.8'
            }
        }
        Debian: {
            $available = {
                6 => 'sun-java6-jdk',
                7 => 'oracle-java7-jdk',
                8 => 'oracle-java8-jdk'
            }

            $alt_names = {
                6 => 'java-6-sun',
                7 => 'java-7-oracle',
                8 => 'java-8-oracle'
            }
        }
    }

    $default_version = $default_ver ? {
        undef        => $versions[0],
        $default_ver => $default_ver
    }

    if member($versions, $default_version) {
        oracle_java::java_install { $versions:
            available => $available,
            alt_names => $alt_names,
        }
        ->
        oracle_java::set_default { $alt_names[$default_version]: }
    } else {
        err("Could not find default version '$default_version' in versions to be installed.")
    }
}
