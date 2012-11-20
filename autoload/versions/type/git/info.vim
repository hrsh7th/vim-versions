let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#info#do(args)
  let format = get(a:args, 'format', g:versions#info.git)

  let cnt = 0
  let max = len(format)
  let info = ''
  while cnt < max
    if format[cnt] == '%' && cnt + 1 < max
      let part = format[cnt + 1]

      " %%.
      if part == '%'
        let info .= '%'

      " %b : current branch name.
      elseif part == 'b'
        let info .= vital#versions#system('git symbolic-ref --short HEAD')

      " %r : repository name.
      elseif part == 'r'
        let info .= '' " TODO

      " %R : path to repository root.
      elseif part == 'R'
        let info .= versions#get_root_dir(getcwd())

      " %s : VCS name.
      elseif part == 's'
        let info .= 'git'

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

