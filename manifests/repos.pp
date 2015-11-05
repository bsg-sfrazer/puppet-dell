# == Class: dell::repo
#
# This configures the dell package repositories
#
# === Parameters
#
# [*sample_parameter*]
#
# === Variables
#
# [*sample_variable*]
#
# === Examples
#
#  class { 'dell::repos': }
#
class dell::repos() inherits dell::params {

  case $::osfamily {
    'Debian' : {
      $l_lsbdistid = downcase($::lsbdistid)
      # Dell APT Repos
      apt::key { 'dell-community':
        key        => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
        key_server => 'pool.sks-keyservers.net',
      }

      apt::source { 'dell-community':
        location          => "http://linux.dell.com/repo/community/${l_lsbdistid}",
        release           => '',
        repos             => "${lsbdistcodename} openmanage",
        include_src       => false,
      }

    }
    'RedHat' : {
      ########################################
      # Create the two repos
      ########################################

      if $::osfamily == 'RedHat'{
        if $::operatingsystemmajrelease < 7 {
          yumrepo { 'dell-omsa-indep':
            descr          => 'Dell OMSA repository - Hardware     independent',
            enabled        => 1,
            mirrorlist     => $dell::params::repo_indep_mirrorlist,
            gpgcheck       => 1,
            gpgkey         => $dell::params::repo_indep_gpgkey,
            failovermethod => 'priority',
          } -> package { 'yum-dellsysid':  # I dislike this syntax, but     require would not work for some reason...
            ensure  => 'present',
          }
        }
      }

      yumrepo { 'dell-omsa-specific':
        descr          => 'Dell OMSA repository - Hardware specific',
        enabled        => 1,
        mirrorlist     => $dell::params::repo_specific_mirrorlist,
        gpgcheck       => 1,
        gpgkey         => $dell::params::repo_specific_gpgkey,
        failovermethod => 'priority',
      }


      ########################################
      # GPG-KEY Management
      ########################################
      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-dell':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/dell/RPM-GPG-KEY-dell',
      }
      exec { 'dell-RPM-GPG-KEY-dell':
        command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-dell',
        subscribe   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-dell'],
        refreshonly => true,
      }

      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/dell/RPM-GPG-KEY-libsmbios',
      }
      exec { 'dell-RPM-GPG-KEY-libsmbios':
        command     => '/bin/rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios',
        subscribe   => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-libsmbios'],
        refreshonly => true,
      }

    }
  }
}

