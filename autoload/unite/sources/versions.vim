let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#versions#define()
  return [s:source] + unite#sources#versions#get_sources('versions', 1)
endfunction

let s:source = {
      \ 'name': 'versions',
      \ 'description': 'nominates vcs sources.'
      \ }

function! s:source.gather_candidates(args, context)
  let path = get(a:args, 0, versions#get_working_dir())

  if versions#get_type(path) == ''
    call unite#print_source_message('vcs not detected.', s:source.name)
    return []
  endif

  let sources = unite#sources#versions#get_sources('versions')
  let sources += unite#sources#versions#get_sources('versions/' .
        \ versions#get_type(path))

  call unite#print_source_message('type: ' . versions#get_type(path), s:source.name)

  return map(filter(sources, 'v:val.is_listed'), "{
        \ 'word': vital#versions#trim_left(v:val.name, printf('versions/%s/', versions#get_type(path))),
        \ 'action__source_name': v:val.name,
        \ 'action__source_args': a:args,
        \ 'kind': 'source',
        \ }")
endfunction

function! unite#sources#versions#get_sources(target, ...)
  let is_rec = get(a:000, 0, 0)
  let target = 'autoload/unite/sources/' . a:target
  let paths = []

  " target path loop.
  for path in split(globpath(&runtimepath, target . (is_rec ? '/**/*.vim' : '/*.vim')))
    let path = vital#versions#trim_right(vital#versions#substitute_path_separator(path), '/')

    " rtp path loop.
    for rtp in split(&runtimepath, ',')
      let rtp = vital#versions#trim_right(vital#versions#substitute_path_separator(rtp), '/') . '/' . target

      if path =~# rtp
        let l1 = strlen(path)
        let l2 = strlen(rtp)
        call add(paths, strpart(path, l2 + 1, l1 - l2 - strlen('.vim') - 1))
      endif
    endfor
  endfor

  " collect sources.
  let sources = []
  for source in map(paths, "{'unite#sources#' . substitute(a:target . '/' . v:val, '/', '#', 'g') . '#define'}()")
    let sources += source
  endfor
  return sources
endfunction

function! unite#sources#versions#get_path(path)
  if a:path == '!'
    return versions#get_root_dir(versions#get_working_dir())
  endif

  if a:path == '%'
    return versions#get_working_dir()
  endif

  return fnamemodify(a:path, ':p')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

