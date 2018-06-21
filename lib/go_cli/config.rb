module GoCLI
  module Config
    DEFAULT_DRIVER_AMOUNT = 5
    DEFAULT_WORLD_SIZE = 20
    DEFAULT_PRICE_UNIT = 300
    MAX_ATTEMPT = 3
    MAX_RATING = 5
    MIN_RATING = 1
    USER_DATA_DIR = "data/users/"
    USER_ID_MAPFILE = USER_DATA_DIR + "user_id_map.yml"
    USER_FILE_MAPFILE = USER_DATA_DIR + "user_file_map.yml"
    TRIP_DATA_DIR = "data/trips/"
    TRIP_USER_MAPFILE = TRIP_DATA_DIR + "trip_user_map.yml"
    TRIP_DRIVER_MAPFILE = TRIP_DATA_DIR + "trip_driver_map.yml"
    DRIVER_DATA_DIR = "data/drivers/"
    DRIVER_ID_MAPFILE = DRIVER_DATA_DIR + "driver_id_map.yml"
    DRIVER_FILE_MAPFILE = DRIVER_DATA_DIR + "driver_file_map.yml"
    MAP_USER_CHAR = "U"
    MAP_DRIVER_CHAR = "D"
    MAP_EMPTY_CHAR = "·"
    MAP_DESTINATION_CHAR = "X"
    MAP_ROUTE_CHAR = "■"
    DRIVER_RATING_LOOKBACK = 5
  end
end