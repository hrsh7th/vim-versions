let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#type#svn#commit#filename', 'svn-commit.tmp')
call vital#versions#define(g:, 'versions#type#svn#commit#editorcmd', 'vim')
call vital#versions#define(g:, 'versions#type#svn#commit#ignore',
      \ '--This line, and those below, will be ignored--')

function! versions#type#svn#commit#do(args)
  let cwd = getcwd()
  let t:versions_previous_tab = localtime()

  call versions#type#svn#commit#create_message(a:args.paths)
  call vital#versions#execute('tabedit', s:get_file(getcwd()))
  call vital#versions#execute('edit!')
  call vital#versions#execute('lcd', cwd)

  let b:versions = {
        \ 'context': {
        \   'type': 'svn',
        \   'command': 'commit',
        \   'args': a:args,
        \   'working_dir': getcwd(),
        \   }
        \ }

  augroup VersionsSvnCommit
    autocmd!
    autocmd! BufWinEnter <buffer> setlocal bufhidden=wipe nobuflisted noswapfile
    autocmd! BufWritePre <buffer> execute '%s/' . g:versions#type#svn#commit#ignore . '\_.*//g'
    autocmd! BufWritePost <buffer> call versions#type#svn#commit#finish()
  augroup END
endfunction

function! versions#type#svn#commit#finish()
  if !exists('b:versions.context.args')
    throw 'versions#type#svn#commit: b:versions.context.args is not found.'
  endif
  if !exists('b:versions.context.working_dir')
    throw 'versions#type#svn#commit: b:versions.context.working_dir is not found.'
  endif
  if exists('b:versions.context.type') && b:versions.context.type != 'svn'
    throw 'versions#type#svn#commit: invalid b:versions.context.type.'
  endif
  if exists('b:versions.context.command') && b:versions.context.command != 'commit'
    throw 'versions#type#svn#commit: invalid b:versions.context.command.'
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
          \ "gettabvar(v:val, 'versions_previous_tab') > 0")
      execute 'tabnext' tabnr
      unlet! t:versions_previous_tab
    endfor
  endif
endfunction

function! versions#type#svn#commit#create_message(paths)
  let statuses = versions#command('status', {
        \   'paths': a:paths
        \ }, {
        \   'working_dir': getcwd(),
        \ })
  call writefile(['', g:versions#type#svn#commit#ignore, ''] + map(filter(statuses,
        \   "index(a:paths, v:val.path) > -1"),
        \   "substitute(v:val.line, '\n', '', 'g')"
        \ ),
        \ s:get_file(getcwd()))
endfunction

function! s:commit(args)
  let output = vital#versions#system(printf('svn commit -F %s %s',
        \ s:get_file(getcwd()),
        \ join(
        \   map(deepcopy(a:args.paths),
        \     'vital#versions#substitute_path_separator(v:val)'
        \   ),
        \   ' '
        \ )))
  call delete(s:get_file(getcwd()))
  call vital#versions#echomsgs(output)
endfunction

function! s:get_file(dir)
  return printf('%s/%s',
        \   vital#versions#trim_right(a:dir, '/'),
        \   g:versions#type#svn#commit#filename
        \ )
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

