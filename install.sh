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
MPI_INSTALL() {
    sudo apt-get install -y python-mpi4py libopenmpi-dev openmpi-bin openmpi-doc
}
HADOOP_INSTALL() {
    sudo apt-get remove -y oracle-java8-jdk
    sudo apt-get install -y oracle-java7-jdk libjansi-java libjansi-native-java libhawtjni-runtime-java
    wget http://dev.dacostarepublic.co.za/hadoop/hadoop-2.6.3.tar.gz
    wget http://dev.dacostarepublic.co.za/hadoop/hadoop_conf.tar.gz
    tar -xzvf hadoop-2.6.3.tar.gz
    tar -xzvf hadoop_conf.tar.gz
    sudo cp hadoop_conf/* hadoop-2.6.3/etc/hadoop/.
    sudo mv hadoop-2.6.3 /usr/local/.       
    echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-armhf" >> ~/.bashrc
    echo "export HADOOP_HOME=/usr/local/hadoop-2.6.3" >> ~/.bashrc
    echo "export HADOOP_MAPRED_HOME=$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_COMMON_HOME=$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_HDFS_HOME=$HADOOP_HOME" >> ~/.bashrc
    echo "export YARN_HOME=$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" >> ~/.bashrc
    echo "export HADOOP_OPTS='-Djava.library.path=$HADOOP_HOME/lib'" >> ~/.bashrc
    echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> ~/.bashrc
    echo "export MAVEN_OPTS='-Xmx2g -XX:MaxPermSize=752M -XX:ReservedCodeCacheSize=752M'" >> ~/.bashrc
    sudo vim /etc/hosts
    sudo vim /usr/local/hadoop-2.6.3/etc/hadoop/slaves
}
SPARK_INSTALL(){
    echo "Spark"
}


MASTER_INSTALL () {
    echo "Installing Master node - $NODE_NAME $IPADDRESS"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"$(tput cols)"   
    echo "** Updating apt-get (requires internet)"
    sudo apt-get update
    echo "** Installing required packages (requires internet)"
    sudo apt-get install -y apache2 ganglia-monitor gmetad ganglia-webfrontend vim 
    echo "** Changing hostname"
    sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hosts
    sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hostname
    echo "** Setting static ipaddress for eth0 (/etc/dhcpch.conf)"
    echo -e "\t-Please enter the router's ipaddress"
    read router_address
    echo -e "\t-Please enter the dns address (usually same as router)"
    read dns_address
    sudo echo "interface eth0" >> /etc/dhcpcd.conf
    sudo echo "inform $IPADDRESS" >> /etc/dhcpcd.conf
    sudo echo "static routers=$router_address" >> /etc/dhcpcd.conf
    sudo echo "static domain_name_servers=$dns_address" >> /etc/dhcpcd.conf
    echo "** Change Password - pi"
    sudo passwd pi
    echo "** Change Password - root"
    sudo passwd root
    read -p $'Which implementation to install?\n(1) MPI\n(2) Hadoop\n(3) Spark/Scala\n> ' install_option
    if [ "$install_option" -eq "1" ]; then
        echo -e "** Installing for MPI"
        MPI_INSTALL
    fi
    if [ "$install_option" -eq "2" ]; then
        echo -e "** Installing for Hadoop"
        HADOOP_INSTALL
        
    fi
    if [ "$install_option" -eq "3" ]; then
        echo -e "** Installing for Spark/Scala"
        HADOOP_INSTALL
        SPARK_INSTALL
    fi
    
    # echo "** Changing hostname"
    # sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hosts
    # sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hostname
    # echo "** Setting static ipaddress for eth0 (/etc/dhcpch.conf)"
    # echo -e "\t-Please enter the router's ipaddress"
    # read router_address
    # echo -e "\t-Please enter the dns address (usually same as router)"
    # read dns_address
    # sudo echo "interface eth0" >> /etc/dhcpcd.conf
    # sudo echo "inform $IPADDRESS" >> /etc/dhcpcd.conf
    # sudo echo "static routers=$router_address" >> /etc/dhcpcd.conf
    # sudo echo "static domain_name_servers=$dns_address" >> /etc/dhcpcd.conf
    # echo "** Change Password - pi"
    # sudo passwd pi
    # echo "** Change Password - root"
    # sudo passwd root
    # echo ""
    # echo -e "** Installing for Spark/Scala"
    # sudo apt-get remove -y oracle-java8-jdk
    # sudo apt-get install -y oracle-java7-jdk libjansi-java libjansi-native-java libhawtjni-runtime-java
    # wget http://apache.is.co.za/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz
    # tar -xzvf hadoop-2.6.3.tar.gz
    # sudo mv hadoop-2.6.3 /usr/local/.
    # echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-armhf" >> ~/.bashrc
    # echo "export HADOOP_HOME=/usr/local/hadoop-2.6.3" >> ~/.bashrc
    # echo "export HADOOP_MAPRED_HOME=$HADOOP_HOME" >> ~/.bashrc
    # echo "export HADOOP_COMMON_HOME=$HADOOP_HOME" >> ~/.bashrc
    # echo "export HADOOP_HDFS_HOME=$HADOOP_HOME" >> ~/.bashrc
    # echo "export YARN_HOME=$HADOOP_HOME" >> ~/.bashrc
    # echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" >> ~/.bashrc
    # echo "export HADOOP_OPTS='-Djava.library.path=$HADOOP_HOME/lib'" >> ~/.bashrc
    # echo "export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> ~/.bashrc
    # echo "export MAVEN_OPTS='-Xmx2g -XX:MaxPermSize=752M -XX:ReservedCodeCacheSize=752M'" >> ~/.bashrc
    # sudo vim /etc/hosts
    

}
SLAVE_INSTALL () {
    echo "Installing Slave node - $NODE_NAME $IPADDRESS"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -"$(tput cols)"   
    echo "** Updating apt-get (requires internet)"
    sudo apt-get update
    echo "** Installing required packages (requires internet)"
    sudo apt-get install -y ganglia-monitor vim software-properties-common 
    echo "** Changing hostname"
    sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hosts
    sudo sed -i "s/$hostn/$NODE_NAME/g" /etc/hostname
    echo "** Setting static ipaddress for eth0 (/etc/dhcpch.conf)"
    echo -e "\t-Please enter the router's ipaddress"
    read router_address
    echo -e "\t-Please enter the dns address (usually same as router)"
    read dns_address
    sudo echo "interface eth0" >> /etc/dhcpcd.conf
    sudo echo "inform $IPADDRESS" >> /etc/dhcpcd.conf
    sudo echo "static routers=$router_address" >> /etc/dhcpcd.conf
    sudo echo "static domain_name_servers=$dns_address" >> /etc/dhcpcd.conf
    echo "** Change Password - pi"
    passwd
    echo "** Change Password - root"
    sudo passwd root
    echo ""
    read -p $'Which implementation to install?\n(1) MPI\n(2) Hadoop\n(3) Spark/Scala\n> ' install_option
    if [ "$install_option" -eq "1" ]; then
        echo -e "** Installing for MPI"
        MPI_INSTALL
    fi
    if [ "$install_option" -eq "2" ]; then
        echo -e "** Installing for Hadoop"
    	HADOOP_INSTALL
        
    fi
    if [ "$install_option" -eq "3" ]; then
        echo -e "** Installing for Spark/Scala"
        HADOOP_INSTALL
        SPARK_INSTALL
 #        wget http://www.scala-lang.org/files/archive/scala-2.11.7.deb
	# sudo dpkg -i scala-2.11.7.deb	
 #        sudo apt-get update
	# sudo apt-get install scala
 #        sudo apt-get install -y git
 #        wget http://archive.apache.org/dist/spark/spark-1.2.2/spark-1.2.2.tgz
 #        tar -xzvf spark-1.2.2.tgz
	# sudo apt-get install -y maven
	
 #        . ~/.bashrc
	# cd spark-1.2.2
 #        sbt/sbt assembly
 #        ./bin/run-example SparkPi 10
    fi
    

}
HEADER
CHECK



if [[ "master" = "$TYPE" ]]; then
    MASTER_INSTALL
fi
if [[ "slave" = "$TYPE" ]]; then
    SLAVE_INSTALL
fi 

