module GoCLI
  module Utils
    extend self
    def load_file(filename)
      begin
        result = YAML.load_file(filename)
        raise LoadError, "(ERRNO: #{ERR::BAD_FILE}) Bad file: #{filename}" unless result
      rescue Errno::ENOENT => err
        raise FileNotFoundError, filename
      end
    end
  end
end