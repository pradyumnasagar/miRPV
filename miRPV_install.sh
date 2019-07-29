#!/bin/bash
set -e
set -u
#set -x
#exec 1> miRPV.log
#exec 2>&1
#AUTHOR: Pradyumna Jayaram
#bash miRPV_install.sh </path/to/miRPV>

###prints help when -h is typed with script
if [ "$1" == "-h" ]; then
	echo -e "Usage:\nbash `basename $0` /path/to/miRPV"
	echo "path to miRPV is the folder where `basename $0` is present"
	exit 0
fi

##prints help when miRPV path is not given
if [ "$1" == "" ]; then
	echo -e "Usage:\nbash `basename $0` /path/to/miRPV"
	echo "path to miRPV is the folder where `basename $0` is present"
	exit 0
fi
miRPV_PATH=$1
PDIR=$(pwd)

if [ "$miRPV_PATH" == "$PDIR" ]; then
	echo ""
else
	cd "$miRPV_PATH" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
fi

[ -d "$miRPV_PATH" ] && echo "$miRPV_PATH exists" || read -r -p "`echo -e '\n Path to miRPV does not exists.\n \n  give path to miRPV folder where this script is present and try to run this script again. \n \n Closing installation in  50 seconds or press any key to close immediately'`" -t 50 -n 1 -s | echo "invalid miRPV path" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit

#####all export
export PATH="$miRPV_PATH/bin:$PATH"

source "$miRPV_PATH"/data/config/miRPV_var.conf



echo "This version of miRPV works best on ubuntu System. However, it can be tried in other linux system at your own risk"
systemID='cat /etc/os-release | grep "^ID="|  awk -F "=" '{print $2}''
VERSION_ID='cat /etc/os-release | grep "^VERSION_ID="|  awk -F "=" '{print $2}''


if [[ "$systemID" -eq "ubuntu" ]]; then
	echo "installing dependencies"
else
	echo "The tool currently verified on ubuntu system but you have $systemID some dependencies might not be installed which may break the pipeline"
fi


#Set Path

miRPara_PATH=""$miRPV_PATH"/src/tools/miRPara/"
miRPara="$miRPara_PATH"/miRPara/miRPara.pl
#miRBAG_PATH="$miRPV_PATH"/src/tools/miRBAG/ #miRBAG is removed from pipeline
echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log

echo "creating missing folders" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log

#make directories
mkdir -p "$miRPV_PATH"/src/tools/
mkdir -p "$miRPV_PATH"/src/tools/miRPara/
#mkdir -p "$miRPV_PATH"/src/tools/miRBAG/
#mkdir -p "$miRPV_PATH"/src/tools/miniconda/ #installation doesnot require existing directory
mkdir -p "$miRPara_PATH"/required_packages/
mkdir -p "$miRPara_PATH"/required_packages/ct2out/
# mkdir -p ""


echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
echo "Running script as root to install missing packages" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
#sudo echo "Testing dependencies installed" #Gain sudo permission
echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log


# checking for WGET
set +e
WGET=`which wget`
set -e
if [ ! -x "$WGET" ]; then
	echo "Unable to find wget in your PATH" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi

# checking for UNZIP
set +e
UNZIP=`which unzip`
set -e
if [ ! -x "$UNZIP" ]; then
	echo "Unable to find unzip in your PATH"  | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi


# checking for GCC
set +e
CC=`which gcc`
set -e
if [ ! -x "$CC" ]; then
	echo "Unable to find GCC in your PATH"  | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi

set +e
CPP=`which g++`
set -e
if [ ! -x "$CPP" ]; then
	echo "Unable to find G++ in your PATH" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi

# checking for make
set +e
MAKE=`which make`
set -e
if [ ! -x "$MAKE" ]; then
	echo "Unable to find make in your PATH" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi

# checking for java
set +e
JAVA=`which java`
set -e
if [ ! -x "$JAVA" ]; then
	echo "Unable to find java in your PATH" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	exit 1
fi




##installing RNAFold for TripletSVM
cd "$miRPV_PATH" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
systemID=$(cat /etc/os-release | grep "^ID="|  awk -F "=" '{print $2}')

# checking for RNAfold
set +e
JAVA=`which RNAfold`
set -e
if [ ! -x "$JAVA" ]; then
	echo "Unable to find RNAfold in your PATH" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "Installing RNAfold"
	if [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "14.04" ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1404_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[  "$systemID" -eq "ubuntu" && "$VERSION_ID" == "16.04"  ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1604_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "16.10" ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1610_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "17.04"  ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		wget "$RNAFold_1704_URL"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "17.10" ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1710_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "18.04"  ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1804_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	elif [[ "$systemID" -eq "ubuntu" && "$VERSION_ID" == "18.10" ]]; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "Downloading RNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		cd ""$miRPara_PATH"/required_packages/" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
		wget "$RNAFold_1810_URL"
		echo "running 'sudo dpkg -i python-rna_2.4.11-1_amd64.deb'"
		sudo dpkg -i python-rna_2.4.11-1_amd64.deb
	fi
fi


##install fasta formatterVERSION_ID" -eq VERSION_ID" -eq
if command -v fasta_formatter >/dev/null; then
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	sudo apt-get install gcc g++ pkg-config wget
	sudo apt-get install fastx-toolkit
fi



echo "checking for Anaconda/Miniconda package" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log


##checks if conda is installed
if command -v conda >/dev/null; then
	#installs miRPara dependencies through conda
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "conda is installed, Installing other dependencies" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	conda update conda -y
	conda install -c bioconda perl-getopt-long
	conda install -c bioconda gnuplot
	if command -v cpan >/dev/null; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	else
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is not installed, installing cpan" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		conda install -c bioconda perl-cpan-shell
		conda install -c bioconda gnuplot
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	fi
else
	#installs miniconda if not installed
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "Downloading and installing anaconda" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	wget "$MiniConda_URL"
	bash Miniconda3-latest-Linux-x86_64.sh -b --license y -p "$miRPV_PATH"/src/tools/miniconda/
	echo "export PATH=""$miRPV_PATH"/src/tools/miniconda/bin:'$PATH'"" >> ~/.bashrc
	source ~/.bashrc
	conda install -c bioconda perl-getopt-long
	conda install -c bioconda gnuplot
	if command -v cpan >/dev/null; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		perl -MCPAN -e 'install Getopt::Long'
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	else
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is not installed, installing cpan" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		conda install -c bioconda perl-cpan-shell
		conda install -c bioconda gnuplot
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "cpan is installed, installing perl dependences" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		perl -MCPAN -e 'install Getopt::Long'
		perl -MCPAN -e 'install threads'
		perl -MCPAN -e 'install threads::shared'
		perl -MCPAN -e 'install Cwd'
		perl -MCPAN -e 'install File::chdir'
		perl -MCPAN -e 'install Algorithm::SVM'
	fi
fi

if command -v conda >/dev/null; then
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "anaconda is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "anaconda inatallation failed. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
fi

echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
echo "downloadin miRPara" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log

#wget "https://github.com/pradyumnasagar/miRPara/archive/master.zip" -O "$miRPV_PATH"/tools/miRPara/miRPara.zip || echo "failed to download miRPara" && exit #download miRPara and store in miRPara dir in miRPV exit script if fails

wget "$miRPara_URL" -O "$miRPara_PATH"/miRPara.zip || read -r -p "`echo -e '\n miRPara download failed. \n Closing installation in 500 seconds or press any key to close immediately \n\n'`" -t 500 -n 1 -s | echo "miRPara download failed.\n\n" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit #download miRPara and store in miRPara dir in miRPV exit script if fails


cd "$miRPara_PATH" || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
unzip "$miRPara_PATH"/miRPara.zip
mv "$miRPara_PATH"/miRPara-master "$miRPV_PATH"/tools/miRPara/miRPara
cp "$miRPara_PATH"/miRPara/mirpara6.3.tar.gz "$miRPV_PATH"/tools/miRPara/
cp "$miRPara_PATH"/miRPara/miRPara/organisms.txt.gz "$miRPara_PATH"/miRPara/models/miRBase/current/organisms.txt.gz
cp "$miRPara_PATH"/miRPara/miRPara/mature.fa.gz "$miRPara_PATH"/miRPara/models/miRBase/current/mature.fa.gz
rm -rf "$miRPara_PATH"/miRPara/miRPara
tar -xzf mirpara6.3.tar.gz

mv "$miRPara_PATH"/miRPara/required_packages/unafold-3.8.tar.gz "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
cd "$miRPara_PATH"/required_packages/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
tar -xzf "$miRPara_PATH"/required_packages/unafold-3.8.tar.gz
mv "$miRPara_PATH"/miRPara/required_packages/libsvm-3.14.tar.gz "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
cd "$miRPara_PATH"/required_packages/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
tar -xzf "$miRPara_PATH"/required_packages/libsvm-3.14.tar.gz
mv "$miRPara_PATH"/miRPara/required_packages/ct2out/* "$miRPara_PATH"/required_packages/ct2out/

#install dependencies
##Install UNAFOLD id not installed
if command -v UNAFold.pl >/dev/null; then
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "UNAFold is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "installing UNAFold" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	cd "$miRPara_PATH"/required_packages/unafold-3.8/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
	autoconf
	./configure
	make
	echo "running 'sudo make install'"
	sudo make install
#echo "running 'sudo cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl "$miRPara_PATH"/bin/'"
	cp "$miRPara_PATH"/required_packages/unafold-3.8/scripts/UNAFold.pl "$miRPara_PATH"/bin/
	if command -v UNAFold.pl >/dev/null; then
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "UNAFold is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	else
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "UNAFold inatallation failed. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	fi
fi

##install ct2out
cd "$miRPara_PATH"/required_packages/ct2out/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
if command -v ct2out >/dev/null; then
	echo "ct2out is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	if command -v gfortran >/dev/null;then
		gfortran ct2out.f -o ct2out
		cp ct2out "$miRPV_PATH"/bin/
	else
		conda install -c conda-forge fortran-compiler
		gfortran ct2out.f -o ct2out
		cp ct2out "$miRPV_PATH"/bin/
	fi
fi
if command -v ct2out >/dev/null;then
	echo "ct2out is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "ct2out installation failed. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
fi

##install libSVM
cd "$miRPara_PATH"/required_packages/libsvm-3.14/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
if command -v svm-predict >/dev/null; then
	echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	echo "libSVM is installed" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	make
	sudo cp svm-predict /usr/bin/
	if command -v svm-predict >/dev/null; then
		echo ""
	else
		echo $(date) | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
		echo "libSVM failed to install. Please install manually" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
	fi
fi
cd "$miRPara_PATH"/ || echo "$miRPV_PATH does not exist" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log | exit
rm test/result/test.pmt
rm test/result/test_level_1.out
perl "$miRPara" test/test.fa
if [ ! -f "$miRPara_PATH"/test.pmt ]; then
	echo "Test result file not found! miRPara test failed. Resuming installation" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
else
	echo "miRPara test Successful" | tee -a "$miRPV_PATH"/results/log/miRPV_install.log
fi



#copy necessacary files
cp "$miRPV_PATH"/miRPV "$miRPV_PATH"/bin/


#export paths

export PATH=$PATH:"$miRPV_PATH"/bin
#export PATH=$PATH:
#export PATH=$PATH:

#After Installations

##check packages


##if failed
grep 'failed' "$miRPV_PATH"/results/log/miRPV_install.log > "$miRPV_PATH"/results/log/failed.long
faillog="$miRPV_PATH"/results/log/failed.long
if [[ -s "$faillog" ]]; then
	echo "Installation of some dependencies failed, please reffer "$miRPV_PATH"/results/log/failed.long and install required package for optimal usage of pipeline or use Virtual Machine provided at http://slsdb.manipal.edu"
else
	echo "Installation finished without any errors. run miRPV [miRPV -h] for help"
fi
