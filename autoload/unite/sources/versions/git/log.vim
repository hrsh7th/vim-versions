let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#git#log#define()
  return [s:source]
endfunction

function! unite#sources#versions#git#log#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/git/log',
      \ 'description': 'vcs repository log.',
      \ 'hooks': {},
      \ }

function! s:source.hooks.on_init(args, context)
  let a:context.source__args = {}
  let a:context.source__args.path = unite#sources#versions#get_path(get(a:args, 0, '%'))
  let a:context.source__args.limit = get(a:args, 1, '')

  if versions#get_type(a:context.source__args.path) != 'git'
    throw '[versions] vcs not detected.'
  endif
endfunction

function! s:source.gather_candidates(args, context)
  let path = a:context.source__args.path
  let limit = a:context.source__args.limit

  call unite#print_message('[versions/log] type: ' . versions#get_type(path))
  call unite#print_message('[versions/log] path: ' . path)

  let logs = versions#command('log', {
        \   'path': path,
        \   'limit': limit
        \ }, {
        \   'working_dir': fnamemodify(path, ':p:h')
        \ })
  let revisionlen = max(map(deepcopy(logs), 'strlen(v:val.revision)'))
  let authorlen = max(map(deepcopy(logs), 'strlen(v:val.author)'))
  let datelen = max(map(deepcopy(logs), 'strlen(v:val.date)'))
  return map(logs, "{
        \   'word': 
        \      vital#versions#padding(v:val.revision, revisionlen) . ' | ' .
        \      vital#versions#padding(v:val.author, authorlen) . ' | ' .
        \      vital#versions#padding(v:val.date, datelen) . ' | ' .
        \      v:val.message,
        \   'action__log': v:val,
        \   'source__args': a:context.source__args,
        \   'kind': 'versions/git/log',
        \ }")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

