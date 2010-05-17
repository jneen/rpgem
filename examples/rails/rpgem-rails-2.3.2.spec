
%define rbname rails

Name:		rpgem-%{rbname}
Version:  2.3.2
Release:	1%{?dist}
Summary:	Web-application framework with template engine, control-flow layer, and ORM.

Group: Development/Languages/Ruby
License:  #FIXME - this gem has an unspecified license!
URL:  http://www.rubyonrails.org
Source0:  %{_sourcedir}/%{rbname}-%{version}.gem
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Vendor: David Heinemeier Hansson

BuildRequires: ruby, rubygems
Requires:	ruby, rubygems, rpgem-rake >= 0.8.3, rpgem-activesupport = 2.3.2, rpgem-activerecord = 2.3.2, rpgem-actionpack = 2.3.2, rpgem-actionmailer = 2.3.2, rpgem-activeresource = 2.3.2

Prefix: /opt

%define gem_prefix %{prefix}/lib/gems/%(%{prefix}/bin/ruby -e "puts VERSION.split('.')[0..1].join('.')")

%description
Rails is a framework for building web-application using CGI, FCGI, mod_ruby, or WEBrick on top of either MySQL, PostgreSQL, SQLite, DB2, SQL Server, or Oracle with eRuby- or Builder-based templates.

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

%{gem_prefix}/bin/rails



%changelog
