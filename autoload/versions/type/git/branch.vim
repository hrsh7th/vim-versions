let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#branch#do(args)
  let output = vital#versions#system('git branch')
  return map(split(output, "\n"), 'versions#type#git#branch#convert(v:val)')
endfunction

function! versions#type#git#branch#convert(line)
  let mark = strpart(a:line, 0, 2)
  let name = strpart(a:line, 2)
  return {
        \ 'name': name,
        \ 'is_current': mark =~# '\*',
        \ }
endfunction

echomsg PP(versions#type#git#branch#do({}))

let &cpo = s:save_cpo
unlet s:save_cpo

