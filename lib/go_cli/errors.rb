module GoCLI
  class BadFileError < StandardError
    def initialize(filename=nil)
      message = "ERRNO: #{ERR::BAD_FILE} - Bad file"
      message += ": #{filename}" if filename
      super(message)
    end
  end

  class FileNotFoundError < IOError
    def initialize(filename=nil)
      message = "ERRNO: #{ERR::FILE_NOT_FOUND} - File not found"
      message += ": #{filename}" if filename
      super(message)
    end
  end

  module EXT
    SUCCESS = 0
    INTERRUPT = -1
  end

  module ERR
    FILE_NOT_FOUND = 1
    BAD_FILE = 2
    TOO_MANY_ATTEMPTS = 1
    LOGIN_ERROR = 3
  end
end