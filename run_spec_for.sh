# Run spec for given file/line
#
# Example usage:
#
# run_spec_for app/model/user.rb # will run `rspec spec/model/user_spec.rb`
# run_spec_for spec/model/user_spec.rb:8472 # will run `rspec spec/model/user_spec.rb:8472`
function run_spec_for() {
  local run_spec_for_COUNT=0
  local run_spec_for_FILE
  local run_spec_for_FILES=()
  for run_spec_for_FILE in `existing_spec_for $@`
  do
    run_spec_for_FILES+=$run_spec_for_FILE
    run_spec_for_COUNT+=1
  done
  local run_spec_for_SINGLE_LINES=()
  for run_spec_for_FILE in $@
  do
    case $run_spec_for_FILE in
      *_spec.rb:[1-9] | *_spec.rb:[1-9][0-9] | *_spec.rb:[1-9][0-9][0-9] | *_spec.rb:[1-9][0-9][0-9][0-9] | *_spec.rb:[1-9][0-9][0-9][0-9][0-9])
        run_spec_for_SINGLE_LINES+=$run_spec_for_FILE
        ;;
    esac
  done
  if [ ${#run_spec_for_SINGLE_LINES[@]} -gt 0 ]; then
    echorun bers $run_spec_for_SINGLE_LINES || return $?
  fi
  if [ $run_spec_for_COUNT -eq 1 ]; then
    echorun bers $run_spec_for_FILES || return $?
  elif [ $run_spec_for_COUNT -gt 1 ]; then
    echorun beps $run_spec_for_FILES || return $?
  else
    echo "No specs for $@ !!!"
    return 8472
  fi
}
