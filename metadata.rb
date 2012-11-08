maintainer       "Metaworx Inc."
maintainer_email "pj@ezgr.net"
license          ""
description      "Installs/Configures chef-rundeck"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%{ ubuntu debian }.each do |system|
	supports system
end

depends 'java'
recommends 'nginx'
recommends 'supervisor'