require 'fileutils'
require 'rubygems'
require 'rubygems/format'

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


class RPGem
  CWD = `pwd`.strip
  TMP = "#{CWD}/tmp"
  BUILD = "#{CWD}/rpmbuild"

  def initialize(name, options={})
    options.rmerge!({
      :version => nil,
      :version_reqs => [],
      :recursive => false
    })

    @name = name
    @version_reqs = options[:version_reqs]
    @version = options[:version]
    @recursive = options[:recursive]
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

  def sources_dir
    "#{BUILD}/SOURCES"
  end

  def gem_loc
    "#{sources_dir}/#{self.to_s}.gem"
  end

  def format
    Gem::Format.from_file_by_path(gem_loc)
  end

  def spec
    format.spec
  end

  def req_satisfied?(name_or_dep, requirements=nil)
    current = `ls #{sources_dir} | grep '^#{d.name}' | head -1`
    return false if current.empty?

    if name_or_dep.is_a? Gem::Dependency
      d = name_or_dep
    else
      d = Gem::Dependency.new(name_or_dep, requirements)
    end
    d.match?(d.name, current.match(/-(\d+(\.\d+)+)\.gem$/)[1])
  end

  def fetched?
    if @version
      return File.exists? self.gem_loc
    else if !@version_reqs.empty?
      return @version_reqs.all? do |r|
        req_satisfied? @name, r
      end
    end
  end

  def fetch!
    if self.fetched?
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
        system("mv #{TMP}/* #{sources_dir}/")
      else
        FileUtils.in_dir sources_dir do
          system("gem fetch #{@name} --version #{@version}")
        end
      end
    end
  end

  def make_spec!
    #generate specfile
  end

  def build!
    #rpmbuild
  end

  def recurse!(options={})
    #TODO: add an option for dev dependencies
    deps = self.spec.runtime_dependencies
    deps.each do |d|
      if !satisfied?(d)
        self.class.new(d.name,
          :version_reqs => d.requirements_list,
          :recursive => true
        ).setup!
      end
    end
  end

  def setup!
    fetch!
    make_spec!
    build!
    recurse! if @recursive
  end
end
