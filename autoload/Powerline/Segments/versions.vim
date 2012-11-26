let s:save_cpo = &cpo
set cpo&vim

let g:Powerline#Segments#versions#segments = Pl#Segment#Init(['versions',
      \ (exists('g:loaded_versions') && g:loaded_versions == 1),
      \
      \ Pl#Segment#Create('branch', '%{Powerline#Functions#versions#GetBranch("$BRANCH")}')
      \ ])

let &cpo = s:save_cpo
unlet s:save_cpo

