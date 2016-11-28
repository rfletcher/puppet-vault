# == Class vault::params
#
# This class is meant to be called from vault.
# It sets variables according to platform.
#
class vault::params {
  $user               = 'vault'
  $manage_user        = true
  $group              = 'vault'
  $manage_group       = true
  $bin_dir            = '/usr/local/bin'
  $config_dir         = '/etc/vault'
  $version            = '0.6.2'
  $download_sha256    = '91432c812b1264306f8d1ecf7dd237c3d7a8b2b6aebf4f887e487c4e7f69338c'
  $download_url       = "https://releases.hashicorp.com/vault/${version}/vault_${version}_linux_amd64.zip"
  $service_name       = 'vault'
  $num_procs          = $::processorcount
  $install_method     = 'archive'
  $package_name       = 'vault'
  $package_ensure     = 'installed'

  $download_dir        = '/tmp'
  $manage_download_dir = false

  # backend and listener are mandatory, we provide some sensible
  # defaults here
  $backend             = { 'file' => { 'path' => '/var/lib/vault' }}
  $manage_backend_dir  = false
  $listener            = {
    'tcp' => {
      'address' => '127.0.0.1:8200',
      'tls_disable' => 1,
    }
  }

  # These should always be undef as they are optional settings that
  # should not be configured unless explicitly declared.
  $ha_backend         = undef
  $disable_cache      = undef
  $telemetry          = undef
  $default_lease_ttl  = undef
  $max_lease_ttl      = undef
  $disable_mlock      = undef

  case $::osfamily {
    'Debian': {
      $service_provider = 'upstart'
    }
    'RedHat': {
      if ($::operatingsystemmajrelease == '6' or $::operatingsystem == 'Amazon') {
        $service_provider = 'redhat'
      } else {
        $service_provider = 'systemd'
      }
    }
    default: {
      fail("Module ${module_name} is not supported on osfamily '${::osfamily}'")
    }
  }
}
