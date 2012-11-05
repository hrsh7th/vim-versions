scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ 'X       web/test/test1',
      \ '    X   web/test/test2',
      \ '?       web/test/test3',
      \ '!     C web/test/test4',
      \ '      >   local missing, incoming edit upon update'
      \ ]

Context Source.run()

  It 'parse output'
    let statuses = versions#type#svn#status#parse(join(output, "\n"))
    Should len(statuses) == 4
    Should statuses[0].status == 'X      '
    Should statuses[1].status == '    X  '
    Should statuses[2].status == '?      '
    Should statuses[3].status == '!     C'
  End

  It 'checking status line'
    Should versions#type#svn#status#is_status_line(output[0])
    Should !versions#type#svn#status#is_status_line(output[4])
  End

  It 'parse one line'
    let s = versions#type#svn#status#create_status(output[0])
    Should s.line == 'X       web/test/test1'
    Should s.status == 'X      '
    Should s.path == 'web/test/test1'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

