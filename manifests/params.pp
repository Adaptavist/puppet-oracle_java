# provides default params
class oracle_java::params {
    $versions               = [ '7' ]
    $default_ver            = undef
    $deb_ppa_repo           = 'ppa:webupd8team/java'
    $ensure                 = 'present'
    $install_java           = true
    $version_details = {
        '6' => { 'update_version' => '45', 'version_minor' => 'b06' },
        '7' => { 'update_version' => '80', 'version_minor' => 'b15' },
        '8' => { 'update_version' => '51', 'version_minor' => 'b16' }
    }
}