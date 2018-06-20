require_relative 'lib/world'
require_relative 'lib/user'
require_relative 'lib/driver'
require_relative 'lib/trip'
require_relative 'lib/user_session'
require_relative 'lib/app_session'
require_relative 'lib/cli.rb'
require 'optparse'

options = {}

GoCLI::CLI.new.start(options)