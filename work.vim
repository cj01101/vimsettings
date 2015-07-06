command! DebugStackTrace execute "normal! gg0df\"$,D:s/   at/\<c-v>\<CR>   at/g\<CR>vip:s/\\\\r\\\\n//g\<CR>"
command! DebugString execute "normal! gg0df\"$,D"
command! DebugXml execute "normal! gg0df\"$,D:s/\\\\//g\<CR>"

command! ShiloBrackets execute "normal! :s/&lt;/</g\<CR>:s/&gt;/>/g\<CR>"

