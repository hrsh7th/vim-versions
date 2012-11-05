scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ '------------------------------------------------------------------------',
      \ 'r5 | hrsh7th | 2012-10-06 04:44:58 +0900 (土, 06 10 2012) | 3 lines',
      \ '',
      \ 'test commit1.',
      \ 'test commit2.',
      \ '------------------------------------------------------------------------',
      \ 'r6 | hrsh7th | 2012-10-06 04:44:58 +0900 (土, 06 10 2012) | 3 lines',
      \ '',
      \ 'test commit3.',
      \ '',
      \ 'test commit4.',
      \ '------------------------------------------------------------------------'
      \ ]

Context Source.run()

  It 'parse output'
    let logs = versions#type#svn#log#parse(join(output, "\n"))

    Should len(logs) == 2

    let message = join(['test commit1.', 'test commit2.'], "\n")
    Should logs[0].revision == '5'
    Should logs[0].message == message
    Should logs[0].author == 'hrsh7th'
    Should logs[0].date == '2012-10-06 04:44:58'
    Should logs[0].prev_revision == '6'

    let message = join(['test commit3.', '', 'test commit4.'], "\n")
    Should logs[1].revision == '6'
    Should logs[1].message == message
    Should logs[1].author == 'hrsh7th'
    Should logs[1].date == '2012-10-06 04:44:58'
    Should logs[1].prev_revision == ''
  End

  It 'parse one block'
    let l = versions#type#svn#log#create_log(join(output[1:4], "\n"))
    let message = join(['test commit1.', 'test commit2.'], "\n")
    Should l.revision == '5'
    Should l.message == message
    Should l.author == 'hrsh7th'
    Should l.date == '2012-10-06 04:44:58'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

