module GoCLI
  module Utils
    extend self
    def load_file(filename)
      begin
        result = YAML.load_file(filename)
        raise LoadError, "(ERRNO: #{ERR::BAD_FILE}) Bad file: #{filename}" unless result
        result
      rescue Errno::ENOENT => err
        raise FileNotFoundError, filename
      end
    end

    def write_file(object, filename)
      File.read(filename) rescue File.new(filename, "w")
      contents = YAML.dump(object)
      File.write(filename, contents)
    end

    def load_yml_file(filename)
      begin
        result = YAML.load_file(filename)
        raise LoadError, "(ERRNO: #{ERR::BAD_FILE}) Bad file: #{filename}" unless result
        result
      rescue Errno::ENOENT => err
        raise FileNotFoundError, filename
      end
    end

    def write_yml_file(object, filename)
      File.read(filename) rescue File.new(filename, "w")
      contents = YAML.dump(object)
      File.write(filename, contents)
    end
  end
end