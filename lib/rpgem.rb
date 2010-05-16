require 'fileutils'
require 'rubygems'
require 'rubygems/format'
require 'erb'

module FileUtils
  def self.in_dir(dir)
    cwd = `pwd`.strip
    cd dir
    r = yield
    cd cwd
    r
  end
end

class Hash
  # like merge!, but doesn't update existing keys.
  # useful for defaulting options
  def rmerge!(hsh)
    hsh.each do |k,v|
      self[k] = v unless self.has_key? k
    end
  end

  def rmerge(hsh)
    self.dup.rmerge!(hsh)
  end
end

class << File
  def write(fname, str)
    self.open(fname, "w") do |f|
      f.write str
    end
  end
end

LIB_DIR = File.expand_path(File.dirname(__FILE__))


class RPGem
  HOME_DIR = `echo ~`.strip
  CWD = `pwd`.strip
  TMP = "/tmp/rpgem"
  RPMBUILD_DIR = "#{HOME_DIR}/rpmbuild"
  SOURCES_DIR = "#{RPMBUILD_DIR}/SOURCES"
  SPECS_DIR = "#{RPMBUILD_DIR}/SPECS"

  def initialize(name, options={})
    @name = name
    options.rmerge!({
      :version => nil,
      :version_reqs => [],
      :recursive => false,
      :ruby_cmd => "ruby"
    })
    options.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  def sh_version_reqs
    @version_reqs.map do |r|
      "--version '#{r}'"
    end.join ' '
  end

  attr_reader :name, :version

  def to_s
    if @version.nil?
      @name
    else
      "#{@name}-#{@version}"
    end
  end

  def gem_loc
    "#{SOURCES_DIR}/#{self.to_s}.gem"
  end

  def spec_loc
    "#{SPECS_DIR}/rpgem-#{self.to_s}.gem"
  end

  def format
    @format ||= Gem::Format.from_file_by_path(gem_loc)
  end

  def spec
    @spec ||= format.spec
  end

  def fetched_version(name_or_dep, requirements=[])
    if name_or_dep.is_a? Gem::Dependency
      d = name_or_dep
    else
      d = Gem::Dependency.new(name_or_dep, requirements)
    end

    currents = `ls #{SOURCES_DIR} | grep '^#{d.name}'`.split($/)
    return false if currents.empty?

    currents.each do |c|
      ver = c.match(/-(\d+(\.\d+)+)\.gem$/)[1]
      return ver if d.match?(d.name, ver)
    end
    return nil
  end

  def fetched?
    return File.exists?(self.gem_loc)
  end

  def fetch!
    v = self.fetched_version(@name, @version_reqs)
    if (@version.nil? && v) || (!@version.nil? && self.fetched?)
      @version = v
      puts "Skipping fetch of #{self.to_s}"
    else
      puts "Fetching the gem #{self.to_s}"
      if @version.nil?
        system("rm -rf #{TMP}")
        system("mkdir #{TMP}")
        FileUtils.in_dir TMP do
          system("gem fetch #{@name} #{sh_version_reqs}")
          gem_title = `ls`
          @version = gem_title.match(/-(\d+(\.\d+)+)\.gem$/)[1]
        end
        system("mv #{TMP}/* #{SOURCES_DIR}/")
      else
        FileUtils.in_dir SOURCES_DIR do
          system("gem fetch #{@name} --version #{@version}")
        end
      end
    end
  end

  def make_spec!
    fetch!
    puts "rendering the specfile..."
    template = File.read("#{LIB_DIR}/template.spec.erb")
    specfile = ERB.new(template).result(binding)
    puts "rendered:"
    puts "==============="
    puts specfile
    puts "==============="
    File.write(spec_loc, specfile)
    puts "rendered to #{spec_loc}"
  end

  def build!
    fetch!
    make_spec!

    puts "-*- Building RPM -*-"
    FileUtils.in_dir RPMBUILD_DIR do
      system("rpmbuild -vv -ba #{spec_loc}")
    end
    puts "-*- Done Building RPM -*-"
  end

  def setup!
    fetch!
    make_spec!
    build!
  end

  def recurse!(action=:setup!)
    #TODO: add an option for dev dependencies
    deps = self.spec.runtime_dependencies
    deps.each do |d|
      if !fetched?(d)
        g = self.class.new(d.name,
          :version_reqs => d.requirements_list,
          :recursive => true
        )
        g.send(action)
        g.recurse!(action)
      end
    end
  end
end
