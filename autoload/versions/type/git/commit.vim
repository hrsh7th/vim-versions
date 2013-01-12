let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#type#git#commit#filepath', '.git')
call vital#versions#define(g:, 'versions#type#git#commit#filename', 'COMMIT_EDITMSG')
call vital#versions#define(g:, 'versions#type#git#commit#filetype', 'gitcommit')
call vital#versions#define(g:, 'versions#type#git#commit#ignore',
      \ '--This line, and those below, will be ignored--')

let s:paths = []

function! versions#type#git#commit#do(args)
  let cwd = getcwd()
  let t:versions_previous_tab = localtime()

  call vital#versions#execute('tabedit', s:get_file(getcwd()))
  call vital#versions#execute('set', 'filetype=' . g:versions#type#git#commit#filetype)
  call vital#versions#execute('lcd', cwd)

  let output = vital#versions#system(printf('git commit --dry-run --quiet -- %s',
        \ join(
        \   map(deepcopy(a:args.paths),
        \     'vital#versions#substitute_path_separator(v:val)'
        \   ),
        \   ' '
        \ )))

  " append diff.
  let output .= g:versions#type#git#commit#ignore . "\n"
  let output .= s:get_unified_diff(a:args.paths)

  silent % delete _
  put=output
  call setpos('.', [bufnr('%'), 0, 0])
  set nomodified

  let b:versions = {
        \ 'context': {
        \   'type': 'git',
        \   'command': 'commit',
        \   'args': a:args,
        \   'working_dir': getcwd(),
        \   }
        \ }

  augroup VersionsGitCommit
    autocmd!
    autocmd! BufWinEnter <buffer> setlocal bufhidden=wipe nobuflisted noswapfile
    autocmd! BufWritePre <buffer> g/^#\|^\s*$/d | execute '%s/' . g:versions#type#git#commit#ignore . '\_.*//g'
    autocmd! BufWritePost <buffer> call versions#type#git#commit#finish()
  augroup END
endfunction

function! versions#type#git#commit#finish()
  if !exists('b:versions.context.args')
    throw 'versions#type#git#commit: b:versions.context.args is not found.'
  endif
  if !exists('b:versions.context.working_dir')
    throw 'versions#type#git#commit: b:versions.context.working_dir is not found.'
  endif
  if exists('b:versions.context.type') && b:versions.context.type != 'git'
    throw 'versions#type#git#commit: invalid b:versions.context.type.'
  endif
  if exists('b:versions.context.command') && b:versions.context.command != 'commit'
    throw 'versions#type#git#commit: invalid b:versions.context.command.'
  endif

  if !vital#versions#yesno('commit?', 0)
    return
  endif

  call versions#call(function(printf('<SNR>%d_commit', s:SID())),
        \ [b:versions.context.args],
        \ b:versions.context.working_dir)

  tabclose

  if exists('*gettabvar')
    " search previous tab.
    for tabnr in filter(range(1, tabpagenr('$')),
          \ "gettabvar(tabnr, 'versions_previous_tab') > 0")
      execute 'tabnext' tabnr
      unlet! t:versions_previous_tab
    endfor
  endif
endfunction

function! s:commit(args)
  let output = vital#versions#system(printf('git commit -F %s -- %s',
        \ s:get_file(getcwd()),
        \ join(
        \   map(deepcopy(a:args.paths),
        \     'vital#versions#substitute_path_separator(v:val)'
        \   ),
        \   ' '
        \ )))
  call vital#versions#echomsgs(output)
endfunction

function! s:get_unified_diff(paths)
  let outputs = []
  for path in a:paths
    call add(outputs, vital#versions#system(printf('git diff HEAD -- %s',
          \ vital#versions#substitute_path_separator(path))))
  endfor
  return "\n" . join(outputs, "\n\n\n")
endfunction

function! s:get_file(dir)
  return printf('%s/%s/%s',
        \   versions#get_root_dir(a:dir),
        \   g:versions#type#git#commit#filepath,
        \   g:versions#type#git#commit#filename
        \ )
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

