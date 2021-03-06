# Show spec files which include contexts from file
#
# context usage:
#   rspec_files_containing_shared_contexts_from_file spec/support/shared_contexts/my_shared_contexts.rb
function rspec_files_containing_shared_contexts_from_file() {
  local rspec_files_containing_shared_contexts_from_file_RECURSION_IGNORE
  # shellcheck disable=SC2116
  rspec_files_containing_shared_contexts_from_file_RECURSION_IGNORE=$(IFS="|" echo "$*")
  case $IGNORE in
    "");;
    *)
      rspec_files_containing_shared_contexts_from_file_RECURSION_IGNORE+="|$IGNORE"
      ;;
  esac
  parallel \
    "grep -E \"shared_contexts \\\"(.*)\\\"|shared_contexts '(.*)'|shared_contexts_for \\\"(.*)\\\"|shared_contexts_for '(.*)'\" {} | \
     sed -e \"s/shared_contexts \\\"/~/\" -e \"s/shared_contexts '/~/\" -e \"s/shared_contexts_for \\\"/~/\" -e \"s/shared_contexts_for '/~/\" -e \"s/\\\" do/~/\" -e \"s/' do/~/\" | \
     cut -f 2 -d '~' | \
     parallel -I '<>' \"
        rg <> $(spec_directories | tr "\n" ' ') | \
        grep 'include_contexts' | \
        cut -f 1 -d : | \
        sort -u
     \" | \
     grep \"\\\.rb$\" | \
     sort -u
    " \
    ::: \
    "$@" | sort -u | grep -vE "^$rspec_files_containing_shared_contexts_from_file_RECURSION_IGNORE$" | \
      parallel \
        "if (echo {} | grep -q \"_spec\\\.rb$\") then
           echo {}
         else
           source $HOME/projects/ruby_dev_shell_aliases/spec_directories.sh && \
           source $HOME/projects/ruby_dev_shell_aliases/rspec_files_containing_shared_contexts_from_file.sh && \
           IGNORE='$rspec_files_containing_shared_contexts_from_file_RECURSION_IGNORE' rspec_files_containing_shared_contexts_from_file {}
         fi
        " | \
      sort -u
}
