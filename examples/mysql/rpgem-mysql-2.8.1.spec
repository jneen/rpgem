
%define rbname mysql

Name:		rpgem-%{rbname}
Version:  2.8.1
Release:	1%{?dist}
Summary:	This is the MySQL API module for Ruby

Group: Development/Languages/Ruby
License:  #FIXME - this gem has an unspecified license!
URL:  http://mysql-win.rubyforge.org
Source0:  %{_sourcedir}/%{rbname}-%{version}.gem
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Vendor: TOMITA Masahiro

BuildRequires: ruby, rubygems
Requires:	ruby, rubygems, mysql > 5.0, mysql-devel

Prefix: /usr

%define gem_prefix %{prefix}/lib/gems/%(%{prefix}/bin/ruby -e "puts VERSION.split('.')[0..1].join('.')")

%description
This is the MySQL API module for Ruby. It provides the same functions for Ruby
programs that the MySQL C API provides for C programs.

This is a conversion of tmtm's original extension into a proper RubyGems.

%prep
#noop

%build
rm -rf $RPM_BUILD_ROOT
mkdir $RPM_BUILD_ROOT
%{prefix}/bin/gem install %{SOURCE0} --force --local --no-rdoc --no-ri --install-dir=.

%install

echo %{gem_prefix}
rm -rf $RPM_BUILD_ROOT%{gem_prefix}
mkdir -p $RPM_BUILD_ROOT%{gem_prefix}
mv * $RPM_BUILD_ROOT%{gem_prefix}
chmod -R 0755 $RPM_BUILD_ROOT%{gem_prefix}

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{gem_prefix}/gems/%{rbname}-%{version}/
%{gem_prefix}/specifications/%{rbname}-%{version}.gemspec
%{gem_prefix}/cache/%{rbname}-%{version}.gem



%changelog
