let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('versions')

function! vital#versions#is_numeric(...)
  return call(s:V.is_numeric, a:000)
endfunction

function! vital#versions#is_integer(...)
  return call(s:V.is_integer, a:000)
endfunction

function! vital#versions#is_float(...)
  return call(s:V.is_float, a:000)
endfunction

function! vital#versions#is_string(...)
  return call(s:V.is_string, a:000)
endfunction

function! vital#versions#is_funcref(...)
  return call(s:V.is_funcref, a:000)
endfunction

function! vital#versions#is_list(...)
  return call(s:V.is_list, a:000)
endfunction

function! vital#versions#is_dict(...)
  return call(s:V.is_dict, a:000)
endfunction

function! vital#versions#is_empty(arg)
  if vital#versions#is_string(a:arg)
    return a:arg == ''
  endif
  if vital#versions#is_numeric(a:arg)
    return a:arg == 0
  endif
  if vital#versions#is_list(a:arg)
    return empty(a:arg)
  endif
  if vital#versions#is_dict(a:arg)
    return empty(a:arg)
  endif
endfunction

function! vital#versions#substitute_path_separator(...)
  return call(s:V.substitute_path_separator, a:000)
endfunction

function! vital#versions#yank(text)
  let @" = a:text
  if has('clipboard')
    let @* = @"
  endif
endfunction

function! vital#versions#has_vimproc()
  return call(s:V.has_vimproc, [])
endfunction

function! vital#versions#iconv(...)
  return call(s:V.iconv, a:000)
endfunction

function! vital#versions#system(...)
  if g:versions#debug
    echomsg a:000[0]
  endif
  let s:system = vital#versions#has_vimproc() ?
        \ function('vimproc#system') :
        \ function('system')
  return vital#versions#trim_cr(
        \   vital#versions#iconv(
        \     call(s:system, a:000),
        \     'utf-8',
        \     &encoding
        \   )
        \ )
endfunction

function! vital#versions#execute(...)
  if g:versions#debug
    echomsg join(a:000, ' ')
  endif
  execute join(a:000, ' ')
endfunction

function! vital#versions#echomsgs(messages)
  let messages = vital#versions#trim_cr(a:messages)
  for message in [' '] + split(messages, "\n")
    echomsg message
  endfor
endfunction

function! vital#versions#trim(...)
  return vital#versions#trim_right(vital#versions#trim_left(a:000[0]))
endfunction

function! vital#versions#trim_right(...)
  return substitute(a:000[0], get(a:000, 1, '\s*') . '$', '', 'g')
endfunction

function! vital#versions#trim_left(...)
  return substitute(a:000[0], '^' . get(a:000, 1, '\s*'), '', 'g')
endfunction

function! vital#versions#trim_cr(...)
  return substitute(a:000[0], '\r', '', 'g')
endfunction

function! vital#versions#yesno(message, ...)
  let allow_empty = get(a:000, 0, 1)
  let yesno = input(a:message . ' [yes/no] : ')
  while yesno !~? '^\%(y\%[es]\|n\%[o]\)$'
    redraw
    if yesno == '' && allow_empty
      echo 'canceled.'
      break
    endif
    let yesno = input(a:message . ' [yes/no] : ')
  endwhile

  return yesno =~? 'y\%[es]'
endfunction

function! vital#versions#define(dict, key, value)
  if !has_key(a:dict, a:key)
    let a:dict[a:key] = a:value
  endif
endfunction

function! vital#versions#padding(str, num)
  return strpart(a:str . repeat(' ', a:num), 0, a:num)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

