define oracle_java::set_default(){
    # Need to allow return code of 2 as the java packages don't provide everything that
    # update-alternatives is looking for...
    case $::osfamily{
        'RedHat': {
            $alternatives_command = "alternatives --set java /usr/java/$(ls /usr/java/ | grep ${name} | sort -V | tail -1)/bin/java"
            $alternatives_return_value = [0]
        }
        'Debian': {
            $alternatives_command = "update-java-alternatives -s ${name}"
            $alternatives_return_value = [0,2]
        }
        default: {
            fail("oracle_java - Unsupported Operating System family: ${::osfamily}")
        }
    }
    exec { "Set default Java version: ${name}":
        command  => $alternatives_command,
        returns  => $alternatives_return_value,
        provider => shell,
    }
}

