# Configuration script template

## Table of content

[TOC]

## 1. Introduction

The file `install-configs.sh` is a configuration script which will do all your configuration for you. The one in this directory is a template that you can edit to match your needs. This document will explain how it works. 

## 2. File structure

```text
configure/
|
+-- service-1/            : configuration files for service-1
+-- service-2/            : configuration files for service-2
+-- ...
+-- service-n/            : configuration files for service-n
|
+-- install-configs.sh    : configuration script
+-- README.md             : documentation
```

## 3. Getting start with the script

1. Start by adding the needed directories to the parent folder of `install-configs.sh`. One for each service or app you want to configure as in the [file structure section](#file-structure). Do not forget to add the configuration files to them.
1. In the script `install-configs.sh`, for each service or app you want to configure, do the following:
    1. Add a configuration function in the `CONFIGURE APP` section:
        1. Note: The script uses pushd to move within the directory matching the service name (here: `my-service`) to execute the function.

        ```bash
        #
        # APP CONFIGURATION FUNCTIONS
        # Add your configuration functions here
        #

        # configuration function for the service 'my-service'
        configure-my-service() {
            # Do what you want here
            # The current path will be /path/to/the/script/parent/dir/my-service/
        }
        ```

    1. Add an option entry in the handling option case statement according to your case:

        ```bash
        #
        # BEGIN
        #

        # [...]

        # Handle options
        for opt in "$@"
        do
            case "${opt}" in
                "--help")
                    # [...] 
                    ;;
                "--all")
                    # [...]
                    ;;
                # Add your options here
                "--my-service")
                    # Choose and adapt one of the next options:

                    # Configure my-service without checking for a specific path
                    configure-app "my-service" false
                    
                    # OR

                    # Configure my-service after checking for a specific path
                    my_service_dir="/path/to/required/directory/"
                    configure-app "my-service" true "${my_service_dir}"

                    # OR

                    # Configure my-service that requires sudo
                    try-sudo "my-service" && configure-app "my-service" false

                    # OR

                    # Configure my-service that requires sudo and checks for a specific
                    my_service_dir="/path/to/required/directory/"
                    try-sudo "my-service" && configure-app "my-service" true "${my_service_dir}"
                    ;;
                *)
                    # [...]
                    ;;
            esac
        done
        ```

    1. Add you new option in the command called by `--all` option:

        ```bash
        #
        # BEGIN
        #

        # [...]

        # Handle options
        for opt in "$@"
        do
            case "${opt}" in
                "--help")
                    # [...]
                    ;;
                "--all")
                    # Configure all only if --all is the only argument
                    if [ $# -eq 1 ]
                    then
                        bash "${script_path}" --my-service    # <= Add your option here
                    else 
                        echo "There are other arguments than --all. Skipping --all argument"
                    fi
                    ;;
                # Add your options here
                "--my-service")
                    # [your choice from the previous step]
                    ;;
                *)
                    # [...]
                    ;;
            esac
        done
        ```

    1. Add a description in the `print-help` function for your new option:

        ```bash
        #
        # FUNCTIONS
        #
        print-help() {
            # [...]
            echo "[AVAILABLE OPTIONS]"
            # [...]
            # Add your option descriptions here
            echo "    --my-service    : Configure my-service"
            # [...]
        }
        ```

## 4. Use the script

Once all the setup is done, you can use the script as follows, assuming the file structure to be the one discribed in the [file structure section](#file-structure):

```bash
# To configure only service-1
bash "/path/to/the/script/install-configs.sh" --service-1

# To congigure several services
bash "/path/to/the/script/install-configs.sh" --service-1 --service-2 ...

# To congigure all sercices
bash "/path/to/the/script/install-configs.sh" --all
```

## 5. Author

* Lilian POULIQUEN: [Github – @lilian-pouliquen](https://github.com/lilian-pouliquen)
