# LOG_PATH="/Users/USER/charging.txt"

NO_CHARGING_PORTS=("4" "3") # Bash array of strings

# https://github.com/actuallymentor/battery
function enable_charging() {
	sudo smc -k CH0B -w 00
	sudo smc -k CH0C -w 00
}

function disable_charging() {
	sudo smc -k CH0B -w 02
	sudo smc -k CH0C -w 02
}

function main() {
    hex_val=$(smc -r -k AC-W | awk '{print $4}')
    if [[" ${NO_CHARGING_PORTS[*]} " =~ " ${hex_val} " ]]; then
        # echo "$(date +%T) - $hex_val - Disabled charging" >> "$LOG_PATH"
		disable_charging
	else
	    # echo "$(date +%T) - $hex_val - Enabled charging" >> "$LOG_PATH"
    	enable_charging
    fi
}

main