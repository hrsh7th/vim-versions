let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#debug', 0)
call vital#versions#define(g:, 'versions#type', {
      \ 'git': '.git',
      \ 'svn': '.svn',
      \ })
call vital#versions#define(g:, 'versions#info', {
      \ 'git': '(%s)-(%b)',
      \ 'svn': '(%s)',
      \ })

let s:type_cache = {}
function! versions#get_type(path)
  let path = fnamemodify(vital#versions#substitute_path_separator(a:path), ':p:h')

  if exists('s:type_cache[path]') && s:type_cache[path] != ''
    return s:type_cache[path]
  endif

  for type in keys(g:versions#type)
    if executable(type) && finddir(g:versions#type[type], path . ';', ':p:h:h') != ''
      let s:type_cache[path] = type
    endif
  endfor

  return get(s:type_cache, path, '')
endfunction

function! versions#is_type(type, path)
  return a:type == versions#get_type(a:path)
endfunction

function! versions#get_relative_path(path)
  if fnamemodify(getcwd(), ':p') != fnamemodify(a:path, ':p')
    return './' . fnamemodify(a:path, ':.')
  endif
  return ''
endfunction

function! versions#get_root_dir(path)
  let type = versions#get_type(a:path)
  if !exists('g:versions#type[type]')
    throw 'versions#get_root_dir: vcs not detected.'
  endif

  let path = vital#versions#trim_right(
        \ fnamemodify(vital#versions#substitute_path_separator(a:path), ':p'),
        \ '/')
  while !filereadable(path . '/' . g:versions#type[type]) && !isdirectory(path . '/' . g:versions#type[type])
    let path = vital#versions#trim_right(
          \ fnamemodify(path, ':p:h:h'),
          \ '/')
  endwhile
  return vital#versions#trim_right(vital#versions#substitute_path_separator(path), '/')
endfunction

function! versions#get_working_dir()
  let working_dir = expand('%')
  if exists('b:vimshell.current_dir')
    let working_dir = b:vimshell.current_dir
  endif
  if exists('b:vimfiler.current_dir')
    let working_dir = b:vimfiler.current_dir
  endif
  if exists('b:unite')
    let working_dir = fnamemodify(bufname(b:unite.prev_bufnr), ':p')
  endif
  if !isdirectory(working_dir) && !filereadable(working_dir)
    let working_dir = expand('%:p:h')
  endif
  return fnamemodify(working_dir, ':p')
endfunction

function! versions#command(command, command_args, global_args)
  " get command working dir.
  let working_dir = get(vital#versions#is_dict(a:global_args) ? a:global_args : {},
        \ 'working_dir',
        \ versions#get_working_dir())

  " try versions detect.
  if versions#get_type(working_dir) == ''
    throw 'versions#command: vcs not detected.'
  endif

  " do command.
  let command = split(a:command, ':')
  let function_name = printf('versions#type#%s#%s#%s',
        \ versions#get_type(working_dir),
        \ get(command, 0, ''),
        \ get(command, 1, 'do'))
  return versions#call(
        \   function(function_name),
        \   [vital#versions#is_dict(a:command_args) ? filter(a:command_args, "!vital#versions#is_empty(v:val)") : {}],
        \   working_dir
        \ )
endfunction

function! versions#info(...)
  let args = get(a:000, 0, {})
  let path = get(args, 'path', getcwd())
  let type = versions#get_type(path)
  if type == '' || path == ''
    return ''
  endif
  let format = get(args, 'format', g:versions#info[type])

  try
    let function_name = printf('versions#type#%s#info#do', type)
    return versions#call(function(function_name),
          \ [{ 'format': format }],
          \ path)
  catch
    if g:versions#debug
      echomsg v:exception
    endif
  endtry
  return ''
endfunction

function! versions#call(function, args, working_dir)
  let current_dir = getcwd()
  call vital#versions#execute('lcd', a:working_dir)
  try
    let result = call(a:function, a:args)
  catch
    let result = ''
    if g:versions#debug
      echomsg v:exception
    endif
  finally
    call vital#versions#execute('lcd', current_dir)
  endtry
  return result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

