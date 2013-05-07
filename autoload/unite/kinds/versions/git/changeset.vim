let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#git#changeset#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/git/changeset',
      \ 'default_action': 'diff_prev',
      \ 'action_table': {},
      \ }

let s:kind.action_table.diff = {
      \ 'description': 'display diff.',
      \ 'is_selectable': 1,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.diff.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  call versions#call('unite#kinds#versions#git#changeset#diff',
        \ [candidates],
        \ fnamemodify(candidates[0].source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#git#changeset#diff(candidates)
  for candidate in a:candidates
    let changeset = candidate.action__changeset
    let status = candidate.action__status
    call versions#diff#file_with_string(status.path, {
          \   'name': printf('[REMOTE: %s] %s', candidate.source__args.prev_revision, status.path),
          \   'string': versions#command('show', {
          \     'path': status.path,
          \     'revision': candidate.source__args.prev_revision,
          \   }, {
          \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
          \   })
          \ })
  endfor
endfunction

let s:kind.action_table.diff_prev = {
      \ 'description': 'display previous revision diff.',
      \ 'is_selectable': 1,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.diff_prev.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  call versions#call('unite#kinds#versions#git#changeset#diff_prev',
        \ [candidates],
        \ fnamemodify(candidates[0].source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#git#changeset#diff_prev(candidates)
  for candidate in a:candidates
    let changeset = candidate.action__changeset
    let status = candidate.action__status
    call versions#diff#string_with_string({
          \   'name': printf('[REMOTE: %s] %s', candidate.source__args.revision, status.path),
          \   'string': versions#command('show', {
          \     'path': status.path,
          \     'revision': candidate.source__args.revision,
          \   }, {
          \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
          \   })
          \ }, {
          \   'name': printf('[REMOTE: %s] %s', candidate.source__args.prev_revision, status.path),
          \   'string': versions#command('show', {
          \     'path': status.path,
          \     'revision': candidate.source__args.prev_revision,
          \   }, {
          \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
          \   })
          \ })
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

