#!/bin/sh

# URL to the Download Directory, NOT the file
URL="https://github.com/downloads/SpaceDev/SpaceBukkitPanel/"
# Filename derp
FILENAME="spacebukkit.1.2.00.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/install.sh"

if [ "$(id -u)" != "0" ]
then
	echo "This script must be run as root!" 1>&2
	exit 1
fi

if [ "$(pwd)" = '/' ] \
        || [ "$(pwd)" = '/home' ] \
        || [ "$(pwd)" = '/var' ] \
        || [ "$(pwd)" = '/var' ] \
        || [ "$(pwd)" = '/root' ] \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/boot' > /dev/null \
        || pwd | grep '^/lib' > /dev/null \
        || pwd | grep '^/etc' > /dev/null \
        || pwd | grep '^/sbin' > /dev/null \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/selinux' > /dev/null \
        || pwd | grep '^/srv' > /dev/null \
        || pwd | grep '^/usr' > /dev/null \
        || pwd | grep '^/mnt' > /dev/null \
        || pwd | grep '^/mount' > /dev/null \
        || pwd | grep '^/media' > /dev/null \
        || pwd | grep '^/dev' > /dev/null \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/sys' > /dev/null \
        || pwd | grep '^/lib64' > /dev/null \
        || pwd | grep '^/proc' > /dev/null \
        || pwd | grep '^/home/[^/]*$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Desktop$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Videos' > /dev/null \
        || pwd | grep '^/home/[^/]*/Pictures' > /dev/null \
        || pwd | grep '^/home/[^/]*/Documents$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Music' > /dev/null \
        || pwd | grep '^/home/[^/]*/Templates' > /dev/null \
        || pwd | grep '^/home/[^/]*/Downloads$' > /dev/null
then
	echo "Anti bumblebee security system engaged."
	echo "Please execute the script in another directory, you were about to delete important files, and we don't want that :("
	exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
	echo "Are you SURE you want to upgrade Spacebukkit in this directory? Everything (except your settings) in it will be deleted! [y/N] \c"
	read inputline
	if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
	then
		echo "Exiting..."
		exit 0
	fi
	echo "Deleting old files...\c"
	for i in $(ls -A ./ | grep -v "app")
	do
		rm -r $i
	done
	cd app/
	for i in $(ls -A ./ | grep -v "Config" | grep -v "webroot")
	do
		rm -r $i
	done
	cd webroot/
	for i in $(ls -A ./ | grep -v "servers")
	do
		rm -r $i
	done
	cd ../Config/
	for i in $(ls -A ./ | grep -v "database.php")
	do
		rm -r $i
	done
	cd ../../
	echo "\t\tOK"

	echo "Downloading Spacebukkit...\c"
	i=0
	success=0
	while [ $i -lt 5 ] && [ $success -eq 0 ]
	do
		if wget -q "$URL$FILENAME" > /dev/null
		then
			success=1
		else
			(( $i += 1 ))
		fi
	done
	if [ $success -eq 1 ]
	then
		echo "\t\tOK"
	else
		echo "\t\tERROR"
		echo "Could not download the panel! Maybe try again or ask us for support!\n"
		exit 1
	fi

	echo "Unzipping...\c"
	if unzip -nqq $FILENAME > /dev/null
	then
		chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
		if [ -f /etc/centos-release ]
		then
			chown -R apache:apache *
		else
			chown -R www-data:www-data *
		fi
		rm $FILENAME
		rm app/tmp/inst.txt
		wget -q $INSTURL > /dev/null
		echo "\t\t\tOK"
		echo "\nEverything has been updated correctly! Enjoy Spacebukkit!\n"
		exit 0
	else
		echo "\t\t\tERROR"
		echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
		exit 1
	fi
fi



echo "Checking dependencies...\n"

echo "unzip...\c"
if [ -f /usr/bin/unzip ]
then
	echo "\t\t\tOK"
else
	echo "\t\t\tERROR"
	echo "\nYou need unzip to execute this script! Please install it and rerun the script!"
	exit 1
fi

echo "webserver...\c"
resw=0
if [ -d /etc/apache2 ]
then
	echo "\t\t\tApache2"
	dep1=1
	resw=1
elif [ -d /etc/apache ]
then
	echo "\t\t\tApache"
	dep1=1
elif [ -d /etc/lighttpd ]
then
	echo "\t\t\tlighttpd"
	dep1=1
elif [ -d /etc/nginx ]
then
	echo "\t\t\tnginx"
	dep1=1
	resw=2
elif [ -d /etc/httpd ]
then
	echo "\t\t\thttpd"
	dep1=1
	resw=1
else
	echo "\t\t\tERROR"
	dep1=0
fi

echo "sql...\c"
if [ -d /etc/mysql ] || [ -f /usr/bin/mysql ]
then
	echo "\t\t\t\tMySQL"
	sqld=1
elif [ -d /etc/postgresql ]
then
	echo "\t\t\t\tPostgreSQL"
	sqld=2
elif [ -f /usr/bin/sqlite ]
then
	echo "\t\t\t\tSQLite"
	sqld=3
else
	echo "\t\t\t\tERROR"
	sqld=0
fi

echo "php...\c"
if [ -f /usr/bin/php5 -o -f /usr/bin/php ]
then
	echo "\t\t\t\tOK"
	dep2=1
else
	echo "\t\t\t\tERROR"
	dep2=0
fi

echo "php-curl...\c"
if ls /usr/lib*/*curl* > /dev/null
then
	echo "\t\t\tOK"
	dep3=1
else
	echo "\t\t\tERROR"
	dep3=0
fi

if [ $sqld -eq 2 ] || [ $sqld -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		[ $sqld -eq 2 ] && echo "You have PostgreSQL installed. This is not optimal and is not directly supported by Spacebukkit. Would you like to install MySQL now? [Y]/n \c"
		[ $sqld -eq 0 ] && echo "You don't have any SQL Server installed. Spacebukkit will need one. Do you want to install MySQL Server now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing MySQL...\c"
			if apt-get install -y mysql > /dev/null
			then
				echo "\t\tOK"
				slqd=1
			else
				echo "\t\tERROR"
				echo "You will need to install MySQL manually! :(\n"
			fi
		else
			echo "Not installing MySQL...\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		[ $sqld -eq 2 ] && echo "You have PostgreSQL installed. This is not optimal and is not directly supported by Spacebukkit. Would you like to install MySQL now? [Y]/n \c"
		[ $sqld -eq 0 ] && echo "You don't have any SQL Server installed. Spacebukkit will need one. Do you want to install MySQL Server now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing MySQL...\c"
			if yum install -y mysql-server > /dev/null
			then
				echo "\t\tOK"
				sqld=1
			else
				echo "\t\tERROR"
				echo "You will need to install MySQL manually! :(\n"
			fi
		else
			echo "Not installing MySQL...\n"
		fi
	else
		[ $sqld -eq 3 ] && echo "You have SQLite installed. This is not optimal and is not directly supported by Spacebukkit. We recommend you install MySQL."
		[ $sqld -eq 0 ] && echo "You don't have any SQL Server installed. You will need to install one for Spacebukkit. We recommend you install MySQL."
	fi
fi

if [ $dep1 -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		echo "You don't have any Webserver installed. Spacebukkit will need one. Do you want to install the Apache2 webserver now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing Apache2..."
			if apt-get install -y apache2 > /dev/null
			then
				echo "\t\tOK"
				dep1=1
				resw=1
			else
				echo "\t\tERROR"
				echo "You will need to install Apache2 manually! :(\n"
			fi
		else
			echo "Not installing Apache2...\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		echo "You don't have any Webserver installed. Spacebukkit will need one. Do you want to install the httpd webserver now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing httpd...\c"
			if yum install -y httpd > /dev/null
			then
				echo "\t\tOK"
				dep1=1
				resw=1
			else
				echo "\t\tERROR"
				echo "You will need to install httpd manually! :(\n"
			fi
		else
			echo "Not installing httpd...\n"
		fi
	else
		[ $sqld -eq 0 ] && echo "You don't have any Webserver installed. You will need to install one for Spacebukkit. We recommend you install the Apache2 webserver."
	fi
fi

if [ $dep2 -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		echo "You don't have PHP5 and Curl installed. Spacebukkit will need them. Do you want to install PHP5 and Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing PHP5 and Curl...\c"
			if apt-get install -y php5 php5-curl
			then
				echo "\tOK"
				dep3=1
				dep2=1
			else
				echo "\tERROR"
				echo "You will need to install PHP5 and Curl manually! :(\n"
			fi
		else
			echo "Not installing PHP5 or Curl... (You will need to do it manually)\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		echo "You don't have PHP and Curl installed. Spacebukkit will need them. Do you want to install PHP and Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing PHP and Curl...\c"
			if yum install -y php libcurl > /dev/null
			then
				echo "\tOK"
				dep3=1
				dep2=1
			else
				echo "\tERROR"
				echo "You will need to install PHP and Curl manually! :(\n"
			fi
		else
			echo "Not installing PHP or Curl... (You will need to do it manually)\n"
		fi
	else
		[ $sqld -eq 0 ] && echo "You don't have PHP and Curl installed. You will need them for Spacebukkit."
	fi
fi

if [ $dep3 -eq 0 -a $dep2 -eq 1 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		echo "You don't have Curl installed. Spacebukkit will need it. Do you want to install Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing Curl...\c"
			if apt-get install -y php5-curl > /dev/null
			then
				echo "\t\tOK"
				dep3=1
			else
				echo "\t\tERROR"
				echo "You will need to install Curl manually! :(\n"
			fi
		else
			echo "Not installing Curl... (You will need to do it manually)\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		echo "You don't have Curl installed. Spacebukkit will need it. Do you want to install Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			echo "Installing Curl...\c"
			if yum install -y libcurl > /dev/null
			then
				echo "\t\tOK"
				dep3=1
			else
				echo "\t\tERROR"
				echo "You will need to install Curl manually! :(\n"
			fi
		else
			echo "Not installing Curl... (You will need to do it manually)\n"
		fi
	else
		[ $sqld -eq 0 ] && echo "You don't have Curl installed. You will need it for Spacebukkit."
	fi
fi

echo "\nDependencies are OK!\n"

echo "Are you SURE the current directory you are in (`pwd`) is the directoy the script is in and also the directory where you want to install Spacebukkit? [y/N]"
read inputline
if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
then
	echo "Exiting."
	exit 0
fi

echo "Downloading Spacebukkit now...\c"
i=0
success=0
while [ $i -lt 5 ] && [ $success -eq 0 ]
do
	if wget -q "$URL$FILENAME" > /dev/null
	then
		success=1
	else
		(( $i += 1 ))
	fi
done
if [ $success -eq 1 ]
then
	echo "\tOK"
else
	echo "\tERROR"
	echo "Could not download the panel! Maybe try again or ask us for support!\n"
	exit 1
fi

echo "Unzipping...\c"
if unzip -oqq $FILENAME > /dev/null
then
	chmod -R 777 SpaceDev-SpaceBukkitPanel-*/app/tmp SpaceDev-SpaceBukkitPanel-*/app/webroot SpaceDev-SpaceBukkitPanel-*/app/Config/database*
	if [ -f /etc/centos-release ]
	then
		chown -R apache:apache SpaceDev-SpaceBukkitPanel-*/*
	else
		chown -R www-data:www-data SpaceDev-SpaceBukkitPanel-*/*
	fi
	cp -r SpaceDev-SpaceBukkitPanel-*/* ./
	cp SpaceDev-SpaceBukkitPanel-*/.htaccess ./
	rm $FILENAME
	rm -r SpaceDev-SpaceBukkitPanel-*
	if [ -f /etc/debian_verion ]
	then
		[ $resw -eq 1 ] && /etc/init.d/apache2 restart > /dev/null
		[ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
	elif [ -f /etc/centos-release ]
	then
		[ $resw -eq 1 ] && /etc/init.d/httpd restart > /dev/null
		[ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
	fi
	echo "\t\t\tOK"
	echo "\nEverything has been unzipped, modded and owned correctly!\nYou now have a perfect copy of the awesome Spacebukkit Panel! \o/ *!party!* \o/\n"
	exit 0
else
	echo "\t\t\tERROR"
	echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	exit 1
fi
