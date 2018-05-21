class voyager {
	
	package { 'vim':
		ensure => installed,
		allow_virtual => true,
		before => Package['curl'],
	}

	package { 'curl':
		ensure => installed,
		allow_virtual => true,
		before => Package['git'],
	}

	package { 'git':
		ensure => installed,
		allow_virtual => true,
		before => User['monitor'],
	}

	user { 'monitor':
 		ensure           => 'present',
  		gid              => '501',
  		home             => '/home/monitor',
  		password         => '!!',
  		password_max_age => '99999',
  		password_min_age => '0',
  		shell            => '/bin/bash',
  		uid              => '501',
		before => File['/home/monitor/','/home/monitor/scripts'],
	}

	file { ['/home/monitor/','/home/monitor/scripts']:
		ensure => directory,
		mode => '0744',
		before => Exec['getmemcheck'],
	}

	exec { 'getmemcheck':
		command => '/usr/bin/wget https://github.com/rowellilog/voyager-exercises/raw/master/memory_check -O /home/monitor/scripts/memory_check',
		before => File['/home/monitor/scripts/memory_check'],		
	}

	file { '/home/monitor/scripts/memory_check':
		ensure => present,
		mode => '0744',
		before => File['/home/monitor/src'],
	}

	file { '/home/monitor/src':
		ensure => directory,
		mode => '0744',
		before => File ['/home/monitor/src/my_memory_check'],
	}

	file { '/home/monitor/src/my_memory_check':
		ensure => link,
		target => '/home/monitor/scripts/memory_check',
		before => Cron['run_mem_check'],
	}

	cron { 'run_mem_check':
		command => '/home/monitor/src/my_memory_check -c 90 -w 80 -e rowell.ilog@gmail.com',
		user => 'root',
		minute => 10,
		before => File['/etc/localtime'],
	}

	file { '/etc/localtime':
		ensure => '/usr/share/zoneinfo/Asia/Manila',
		before => Exec['set_hostname'],
	}
	
	exec { 'set_hostname':
		command => "/bin/sed -i.bak '/HOSTNAME/ s/^.*$/HOSTNAME=bpx.server.local/' /etc/sysconfig/network",
	}

}

class { 'voyager': }
