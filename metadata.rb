maintainer       "Metaworx Inc."
maintainer_email "pj@ezgr.net"
license          ""
description      "Installs/Configures chef-rundeck"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w{ ubuntu debian }.each do |os|
	supports os
end

depends 'java'
recommends 'nginx'
recommends 'supervisor'