let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#git#status#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/git/status',
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
  call versions#call('unite#kinds#versions#git#status#diff',
        \ [candidates],
        \ fnamemodify(candidates[0].source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#git#status#diff(candidates)
  for candidate in a:candidates
    call versions#diff#file_with_string(candidate.action__status.path, {
          \   'name': printf('[REMOTE] %s',  candidate.action__status.path),
          \   'string': versions#command('show', {
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

let s:kind.action_table.checkout = {
      \ 'description': 'checkout status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.checkout.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('checkout', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.checkout_theirs = {
      \ 'description': 'checkout status with --theirs.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.checkout_theirs.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('checkout', {
        \   'theirs': 1,
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.checkout_ours = {
      \ 'description': 'checkout status with --ours.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.checkout_ours.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('checkout', {
        \   'ours': 1,
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
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

let s:kind.action_table.reset = {
      \ 'description': 'reset status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('reset', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.reset_soft = {
      \ 'description': 'reset status with soft.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset_soft.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('reset', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path'),
        \   'soft': 1
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.reset_hard = {
      \ 'description': 'reset status with hard.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset_hard.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('reset', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path'),
        \   'hard': 1
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.rm = {
      \ 'description': 'remove status.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.rm.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('rm', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path')
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.rm_cached = {
      \ 'description': 'remove status with cached.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.rm_cached.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('rm', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path'),
        \   'cached': 1
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let s:kind.action_table.rm_force = {
      \ 'description': 'remove status with force.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.rm_force.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  let messages = versions#command('rm', {
        \   'paths': map(deepcopy(candidates), 'v:val.action__status.path'),
        \   'force': 1
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
  call vital#versions#echomsgs(messages)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

