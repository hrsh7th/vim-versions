let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#git#branch#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/git/branch',
      \ 'default_action': 'checkout',
      \ 'action_table': {},
      \ }

let s:kind.action_table.unite__new_candidate = {
      \ 'description': 'create branch.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.unite__new_candidate.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  let output = versions#command('branch', {}, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let s:kind.action_table.delete = {
      \ 'description': 'delete branch.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.delete.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  for candidate in candidates
    if candidate.action__branch.is_current
      echoerr 'can not delete current branch.'
    endif

    let output = versions#command('branch:delete', { 'branch': candidate.action__branch.name }, {
          \ 'working_dir': candidate.source__args.path
          \ })
    call vital#versions#echomsgs(output)
  endfor
endfunction

let s:kind.action_table.push = {
      \ 'description': 'push branch.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.push.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  let output = versions#command('branch:push', { 'branch': candidate.action__branch.name, }, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let s:kind.action_table.merge = {
      \ 'description': 'merge branch.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.merge.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  let output = versions#command('branch:merge', { 'branch': candidate.action__branch.name, 'option': [] }, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let s:kind.action_table.merge_no_ff = {
      \ 'description': 'merge branch with --no-ff.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.merge_no_ff.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  let output = versions#command('branch:merge', { 'branch': candidate.action__branch.name, 'option': ['--no-ff'] }, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let s:kind.action_table.merge_squash = {
      \ 'description': 'merge branch with --squash.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.merge_squash.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  let output = versions#command('branch:merge', { 'branch': candidate.action__branch.name, 'option': ['--squash'] }, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let s:kind.action_table.checkout = {
      \ 'description': 'checkout branch.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.checkout.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  if candidate.action__branch.is_current
    echoerr 'can not checkout current branch.'
  endif
  let output = versions#command('checkout', { 'branch': candidate.action__branch.name, }, {
        \ 'working_dir': candidate.source__args.path
        \ })
  call vital#versions#echomsgs(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


