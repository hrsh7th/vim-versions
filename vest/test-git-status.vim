scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ 'M  web/test/test1',
      \ 'UU web/test/test2',
      \ '?? web/test/test3',
      \ ' D web/test/test4',
      \ 'TEST TEST'
      \ ]

Context Source.run()

  It 'parse output'
    let statuses = versions#type#git#status#parse(join(output, "\n"))
    Should len(statuses) == 4
    Should statuses[0].status == 'M '
    Should statuses[1].status == 'UU'
    Should statuses[2].status == '??'
    Should statuses[3].status == ' D'
  End

  It 'checking status line'
    Should versions#type#git#status#is_status_line(output[0])
    Should !versions#type#git#status#is_status_line(output[4])
  End

  It 'parse one line'
    let s = versions#type#git#status#create_status(output[0])
    Should s.line == 'M  web/test/test1'
    Should s.status == 'M '
    Should s.path == 'web/test/test1'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

