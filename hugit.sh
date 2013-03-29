# hugit: GIT FOR HUMANS
# Author: Alesh Kajzar

# remove a resolved file from 'hugit'
function resolved(){
	resolved_file=`cat hugit | egrep --invert-match "^${1}$"`
	echo "$resolved_file" > hugit
}

# check if all conflicts are resolved
# @return 0 if everything is resolved
function check_resolved(){
	if [ -a "hugit" ]; then
		# get files from file hugit
		for i in `cat hugit | egrep "^[^#\n]"`
		do
			unresolved_lines=`cat "$i" | egrep "(^<<<<<<<)|(^=======)|(^>>>>>>>)" -c`
			
			if [ "$unresolved_lines" == "0" ]; then
				write=`cat hugit | egrep --invert-match "^${i}$"`
				echo "$write" > hugit
			fi
		done
		
		unresolved_yet=`cat hugit | egrep -c "^[^#\n]"`
		if [ "$unresolved_yet" != "0" ]; then
			cat hugit >&2
			return 1
		else
			rm -f hugit
			return 0
		fi
	else
		return 0
	fi
}

# Sends data to shared git
# @param $1 message
function check_in(){
	git add -A > /dev/null 2> /dev/null
	git commit -a -m "$1" > /dev/null 2> /dev/null

	get_lastest_version "check-in"
	ret=$?

	if [ "$ret" -eq "0" ]; then
		git checkout master > /dev/null 2> /dev/null
		git merge devel > /dev/null 2> /dev/null
		git push
		git checkout devel > /dev/null 2> /dev/null
	fi 
}

# Continues with uploading files to the shared directory.
function check_in_continue(){
	get_lastest_version_continue
	git checkout master > /dev/null 2> /dev/null
	git merge devel > /dev/null 2> /dev/null
	git push
	git checkout devel > /dev/null 2> /dev/null
}

# Gets lastest version from shared directory.
function get_lastest_version(){
	git add -A > /dev/null 2> /dev/null
	git commit -a -m "saved work" > /dev/null 2> /dev/null

	git checkout master > /dev/null 2> /dev/null
	git pull --rebase > /dev/null 2> /dev/null
	git checkout devel > /dev/null 2> /dev/null
	git rebase master > /dev/null 2> /dev/null
	
	write=`git diff --name-only --diff-filter=U`
	if [ "$write" != "" ]; then
		message="# You have to resolve conflict in these files:\n$write\n\n# Then you can use '$1 --continue'\n\n#If you beleive, that this is an error and file is resolved, use command 'resolved FILE'."
		echo -e "$message" > hugit
		echo -e "$message"
		return 1
	fi
}

# Continues with getting filesfrom the shared directory.
function get_lastest_version_continue(){
	git add . > /dev/null 2> /dev/null
	git rebase --continue > /dev/null 2> /dev/null
}

# Initials new shared directory
function init_shared(){
	git init  > /dev/null 2> /dev/null
	if [ "$(ls -A .)" ]; then
		echo "">/dev/null
	else
		write_help > README_HUGIT;
	fi
	git add -A > /dev/null 2> /dev/null
	git commit -m "Initial commit." > /dev/null 2> /dev/null
	git config receive.denyCurrentBranch ignore > /dev/null 2> /dev/null
	echo "Git initialized."
}

# Creates a clone of the shared directory
function clone(){
	git clone "$1/" "$2/" > /dev/null 2> /dev/null
	cd "$2/" > /dev/null 2> /dev/null
	git checkout -b devel > /dev/null 2> /dev/null
}

# Writes help message
function write_help(){
	echo -e "hugit: GIT FOR HUMANS"
	echo -e "--------------------"
	echo -e "-h, --help\t\t\tPrints help.\n"
	echo -e "check-in MESSAGE\t\tSaves data to the shared repository."
	echo -e "\t\t\t\tMESSAGE: required parameter - it's a short comment, what did you change."
	echo -e "check-in --continue\t\tIf there is a conflict, you have to resolve it and use this command to continue."
	echo
	echo -e "get-lastest-version\t\tGets the lastest version from the shared repository."
	echo -e "get-lastest-version --continue\tIf there is a conflict, you have to resolve it and use this command to continue."
	
	echo
	echo -e "init-shared\t\t\tInitializes shared repository + creates initial commit."
	echo -e "clone SHARED_DIR DEST_DIR\tClones shared repository in SHARED_DIR to DEST_DIR."

}

# Process parameters
if [ "$1" == "get-lastest-version" ] && [ "$2" == "--continue" ]; then
	check_resolved
	ret=$?
	
	if [ "$ret" == "0" ]; then
		get_lastest_version_continue
	fi

elif [ "$1" == "get-lastest-version" ]; then
	check_resolved
	ret=$?
	
	if [ "$ret" == "0" ]; then
		get_lastest_version "get-lastest-version"
	fi
	
elif [ "$1" == "check-in" ] && [ "$2" == "--continue"  ]; then
	check_resolved
	ret=$?
	
	if [ "$ret" == "0" ]; then
		check_in_continue
	fi

elif [ "$1" == "check-in" ]; then
	check_resolved
	ret=$?
	if [ "$ret" == "0" ]; then
		if [ "$2" != "" ]; then
			check_in "$2"
		else
			echo "Missing parameter MESSAGE, e. c.: check-in \"Minor edits in foo.py.\""
			
			echo -e "\ncheck-in MESSAGE\t\tSaves data to the shared repository."
			echo -e "\t\t\t\tMESSAGE: required parameter - it's a short comment, what did you change."
		fi
	fi
	
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	write_help
	
elif [ "$1" == "clone" ]; then
	clone "$2" "$3"
	
elif [ "$1" == "resolved" ]; then
	resolved "$2"

elif [ "$1" == "init-shared" ]; then
	init_shared

else
	write_help>&2
fi
