#!/usr/bin/env ruby

require 'rubygems'
require 'rubygems/format'

class String
  def map_lines(&blk)
    split($/).map(&blk).join($/)
  end
end

gem_loc = ARGV[0]
format = Gem::Format.from_file_by_path(gem_loc)
spec = format.spec

puts <<-rpm.map_lines { |l| l.strip }
  %define rbname #{spec.name}
  %define local_gems_dir /tmp/rpgems

  Name:		rpgem-%{rbname}
  Version:  #{spec.version.to_s}
  Release:	1%{?dist}
  Summary:	#{spec.summary || spec.description}


  Group: MyCoolGroup
  License:  MIT
  URL:  #{spec.homepage}
  Source0:  %{_sourcedir}/%{rbname}-%{version}.gem
  BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

  BuildRequires: ruby, rubygems
  Requires:	ruby

  %description
  #{spec.description}


  %prep
  #noop

  %build
  gem install %{SOURCE0} --no-rdoc --no-ri --install-dir=.

  %install
  rm -rf $RPM_BUILD_ROOT
  mkdir -p $RPM_BUILD_ROOT%{local_gems_dir}
  mv * $RPM_BUILD_ROOT%{local_gems_dir}/
  #TODO: bin
  chmod -R 0755 $RPM_BUILD_ROOT%{local_gems_dir}

  %clean
  rm -rf $RPM_BUILD_ROOT


  %files
  %defattr(-,root,root,-)
  %{local_gems_dir}/gems/%{rbname}-%{version}/
  %{local_gems_dir}/specifications
  %{local_gems_dir}/cache/%{rbname}-%{version}.gem


  %changelog
rpm
