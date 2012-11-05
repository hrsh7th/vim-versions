let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#debug', 0)

" TODO: refactor.
let s:types = [
      \ 'git',
      \ 'svn',
      \ ]

" TODO: refactor.
let s:type_dir_map = {
      \ 'git': '.git',
      \ 'svn': '.svn',
      \ }

let s:type_cache = {}

function! versions#get_type(path)
  let path = fnamemodify(vital#versions#substitute_path_separator(a:path), ':p:h')
  for type in s:types
    if executable(type) && finddir(s:type_dir_map[type], path . ';', ':p:h:h') != ''
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
  return './'
endfunction

function! versions#get_root_dir(path)
  let type = versions#get_type(a:path)
  if !exists('s:type_dir_map[type]')
    throw 'versions#get_root_dir: vcs not detected.'
  endif

  let path = fnamemodify(vital#versions#substitute_path_separator(a:path), ':p')
  while finddir(s:type_dir_map[type], fnamemodify(path, ':p:h:h') . ';') != ''
    let path = fnamemodify(path, ':p:h:h')
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
  return fnamemodify(working_dir, ':p:h')
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
  let function_name = printf('versions#type#%s#%s#do',
        \ versions#get_type(working_dir), a:command)
  return versions#call(
        \   function(function_name),
        \   [vital#versions#is_dict(a:command_args) ? filter(a:command_args, "!vital#versions#is_empty(v:val)") : {}],
        \   working_dir
        \ )
endfunction

function! versions#call(function, args, working_dir)
  let current_dir = getcwd()
  call vital#versions#execute('lcd', a:working_dir)
  try
    let result = call(a:function, a:args)
  finally
    call vital#versions#execute('lcd', current_dir)
  endtry
  return result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

