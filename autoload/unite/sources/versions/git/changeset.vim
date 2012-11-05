let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#git#changeset#define()
  return [s:source]
endfunction

function! unite#sources#versions#git#changeset#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/git/changeset',
      \ 'description': 'vcs repository changeset.',
      \ 'hooks': {},
      \ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__args = {}
  let a:context.source__args.path = unite#sources#versions#get_path(get(a:args, 0, '%'))
  let a:context.source__args.revision = get(a:args, 1, '')

  if versions#get_type(a:context.source__args.path) != 'git'
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
        \   'working_dir': fnamemodify(versions#get_root_dir(path), ':p:h')
        \ })
  call unite#print_message('[versions/changeset] revision: ' . changeset.revision)
  call unite#print_message('[versions/changeset] author: ' . changeset.author)
  call unite#print_message('[versions/changeset] date: ' . changeset.date)
  call unite#print_message('[versions/changeset] message: ' . changeset.message)
  return map(changeset.statuses, "{
        \   'word': v:val.status . ' | ' . v:val.path,
        \   'action__changeset': changeset,
        \   'action__status': v:val,
        \   'source__args': a:context.source__args,
        \   'kind': 'versions/git/changeset',
        \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


