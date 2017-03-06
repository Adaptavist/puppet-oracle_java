# Installs Oracle Java
class oracle_java(
    $versions               = $oracle_java::params::versions,
    $default_ver            = $oracle_java::params::default_ver,
    $deb_ppa_repo           = $oracle_java::params::deb_ppa_repo,
    $ensure                 = $oracle_java::params::ensure,
    $install_java           = $oracle_java::params::install_java,
    $version_details        = $oracle_java::params::version_details,
) inherits  oracle_java::params {

    validate_array($versions)

    case $::osfamily{
        'RedHat': {
            $alt_names = {
                '6' => 'jdk1.6',
                '7' => 'jdk1.7',
                '8' => 'jdk1.8'
            }
        }
        'Debian': {
            $alt_names = {
                '6' => 'java-6-sun',
                '7' => 'java-7-oracle',
                '8' => 'java-8-oracle'
            }
            include apt
            package { 'python-software-properties': }
            apt::ppa { $deb_ppa_repo: }
            exec {
            'set-licence-selected':
              command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections';
            'set-licence-seen':
              command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections';
          }
        }
        default: {
            fail("oracle_java - Unsupported Operating System family: ${::osfamily}")
        }
    }

    $default_version = $default_ver ? {
        undef        => $versions[0],
        $default_ver => $default_ver
    }

    if member($versions, $default_version) {
        if $::osfamily == 'RedHat'{
            file { '/usr/lib/jvm':
                    ensure => directory,
                    owner  => 'root',
                    group  => 'root',
                    mode   => '0644',
            }
        }
        if (str2bool($install_java)){
            Oracle_java::Java_install<| |> -> Oracle_java::Set_default<| |>
            oracle_java::java_install { $versions:
                ensure    => $ensure,
                alt_names => $alt_names,
            }
        }

        oracle_java::set_default { $alt_names[$default_version]: }
    } else {
        err("Could not find default version '${default_version}' in versions to be installed.")
    }
}
