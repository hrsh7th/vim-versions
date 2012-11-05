scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ '------------------------------------------------------------------------',
      \ 'r8 | hrsh7th | 2012-10-06 04:52:54 +0900 (土, 06 10 2012) | 2 lines',
      \ 'Changed paths:',
      \ '   M /README.mkd',
      \ '',
      \ 'test commit.',
      \ '',
      \ '------------------------------------------------------------------------',
      \ 'r7 | hrsh7th | 2012-10-06 04:51:51 +0900 (土, 06 10 2012) | 2 lines',
      \ 'Changed paths:',
      \ '   M /README.mkd',
      \ '',
      \ 'Its a great change.',
      \ ]

Context Source.run()

  It 'parse output'
    let result = versions#type#svn#changeset#parse(join(output, "\n"))
    let message = join(['test commit.', ''], "\n")
    Should !empty(result)
    Should len(result.statuses) == 1
    Should result.message == message
    Should result.statuses[0].status == '   M'
    Should result.statuses[0].path == '/README.mkd'
    Should result.statuses[0].line == '   M /README.mkd'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

