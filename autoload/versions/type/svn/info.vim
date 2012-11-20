let s:save_cpo = &cpo
set cpo&vim

function! versions#type#svn#info#do(args)
  let format = get(a:args, 'format', g:versions#info.svn)

  let cnt = 0
  let max = len(format)
  let info = ''
  while cnt < max
    if format[cnt] == '%' && cnt + 1 < max
      let part = format[cnt + 1]

      " %%.
      if part == '%'
        let info .= '%'

      " %R : path to repository root.
      elseif part == 'R'
        let info .= versions#get_root_dir(getcwd())

      " %s : VCS name.
      elseif part == 's'
        let info .= 'svn'

      " ignore.
      else
        let info .= '?'
      endif

      let cnt += 1
    else
      let info .= format[cnt]
    endif

    let cnt += 1
  endwhile

  return substitute(vital#versions#trim_cr(info), '\n', '', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

