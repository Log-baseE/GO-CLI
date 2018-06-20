require_relative 'lib/go_cli/version'
require_relative 'lib/go_cli/config'
require_relative 'lib/go_cli/utils'
require_relative 'lib/go_cli/errors'
require_relative 'lib/go_cli/world'
require_relative 'lib/go_cli/user'
require_relative 'lib/go_cli/driver'
require_relative 'lib/go_cli/trip'
require_relative 'lib/go_cli/user_session'
require_relative 'lib/go_cli/app_session'
require_relative 'lib/go_cli/cli.rb'
require 'optparse'
require 'yaml'
require 'digest'

options = {}

main_cli = GoCLI::CLI.new
main_cli.start(options)