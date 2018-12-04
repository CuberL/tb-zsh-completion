#compdef tb

__trim() {
    arg=${@:1}
    echo -n "$arg" | sed -e 's/\(^ *\)//' -e 's/\( *$\)//'
}

__get_arg_by_pos() {
	pos=$1
	cmd="echo -n \"$words\" | awk '{print \$$pos}'"
	eval $cmd	
}

__now_arg_pos() {
	lastOne="${words: -1}"
	argCount=$(echo "$words" | awk '{for(i=1; i<=NF; i++) print $i}' | wc -l)
	argCount=$(__trim "$argCount")
	if [ "$lastOne" = " " ]; then
		((argCount=argCount+1))
	fi
	echo -n "$argCount"
}

__tb_task() {
	pos=$(__now_arg_pos)
	now=$(__get_arg_by_pos $pos)	
	if [ "${now:0:1}" = "@" ]; then
		tags=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(.boards | .[])"' | sort | uniq)
		_alternative \
			"tags:tags:(($tags))"
 
	fi
}

__tb_list() {
	tags=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(.boards | .[])"' | grep '@' | sort | uniq | sed 's/@//')
	_alternative \
		"tags:tags:(($tags))"
}

__tb_multi_task() {
	pos=$(__now_arg_pos)
	zstyle ":completion::complete:tb:tasks:tasks" sort no
	zstyle ":completion::complete:tb:tasks:tasks" list-colors "=*-- \[checked\]*=30;1"
	if [ $pos -gt 1 ]; then
		tasks=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(._id)\t\(.description)\t\(._timestamp)\t\(.isComplete)\t\(._isTask)"' | sort -t $'\t' -k 4 -k 3rn | awk -F "\t" '{if($5 == "false" || $4 == "false"){print $1"\\" ":" $2} else {print $1"\\" ":" "'\''[checked] '\''" $2}}')
		#tasks=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(._id)\t\(.description)\t\(._timestamp)"' | sort -t $'\t' -rnk 3 | awk -F "\t" '{print $1"\\\:"$2}')
		_alternative -C tasks \
			"tasks:tasks:(($tasks))"
	fi		
}

__tb_move() {
	pos=$(__now_arg_pos)
	zstyle ":completion::complete:tb:tasks:tasks" sort no
	zstyle ":completion::complete:tb:tasks:tasks" list-colors "=*-- \[checked\]*=30;1"
	if [ $pos -eq 2 ]; then
		tasks=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(._id)\t\(.description)\t\(._timestamp)\t\(.isComplete)\t\(._isTask)"' | sort -t $'\t' -k 4 -k 3rn | awk -F "\t" '{if($5 == "false" || $4 == "false"){print "\@"$1"\\" ":" $2} else {print "\@"$1"\\" ":" "'\''[checked] '\''" $2}}')
                _alternative -C tasks \
                    "tasks:tasks:(($tasks))"
	elif [ $pos -gt 2 ]; then
		tags=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(.boards | .[])"' | grep '@' | sort | uniq | sed 's/@//')
        _alternative \
                "tags:tags:(($tags))"		
	fi				
}

__tb_priority() {
	pos=$(__now_arg_pos)
	case $pos in
		(2)
			zstyle ":completion::complete:tb:tasks:tasks" sort no
			zstyle ":completion::complete:tb:tasks:tasks" list-colors "=*-- \[checked\]*=30;1"
			zstyle ":completion::complete:tb:tasks:priority" list-colors '=*high=1;31' '=*medium=1;33' '=*normal=1;32';
			tasks=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(._id)\t\(.description)\t\(._timestamp)\t\(.isComplete)\t\(._isTask)"' | sort -t $'\t' -k 4 -k 3rn | awk -F "\t" '{if($5 == "false" || $4 == "false"){print "\@"$1"\\" ":" $2} else {print "\@"$1"\\" ":" "'\''[checked] '\''" $2}}')
                        _alternative -C tasks \
                                "tasks:tasks:(($tasks))"
		;;
		(3)
			_alternative -C tasks \
				"priority:priority:((1\:'normal' 2\:'medium' 3\:'high'))"
		;;
	esac
}

__tb_edit() {
	pos=$(__now_arg_pos)
	case $pos in
		(2)
			zstyle ":completion::complete:tb:tasks:tasks" sort no
			zstyle ":completion::complete:tb:tasks:tasks" list-colors "=*-- \[checked\]*=30;1"
			tasks=$(cat ~/.taskbook/storage/storage.json | jq --raw-output '.[] | @sh "\(._id)\t\(.description)\t\(._timestamp)\t\(.isComplete)\t\(._isTask)"' | sort -t $'\t' -k 4 -k 3rn | awk -F "\t" '{if($5 == "false" || $4 == "false"){print "\@"$1"\\" ":" $2} else {print "\@"$1"\\" ":" "'\''[checked] '\''" $2}}')
			_alternative -C tasks \
				"tasks:tasks:(($tasks))"
			;;
		(3)
			arg_2=$(__get_arg_by_pos 2)
			check=`grep '\@[[:digit:]]\{1,\}' <<< "$arg_2" | head -n 1`
			if [ "$check" != "" ]; then
				id=${arg_2##*@}
				content=$(cat ~/.taskbook/storage/storage.json | jq --raw-output ".[] | select(._id==$id) | .description" | sed 's/:/\\:/g')
				local commands 
				commands=(
					"$content:..."
				)
				_describe -t commands 'command' commands
			fi
			;;
	esac	

}


_arguments -C \
	':command:->command' \
	'*::options:->options' 


case $state in
	(command)
		cmds=(  '--task:Create task' \
      			'--note:Create note' \
     			'--timeline:Display timeline view' \
      			'--delete:Delete item' \
      			'--check:Check/uncheck task' \
      			'--star:Star/unstar item' \
      			'--copy:Copy item description' \
	      		'--list:List items by attributes' \
      			'--find:Search for items' \
      			'--edit:Edit item description' \
     			'--move:Move item between boards' \
      			'--priority:Update priority of task' \
      			'--archive:Display archived items' \
      			'--restore:Restore items from archive' \
      			'--clear:Delete all checked items' \
      			'--help:Display help message' \
      			'--version:Display installed version')
		_describe "command" cmds      
		;;
	(options)
		cmd=$(echo "$words" | awk '{print $1}')
		case $cmd in 
			("-t" | "--task")
				__tb_task		    
			;;
			("-d" | "-c" | "-s" | "-y" | "--delete" | "--check" | "--star" | "--copy")
				__tb_multi_task
			;;
			("-e" | "--edit")
				__tb_edit
			;;
			("-m" | "--move" )
				__tb_move
			;;
			("-l" | "--list" )
				__tb_list
			;;
			("-p" | "--priority")
				__tb_priority
			;;
		esac
		;;
esac


