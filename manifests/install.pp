# == Class vault::install
#
class vault::install {
  $vault_bin = "${::vault::bin_dir}/vault"

  include ::zip

  case $::vault::install_method {
      'archive': {
        if $::vault::manage_download_dir {
          file { $::vault::download_dir:
            ensure => directory,
          }
        }
        archive { "vault-${$::vault::version}":
          ensure        => present,
          checksum      => $::vault::download_sha256 ? { undef => false, default => true, },
          digest_string => $::vault::download_sha256,
          digest_type   => 'sha256',
          extension     => 'zip',
          target        => $::vault::bin_dir,
          url           => $::vault::download_url,
          before        => File[$vault_bin],
          require       => Class['::zip'],
        }
      }

    'repo': {
      package { $::vault::package_name:
        ensure  => $::vault::package_ensure
      }
    }

    default: {
      fail("Installation method ${::vault::install_method} not supported")
    }
  }

  file { $vault_bin:
    owner => 'root',
    group => 'root',
    mode  => '0555',
  }

  if !$::vault::disable_mlock {
    exec { "setcap cap_ipc_lock=+ep ${vault_bin}":
      path      => ['/sbin', '/usr/sbin', '/bin', '/usr/bin', ],
      subscribe => File[$vault_bin],
      unless    => "getcap ${vault_bin} | grep cap_ipc_lock+ep",
    }
  }

  if $vault::manage_user {
    user { $::vault::user:
      ensure => present,
    }
    if $vault::manage_group {
      Group[$vault::group] -> User[$vault::user]
    }
  }
  if $vault::manage_group {
    group { $::vault::group:
      ensure => present,
    }
  }
}
