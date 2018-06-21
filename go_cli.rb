require_relative 'lib/go_cli/version'
require_relative 'lib/go_cli/config'
require_relative 'lib/go_cli/utils'
require_relative 'lib/go_cli/errors'
require_relative 'lib/go_cli/world'
require_relative 'lib/go_cli/route'
require_relative 'lib/go_cli/user'
require_relative 'lib/go_cli/driver'
require_relative 'lib/go_cli/trip'
require_relative 'lib/go_cli/user_session'
require_relative 'lib/go_cli/driver_session'
require_relative 'lib/go_cli/app_session'
require_relative 'lib/go_cli/cli'
require 'optparse'
require 'yaml'
require 'digest'
require 'date'
require 'io/console'
require 'base64'

def reset
  File.write(GoCLI::Config::USER_FILE_MAPFILE, "--- {}\n")
  File.write(GoCLI::Config::USER_ID_MAPFILE, "--- {}\n")
  File.write(GoCLI::Config::DRIVER_ID_MAPFILE, "--- []\n")
  File.write(GoCLI::Config::DRIVER_FILE_MAPFILE, "--- {}\n")
  GoCLI::Driver.create("Sudirman Bima Cahyadi","FAX 4438")
  GoCLI::Driver.create("Dwi Eka Oesman","WEE 1935")
  GoCLI::Driver.create("Gunadi Shan","KKI 4222")
  GoCLI::Driver.create("Sugondo Lei","GAP 8485")
  GoCLI::Driver.create("Ward Cresbon","SOB 1258")
  GoCLI::Driver.create("Eli Rambe","LLL 1463")
  GoCLI::Driver.create("Lemuel Masaro","GUM 3007")
  GoCLI::Driver.create("Lemuel Namohaji","OWW 0440")
  GoCLI::Driver.create("Sutikno","SAT 6676")
  GoCLI::Driver.create("Kuwat","BOI 0151")
  File.write(GoCLI::Config::TRIP_DRIVER_MAPFILE, "--- {}\n")
  File.write(GoCLI::Config::TRIP_USER_MAPFILE, "--- {}\n")
end

# reset

options = {:file => nil, :size => nil, :pos => nil}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options]"
  opts.on('-f', '--file=FILE', 'Load FILE') { |file| options[:file] = file }
  opts.on('-s', '--size=SIZE', 'Sets world size', Integer) { |size| options[:size] = size }
  opts.on('--pos=[X,Y]', 'Sets user position to X,Y', Array) { |pos| options[:pos] = pos }
  opts.on('-h', '--help', 'Displays help') { puts opts; exit }
end
parser.parse!

if options[:pos]
  options[:pos].select! { |a| /\d+/.match? a }
  options[:pos].map! { |a| a.to_i }
end

main_cli = GoCLI::CLI.new
main_cli.start(options)