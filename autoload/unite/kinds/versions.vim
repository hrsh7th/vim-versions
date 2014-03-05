let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#define()
  return unite#kinds#versions#get_kinds('versions', 1)
endfunction

function! unite#kinds#versions#get_kinds(target, ...)
  let is_rec = get(a:000, 0, 0)
  let target = 'autoload/unite/kinds/' . a:target
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
  for source in map(paths, "{'unite#kinds#' . substitute(a:target . '/' . v:val, '/', '#', 'g') . '#define'}()")
    let sources += source
  endfor
  return sources
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

