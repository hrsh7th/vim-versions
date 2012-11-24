let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#git#branch#define()
  return [s:source]
endfunction

function! unite#sources#versions#git#branch#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/git/branch',
      \ 'description': 'vcs repository branches.',
      \ 'hooks': {},
      \ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__args = {}
  let a:context.source__args.path = versions#get_root_dir(unite#sources#versions#get_path(get(a:args, 0, '%')))

  if versions#get_type(a:context.source__args.path) != 'git'
    throw '[versions] vcs not detected.'
  endif
endfunction

function! s:source.gather_candidates(args, context)
  let path = a:context.source__args.path

  call unite#print_message('[versions/branch] type: ' . versions#get_type(path))

  " TODO: refactor.
  " versions#command('branch:list', {}, {...})
  let branches = versions#command('branch', { 'list': 1 }, {
        \   'working_dir': fnamemodify(path, ':p:h')
        \ })
  return map(branches, "{
        \   'word': (v:val.is_current ? ' * ' : '   ') . ' | ' . v:val.name,
        \   'action__branch': v:val,
        \   'source__args': a:context.source__args,
        \   'kind': 'versions/git/branch',
        \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo



