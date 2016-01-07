AUTHORS="C.M. da Costa, W.M. Jacobus, K.A. Patience and S. Mahleza"
TITLE="OS Project installer" 
VERSION="0.1"
args_number=$#
INSTALLER="$0"
TYPE="$1"
NODE_NAME="$2"
IPADDRESS="$3"
orig_types="master MASTER slave SLAVE"
DESCRIPTION="DESCRIPTION"
REPORTTO="Report $INSTALLER bugs to conal.dacosta@kurtosys.com\n$TITLE home page: <github>\nGeneral help using $TITLE: <http://dev.dacostarepublic.co.za>"

HEADER () {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ="$(tput cols)"
    COLUMNS=$(tput cols) 
    printf "%*s\n" $(((${#TITLE}+3+${#VERSION}+$COLUMNS)/2)) "$TITLE (v$VERSION)"
    printf "%*s\n" $(((2+$COLUMNS)/2)) "by"
    printf "%*s\n" $(((${#AUTHORS}+$COLUMNS)/2)) "$AUTHORS"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ="$(tput cols)"
}
USAGE () {
    printf "Usage: %s [master|slave] <node_name>\n" "$INSTALLER"
    printf "%s\n" "$DESCRIPTION"
    printf "%s\n" "$REPORTTO"
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
    sudo apt-get update
    echo "** Installing required packages (requires internet)"
    sudo apt-get install -y ganglia-monitor gmetad ganglia-webfrontend vim python-mpi4py libopenmpi-dev openmpi-bin openmpi-doc
}
HEADER
CHECK



if [[ "master" = "$TYPE" ]]; then
    MASTER_INSTALL
fi 

