scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let output = [
      \ '38c67f7546190a7459fe8f9e94ce9b30130494e0	620293d83321321bc12c235da1be51dc2451a8d7	hrsh7th	hrsh7th@gmail.com	2012-10-30 05:08:32 +0900	remove get_root_dir prefix .',
      \ 'M	autoload/versions.vim',
      \ 'M	autoload/vital/versions.vim',
      \ ]

Context Source.run()

  It 'parse output'
    let changeset = versions#type#git#changeset#parse(join(output, "\n"))
    Should !empty(changeset)
    Should len(changeset.statuses) == 2
    Should changeset.statuses[0].line == 'M	autoload/versions.vim'
    Should changeset.statuses[0].path == 'autoload/versions.vim'
    Should changeset.statuses[0].status == 'M'
    Should changeset.statuses[1].line == 'M	autoload/vital/versions.vim'
    Should changeset.statuses[1].path == 'autoload/vital/versions.vim'
    Should changeset.statuses[1].status == 'M'
  End

End

Fin

let &cpo = s:save_cpo
unlet s:save_cpo

