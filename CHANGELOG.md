# CHANGELOG for chef-rundeck

This file is used to list changes made in each version of chef-rundeck.

## 0.3.5

* Bump Rundeck version

## 0.3.4

* Custom properties support for framework and project properties files
* Added chef-rundeck cache timeout
* Added chef-rundeck SSL verify mode

## 0.3.3

* Rundeck version bump
* Various JVM fixes
* Added URL attribute to support Rundeck running behind a reverse proxy
* Added support for external databases (PR #14)
* Added support for SMTP mail authentication (PR #13)
* Allow the rundeck profile to set authentication file and name via attributes

## 0.3.2

* Move stub file array to an attribute to allow control from wrapper cookbooks.
* Added the "hostname" attribute
* Removed the aggressive JVM optimization option

## 0.3.0

* Logic change on admin data bag and Chef credentials fetching
* Moved chef-rundeck gem to the official one
* Implemented plugin LWRP
* Fixed double startup issue with Upstart supporting systems
* Made Rundeck hostname configurable

## 0.2.1

* Version bump to Rundeck
* Fixed stub user creation issue
* Added update action along with create action on admin user (resolves #6)
* Added apt/yum recipe inclusion (resolves #7)
* Fixed outdated jaas module declaration (resolves #8)
* Added partial search support

## 0.2.0:

* Version bump to Rundeck
* Added support for encrypted data bags
* Doc updates
* Added support for RHEL distros
* Various bugfixes

## 0.1.0:

* Initial release of chef-rundeck
