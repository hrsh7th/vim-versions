let g:Powerline#Segments#versions#segments = Pl#Segment#Init(['versions',
	\ (exists('g:loaded_versions') && g:loaded_versions == 1),
	\
	\ Pl#Segment#Create('branch', '%{Powerline#Functions#versions#GetBranch("$BRANCH")}')
\ ])

