"
"	used like vim marker command, "# to jump to history(# is a number ranged from 1-9)
"	1 is the lastest history
"	reserve "0 for jump to next history ( if your previously use jump to 1,then jump to 2
"

"if exists('g:loaded_tracker')
if 0
	finish
endif

" default configuration
let s:default_tracker_max_history = 9

" check user defined configuration
"if !exists('g:tracker_max_history')
if 1
	let g:tracker_max_history = s:default_tracker_max_history
endif

let s:cursor_history_list = repeat([0], 9)
let s:cursor_history_idx = 0

function! Cursor_move_event()
	echo getpos('.')
endfunction

autocmd CursorMoved * call <SID>Cursor_move_event()
