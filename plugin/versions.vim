if exists('g:loaded_versions')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:loaded_versions = 1

command! -nargs=* UniteVersions call s:unite_versions(<q-args>)
function! s:unite_versions(args)
  let args = split(get(a:, 'args', ''), ':')

  if empty(args)
    return unite#start([['versions']])
  endif

  for type in keys(g:versions#type)
    if {'unite#sources#versions#' . type . '#' . args[0] . '#check'}(type, args[1:])
      return unite#start([[printf('versions/%s/%s',
            \   type,
            \   args[0]
            \ )] + args[1:]])
    endif
  endfor

  echomsg 'vcs not detected.'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

