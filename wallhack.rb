require 'byebug'

class WallHack
  def self.instance
    @instance ||= self.new
  end

  def initialize
    @bins = []

    Dir.pwd.split("/").reduce do |path, this_folder|
      path += "/" + this_folder
      if File.exists?(path + "/Gemfile")
        if File.readlines("Gemfile").find { |l| l[/[.]*gem[\s]+['|"]wallhack['|"]/] }
          @project_folder = path

          add_bin_commands
        end
      end

      path
    end
  end

  attr_reader :project_folder

  def active_project?
    !!project_folder
  end

  def c_new
    if active_project?
      raise "Can't initialize a new WallHack application within the directory of another, please change to a non-WallHack directory first."
    end
    # mkdir

    # build all the stuff

    # do the things
  end

  def add_bin_commands
    Dir.glob(project_folder + '/bin/*.rb').each do |bin|
      without_extension = bin.split("/")[-1][0..-4]
      # self.class.define_method(("c_" + without_extension).to_sym) { system("ruby #{bin}") }
      @bins.push(["c_" + without_extension, bin])
    end
  end

  def method_missing(name, *args, &block)

    if name.to_s.start_with?("c_")
      bin = @bins.find { |(bin_name, thing)| bin_name == name.to_s }

      system("ruby '#{bin[1]}'") if bin
    else
      super
    end
  end
end

if !ARGV.length
  puts "Terrible wrongness!\n wallhack needs instructions!"
else
  p WallHack.instance.send(("c_" + ARGV.shift).to_sym)
end
