let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#svn#status#define()
  return [s:source]
endfunction

function! unite#sources#versions#svn#status#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/svn/status',
      \ 'description': 'vcs repository status.',
      \ 'hooks': {},
      \ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__args = {}
  let a:context.source__args.path = unite#sources#versions#get_path(get(a:args, 0, '%'))

  if versions#get_type(a:context.source__args.path) != 'svn'
    throw '[versions] vcs not detected.'
  endif
endfunction

function! s:source.gather_candidates(args, context)
  let path = a:context.source__args.path

  call unite#print_source_message('type: ' . versions#get_type(path), s:source.name)
  call unite#print_source_message('path: ' . path, s:source.name)

  let statuses = versions#command('status', { 'path': path }, {
        \ 'working_dir': fnamemodify(path, ':p:h')
        \ })
  let statuslen = max(map(deepcopy(statuses), 'strlen(v:val.status)'))
  return map(statuses, "{
        \   'word': vital#versions#padding(v:val.status, statuslen) . ' | ' . v:val.path,
        \   'action__status': v:val,
        \   'source__args': a:context.source__args,
        \   'kind': 'versions/svn/status',
        \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

