module GoCLI
  class BadFileError < RuntimeError
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

  class AuthenticationError < RuntimeError
    def initialize(msg = nil)
      message = "ERRNO: #{ERR::AUTHENTICATION_ERROR} - Authentication error"
      message += ": #{msg}" if msg
      super(message)
    end
  end

  module EXT
    SUCCESS = 0
    FAILURE = -1
  end

  module ERR
    FILE_NOT_FOUND = 1
    BAD_FILE = 2
    TOO_MANY_ATTEMPTS = 3
    AUTHENTICATION_ERROR = 4
  end
end