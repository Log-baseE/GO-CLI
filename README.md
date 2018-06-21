# GO-CLI App

A command line application, simulating ordering an online driver

## Usage

To execute the app, run the following command

```bash
ruby go_cli.rb [options]
    -f, --file=FILE                  Load FILE
    -s, --size=SIZE                  Sets world size
        --pos=[X,Y]                  Sets user position to X,Y
    -h, --help                       Displays help message
```

Here are some examples:

```bash
# run with default settings
ruby go_cli.rb 

# run with world size 30
ruby go_cli.rb -s 30
ruby go_cli.rb --size=30

# run with world size 30 and initial position [5,6]
ruby go_cli.rb -s 30 --pos=5,6
ruby go_cli.rb --size=30 --pos=5,6

# run with configuration file
ruby go_cli.rb -f filename
ruby go_cli.rb --file=filename

# run with configuration file (-f option overrides other options)
ruby go_cli.rb -s 30 --pos=1,1 -f filename
```

For easier testing of file load, provided is a file `session.yml` in `data/`

## Design Decisions

### Assumptions

- The world will always be a square grid of size _n_. Each cell is a space an entity can occupy, with the coordinates `i, j (1 <= i,j <= n)`. Below is an illustration of the world's coordinate space.

  ```ruby
  [1,1][2,1][3,1][4,1]
  [1,2][2,2][3,2][4,2]
  [1,3][2,3][3,3][4,3]
  [1,4][2,4][3,4][4,4]
  ```

### Specifications

#### Use Cases

| UC no. | UC name           | Main Actor | Description                                                 |
| ------ | ----------------- | ---------- | ----------------------------------------------------------- |
| UC-1   | View map          | User       | User views the world map, along with the entities within it |
| UC-2   | Order ride        | User       | User orders an online driver ride to a certain destination  |
| UC-3   | View trip history | User       | User views their history of trip orders                     |

#### Scenarios

_**UC-1 => View map**_

1. User selects view map option
2. System displays world map

_**UC-2 => Order ride**_

1. User selects order ride option
2. System displays user position and prompts destination
3. User either enters destination or cancels (a)
4. System finds closest driver to user
5. System shows details of driver, route, and price
6. System prompts for trip confirmation
7. User either confirms or cancels (a)
8. System stores trip data
9. System prompts for trip rating
10. User enters rating
11. System updates trip rating in data

Alternates: <br>

- 3a. Process ends here <br>
- 7a. Process ends here

_**UC-3 => View trip history**_

1. User selects view trip history menu
2. System displays trip history list
3. User selects a trip
4. System displays its details

For all the activities above, the user must be logged in. This is to ensure that any activities are encapsulated for each user.

All data are stored in a YAML file. This is preferred since ruby can load them easily without additional gem installations. Existing files are structured as makeshift database, to aid important queries and updates.

### Configurations

Configurations are stored in `lib/go_cli/config.rb`

### Project structure

The `lib/go_cli` directory is where the main app module lives. The module structure will be discussed in the later section.

The `data` directory contains all saved data from the app. Below are its contents:

- `drivers` : contains all information about drivers. This includes name, license plate, rating, and other information.
  - `driver_file_map.yml` : acts as a map of `driver_id`s to their corresponding data file
  - `driver_id_map.yml` : contains all the existing `driver_id`s for faster query
- `users`: contains all user data
  - `user_id_map.yml` : contains mapping from the `username` to its corresponding `user_id`
  - `user_file_map.yml` : contains mapping from the `user_id` to its corresponding data file
- `trips`: contains all trip data
  - `trip_user_map.yml` : creates a relationship between `user_id` and `trip` so that we can query trips belonging to a `user_id`.
  - `trip_driver_map.yml` : creates a relationship between `driver_id` and `trip` so that we can query trips belonging to a `driver_id`.

### Module structure

The app lives inside the module `GoCLI`. Inside it are classes as the following:

| Class           | Description                                                                                                                                    |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `User`          | Instances of this class act as the temporary data storage for the app. Class methods of `User` are used mainly for data validation and queries |
| `UserSession`   | Mainly acts as an interface with an instance of `User`. Its instance contains information about the user's position                            |
| `Driver`        | Similar to `User`, instances of `Driver` temporarily stores data for the app. Class methods are used in a similar way as `User`                |
| `DriverSession` | Similar to `UserSession`, this class stores the position of the driver, and acts as an interface with a `Driver`                               |
| `AppSession`    | This class acts as the interface for `UserSession` and `DriverSession`. Most of controls are called through here.                              |
| `Route`         | Stores coordinates as nodes in a path, e.g. `[1,2] => [4,5] => [1,4]`.                                                                         |
| `Trip`          | Instances store crucial details about a trip. Details include user, driver, price, starting position, destination, route, and price.           |
| `World`         | Contains information about the world size                                                                                                      |
| `CLI`           | The main command-line interface that the user interacts with. Running `go_cli.rb` will always an instance of `CLI`, with options if any        |

The `GoCLI` module also contains the following submodules:
| Submodule | Description                                |
| --------- | ------------------------------------------ |
| `CONFIG`  | Contains default configuration for the app |
| `ERR`     | Contains error codes that might be used    |
| `ERXT`    | Contains exit codes that might be used     |


## Features to add

- To ensure data integrity, there must be some way to check if all the files are consistent and do not contain any conflicts with each other.
- Better error handling, especially keyboard interrupts.

## Interface

Below are examples of the interface screens within the app
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                              LOGIN                                |
=====================================================================
Please enter your username:
> john_doe
Please enter your password to log in (hidden):
> _
```
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                     Welcome to Go-CLI v0.1.0                      |
|                            MAIN MENU                              |
=====================================================================
Hello john_doe, you are currently in (20, 9)
Debt: 35100

Please choose an option:

1) View Map
2) Order Go-RIDE
3) View trip history

0) Exit

> _
```
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                            VIEW  MAP                              |
=====================================================================
╔════════════════════╗
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║···················U║
║······D···········D·║
║····················║
║····················║
║········D···········║
║····················║
║····················║
║····················║
║····················║
║···················D║
║D···················║
║····················║
╚════════════════════╝
Legend:
U: you!
D: driver

Press any key to continue . . .
```
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                           ORDER  RIDE                             |
=====================================================================
You are now in (20, 9)
Please enter your destination [x y] (enter nothing to cancel)
> 1 1
Finding nearest driver...
Driver found!

Name              : Lemuel Masaro
License plate     : GUM 3007
Rating            : 4.0
Currently at      : (19, 10)
Distance from you : 2 units
-------------------------------- MAP --------------------------------
╔════════════════════╗
║X■■■■■■■■■■■■■■■■■■■║
║···················■║
║···················■║
║···················■║
║···················■║
║···················■║
║···················■║
║···················■║
║···················U║
║··················D·║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
╚════════════════════╝
Legend:
U: you!
X: destination
D: driver
■: route

Total distance  : 27
Estimated price : 8100

Confirm ride? [y]es/[n]o
> y
Ride confirmed
Please rate your ride (1-5)
> 5
Thank you for your feedback!

Press any key to continue . . .
```
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                           VIEW  TRIPS                             |
=====================================================================
1) 21 Jun 2018 (20:43) - trip from (20, 4) to (1,1)
2) 21 Jun 2018 (20:48) - trip from (16, 12) to (1,1)
3) 21 Jun 2018 (20:51) - trip from (7, 2) to (20,20)
4) 21 Jun 2018 (21:08) - trip from (1, 1) to (20,20)
5) 21 Jun 2018 (22:53) - trip from (20, 9) to (1,1)

0) Go Back

Enter trip number to view details. Press 0 to go back
> _
```
```
#####################################################################
     .oooooo.                        .oooooo.   ooooo        ooooo
    d8P'  `Y8b                      d8P'  `Y8b  `888'        `888'
   888            .ooooo.          888           888          888
   888           d88' `88b         888           888          888
   888     ooooo 888   888 8888888 888           888          888
   `88.    .88'  888   888         `88b    ooo   888       o  888
    `Y8bood8P'   `Y8bod8P'          `Y8bood8P'  o888ooooood8 o888o
#####################################################################
|                           VIEW  TRIPS                             |
=====================================================================
TRIP DETAILS (21 Jun 2018 (20:43)

From            : 20, 4
Destination     : 1, 1
Distance        : 22
Price           : 6600
Driver          : Sutikno
Rating          : 4
Route taken     :

╔════════════════════╗
║X■■■■■■■■■■■■■■■■■■■║
║···················■║
║···················■║
║···················U║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
║····················║
╚════════════════════╝
Legend:
U: you!
X: destination
■: route

Press any key to continue . . .
```