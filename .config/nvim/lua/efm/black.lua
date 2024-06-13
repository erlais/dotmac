local cmd = "black --no-color -q --skip-string-normalization " ..
            "$(echo ${--useless:rowStart} ${--useless:rowEnd} | xargs -n4 -r sh -c 'echo --line-ranges=$(($1+1))-$(($3+1))') -"

return {
  formatCanRange = true,
  formatCommand = cmd,
  formatStdin = true
}
