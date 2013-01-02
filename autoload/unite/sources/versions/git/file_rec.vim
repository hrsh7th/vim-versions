let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#git#file_rec#define()
  return [s:source]
endfunction

function! unite#sources#versions#git#file_rec#check(type, args)
  try
    return versions#get_type(unite#sources#versions#get_path(get(a:args, 0, '%'))) == a:type
  catch
    return 0
  endtry
endfunction

let s:source = {
      \ 'name': 'versions/git/file_rec',
      \ 'description': 'vcs repository files.',
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

  return map(unite#get_candidates([['file_rec', path]]), 's:change_kind(v:val)')
endfunction

function! s:change_kind(candidate)
  let candidate = a:candidate
  let candidate.kind = ['versions/git/status', 'file']
  return candidate
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo



