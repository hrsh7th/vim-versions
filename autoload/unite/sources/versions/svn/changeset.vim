let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#svn#changeset#define()
  return [s:source]
endfunction

function! unite#sources#versions#svn#changeset#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/svn/changeset',
      \ 'description': 'vcs repository changeset.',
      \ 'hooks': {},
      \ 'is_listed': 0,
      \ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__args = {}
  let a:context.source__args.path = versions#get_root_dir(unite#sources#versions#get_path(get(a:args, 0, '%')))
  let a:context.source__args.revision = get(a:args, 1, '')

  if versions#get_type(a:context.source__args.path) != 'svn'
    throw '[versions] vcs not detected.'
  endif
endfunction

function! s:source.gather_candidates(args, context)
  let path = a:context.source__args.path
  let revision = a:context.source__args.revision

  call unite#print_message('[versions/changeset] type: ' . versions#get_type(path))
  call unite#print_message('[versions/changeset] path: ' . path)

  let changeset = versions#command('changeset', {
        \   'revision': revision
        \ }, {
        \   'working_dir': fnamemodify(path, ':p:h')
        \ })
  call unite#print_message('[versions/changeset] revision: ' . changeset.revision)
  call unite#print_message('[versions/changeset] author: ' . changeset.author)
  call unite#print_message('[versions/changeset] date: ' . changeset.date)
  call unite#print_message('[versions/changeset] message: ' . changeset.message)
  let statuslen = max(map(deepcopy(changeset.statuses), 'strlen(v:val.status)'))
  return map(changeset.statuses, "{
        \   'word': vital#versions#padding(v:val.status, statuslen) . ' | ' . v:val.path,
        \   'action__changeset': changeset,
        \   'action__status': v:val,
        \   'source__args': a:context.source__args,
        \   'kind': 'versions/svn/changeset',
        \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


