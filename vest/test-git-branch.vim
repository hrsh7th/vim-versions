scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ '* implement-branch',
      \ '  master',
      \ ]

Context Source.run()

  It 'parse output'
    let branches = map(output, 'versions#type#git#branch#convert(v:val)')
    Should branches[0].name == 'implement-branch'
    Should branches[0].is_current
    Should branches[1].name == 'master'
    Should !branches[1].is_current
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo


