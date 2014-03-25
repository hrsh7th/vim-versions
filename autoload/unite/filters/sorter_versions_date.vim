let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#sorter_versions_date#define() "{{{
  return s:sorter
endfunction"}}}

let s:sorter = {
      \ 'name' : 'sorter_versions_date',
      \ 'description' : 'date sorter for vim-versions',
      \}

function! s:sorter.filter(candidates, context) "{{{
  return reverse(unite#util#sort_by(a:candidates, 'v:val.action__log.date'))
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
 
