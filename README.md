# odoo

[odoo](https://www.odoo.com/) is an open source ERP and CRM solution with more than 80% free utilities. This is the docker image of same

## Requirements

- [Docker container virtualization service](https://www.docker.com/)

## Version

Following are the versions for which it is tested

- [PostgreSQL:16](https://hub.docker.com/_/postgres)
- [Odoo:17.0](https://hub.docker.com/_/odoo)
- [Adminer:4.8.1](https://hub.docker.com/_/adminer)

## How to run?

First create a `.env` file. example file is already provided in the source. you can also rename `.env.example` file to `.env` and it will run fine.

Based on whatever details you assigned in `.env` you may also required to update variables mentioned on top of both `build_and_run.sh` and `build_and_run.bat` script.

now you can run the script to initiate containers in docker.

### for linux or mac

```bash
# make script executable
chmod +x ./build_and_run.sh

# run the script
./build_and_run.sh
```

### for windows

execute `build_and_run.bat` script
