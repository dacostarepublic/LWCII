AUTHORS="C.M. da Costa, W.M. Jacobus, K.A. Patience and S. Mahleza"
TITLE="Light Weight Cloud Infrastructure Implementation installer" 
TITLE_SHORT="LWCII installer"
VERSION="0.1"
args_number=$#
INSTALLER="$0"
TYPE="$1"
NODE_NAME="$2"
IPADDRESS="$3"
hostn=$(cat /etc/hostname)
orig_types="master MASTER slave SLAVE"
DESCRIPTION="Main installation for the Light Weight Cloud Infrastructure Implmentation project\nInstallation installs the following packages:\n*ganglia-monitor\n*vim\n*python-pmi4py\n*libopenmpi-dev\n*openmpi-bin\n*openmpi-doc\n*gmetad (master only)\n*ganglia-webfrontend (master only)\n\nThen sets up the static ipaddress for eth0"
REPORTTO="Report $INSTALLER bugs to conal.dacosta@kurtosys.com\n$TITLE_SHORT home page: <https://github.com/dacostarepublic/LWCII>\nGeneral help using $TITLE_SHORT: <http://dev.dacostarepublic.co.za>"

HEADER () {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ="$(tput cols)"
    COLUMNS=$(tput cols) 
    printf "%*s\n" $(((${#TITLE}+3+${#VERSION}+$COLUMNS)/2)) "$TITLE (v$VERSION)"
    printf "%*s\n" $(((2+$COLUMNS)/2)) "by"
    printf "%*s\n" $(((${#AUTHORS}+$COLUMNS)/2)) "$AUTHORS"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ="$(tput cols)"
}
USAGE () {
    printf "Usage: %s [master|slave] <node_name> <ip_address>\n" "$INSTALLER"
    echo -e "\n$DESCRIPTION"
    echo -e "\n$REPORTTO"
    exit
}
CHECK () {
    if [ "$args_number" -ne "3" ]; then
        echo "Illegal number of parameters"
        USAGE
    fi
    if [[ ! $orig_types =~ $TYPE ]]; then
        echo "Illegal [master|slave]"
        USAGE
    fi
    if [[ ! $NODE_NAME =~ ^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]) ]]; then
        echo "Illegal node_name"
        USAGE
    fi
}
MASTER_INSTALL () {
    echo "Installing Master node - $NODE_NAME $IPADDRESS"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"$(tput cols)"   
    echo "** Updating apt-get (requires internet)"
    #sudo apt-get update
    echo "** Installing required packages (requires internet)"
    #sudo apt-get install -y ganglia-monitor gmetad ganglia-webfrontend vim python-mpi4py libopenmpi-dev openmpi-bin openmpi-doc
    echo "** Changing hostname"
    #sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hosts
    #sudo sed -i "s/$hostn/$HODE_NAME/g" /etc/hostname
    echo "** Setting static ipaddress for eth0 (/etc/dhcpch.conf)"
    echo -e "\t-Please enter the router's ipaddress"
    read router_address
    echo -e "\t-Please enter the dns address (usually same as router)"
    read dns_address
    sudo echo "interface eth0" #>> /etc/dhcpcd.conf
    sudo echo "inform $IPADDRESS" #>> /etc/dhcpcd.conf
    sudo echo "static routers=$router_address" #>> /etc/dhcpcd.conf
    sudo echo "static domain_name_servers=$dns_address" #>> /etc/dhcpcd.conf
    echo "** Change Password - pi"
    #passwd
    echo "** Change Password - root"
    #sudo passwd root
    echo ""

}
HEADER
CHECK



if [[ "master" = "$TYPE" ]]; then
    MASTER_INSTALL
fi 

