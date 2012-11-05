scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ 'd5558fde37c50a2976a6253bb7eb9907e2603b89	09717b84fd1f756b2c2e58eb5e2298f14fc71a03	hrsh7th	hrsh7th@gmail.com	2012-10-13 03:43:22 +0900	add svn log command and tests.',
      \ '09717b84fd1f756b2c2e58eb5e2298f14fc71a03	2df4a8083588853283f30186210c54d4d772cbb8	hrsh7th	hrsh7th@gmail.com	2012-10-13 01:23:07 +0900	added status command and tests.',
      \ ]

Context Source.run()

  It 'parse output'
    let logs = versions#type#git#log#parse(join(output, "\n"))
    Should len(logs) == 2
    Should logs[0].revision == 'd5558fde37c50a2976a6253bb7eb9907e2603b89'
    Should logs[0].prev_revision == '09717b84fd1f756b2c2e58eb5e2298f14fc71a03'
    Should logs[0].author == 'hrsh7th'
    Should logs[0].date == '2012-10-13 03:43:22'
    Should logs[0].message == 'add svn log command and tests.'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

