# Quay HA Ansible Playbooks

These playbooks can be used as a starting point to setup Quay 3.3 and Clair in an HA configuration following the docs at: https://access.redhat.com/documentation/en-us/red_hat_quay/3.3/html/manage_red_hat_quay/index

quay-setup.yaml is all that's needed, but also included is an example standalone redis and postgres container for testing, and some host preparation playbooks.

🟥
**Please note** that these playbooks were developed against private Quay 3.3 APIs. These APIs have changed in 3.4 and it is currently not possible to use these playbooks with Quay.3.4

# Usage

Copy inventories/example/, files/example/, and secrets/example/ and make modifications for your environment.

_All Quay options start with clair_ or quay_ (except for is_clair and is_quay)_

**Mark individual hosts with 'is_quay=true' and/or 'is_clair=true' to run those components there.**

Review roles/quay/defaults/main.yml for default variable values and options.

### Quay config.yaml is built in layers (each one is variable aware):
1. config object response from quay config mode API
2. reuse of SECRET_KEY, DATABASE_SECRET_KEY, and BITORRENT_FILENAME_PEPPER from first found existing quay/config.yaml on a server on re-run
3. some sane defaults from roles/quay/files/quay/config.yaml
4. values from 'quay_config' variable defined in inventory (this most easily defined by loading a file like files/example/quay/config.yaml )


### Clair config.yaml is built from (variable aware):
1. security_scanner options from:
     1. reuse of security_scanner pem file and id if already on all clair hosts and known by the Quay config API responses
     2. Quay config API generating a key
2. roles/quay/files/clair/config.yaml

# Notes

Tested on RHEL 7 with Ansible 2.6

Expects NetworkManager, Firewalld, and Selinux to be enabled.

Expects Postgresql DB for Quay
Expects Postgresql DB for Clair

_ansible-vault password is password_
_*.key and secrets/../config.yaml files are encrypted_

**You definitely don't want to use the presetup-* playbooks without modifying them for your environment.**

The load-balancer configuration is outside the scope of these playbooks
