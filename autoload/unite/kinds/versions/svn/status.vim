let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#svn#status#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/svn/status',
      \ 'default_action': 'diff',
      \ 'action_table': {},
      \ }

let s:kind.action_table.file_delete = {
      \ 'description': 'delete file by vimfiler.',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.file_delete.func(candidates)
  if !exists(':VimFiler')
    echo 'vimfiler is not installed.'
    return
  endif

  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  for candidate in candidates
    let candidate.action__path = candidate.source__args.path . '/' . candidate.action__status.path
    let candidate.kind = 'file'
    call unite#take_action('vimfiler__delete', candidate)
  endfor
endfunction

let s:kind.action_table.diff = {
      \ 'description': 'display diff.',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.diff.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  call versions#call('unite#kinds#versions#svn#status#diff',
        \ [candidates],
        \ fnamemodify(candidates[0].source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#svn#status#diff(candidates)
  for candidate in a:candidates
    call versions#diff#file_with_string(candidate.action__status.path, {
          \   'name': printf('[REMOTE] %s',  candidate.action__status.path),
          \   'string': versions#command('cat', {
          \     'path': candidate.action__status.path,
          \   }, {
          \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
          \   })
          \ })
  endfor
endfunction

let s:kind.action_table.commit = {
      \ 'description': 'commit status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.commit.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  call versions#command('commit', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
endfunction

let s:kind.action_table.add = {
      \ 'description': 'add status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.add.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('add', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.delete = {
      \ 'description': 'delete status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.delete.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('delete', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.revert = {
      \ 'description': 'revert status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.revert.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('revert', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.resolved = {
      \ 'description': 'resolved status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.resolved.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('resolved', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

