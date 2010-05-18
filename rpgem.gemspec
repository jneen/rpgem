spec = Gem::Specification.new do |s|
  s.name = 'rpgem'
  s.version = '0.1.2'
  s.summary = "A gem-to-rpm converter, done right."
  s.homepage = 'http://github.com/jayferd/rpgem'
  s.authors = 'Jay Adkisson'
  s.email = 'jay@causes.com'
  s.licenses = "MIT"

  s.description = <<-desc.strip.gsub(/\s+/,' ')
    RPGem will create a binary RPM with the compiled extensions,
    which you can install on a machine painlessly.
  desc

  s.required_rubygems_version = '>= 1.3.6'
  s.add_dependency 'erubis'
  s.requirements = ['rpmbuild']

  s.files = ['lib/rpgem.rb', 'lib/template.spec.erb', 'bin/rpgem']
  s.executables = ['rpgem']
end
