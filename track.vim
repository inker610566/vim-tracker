"
"	used like vim marker command, '# to jump to history,
"	# is a list of marker defined in g:tracker_history_marker
"	the 1st maker is the lastest history, then 2nd, 3rd ...
"	reserve '' for jump to next history i.e. if your previously use jump to 1,then jump to 2
"

if exists('g:loaded_tracker')
	finish
endif
let g:loaded_tracker = 1

" check user defined configuration
if !exists('g:tracker_history_marker')
	"default configuration
	let g:tracker_history_marker = ['q','w','e','r','t','y','u','i','o']
endif

let g:tracker_max_history = len(g:tracker_history_marker)
let g:tracker_is_trigger_marker = 0

let s:cursor_history_idx = 0
let s:cursor_prev_pos = getpos('.')

function! s:Cursor_move_event()
	if g:tracker_is_trigger_marker == 0
		let [l:zero, l:line, l:col, l:zero] = getpos(".")
		let [l:zero, l:line1, l:col1, l:zero] = s:cursor_prev_pos
		if l:line != l:line1
			for idx in reverse(range(g:tracker_max_history-1))
				call setpos("'".g:tracker_history_marker[idx+1], getpos("'".g:tracker_history_marker[idx]))
			endfor
			call setpos("'".g:tracker_history_marker[0], [0, l:line1, l:col1, 0])
		endif
		let s:cursor_prev_pos = [0, l:line, l:col, 0]
		let s:cursor_history_idx = 0
	else
		let g:tracker_is_trigger_marker = 0
	endif
endfunction

function! s:Marker_goto(markname)
	let g:tracker_is_trigger_marker = 1
	return "'".a:markname
endfunction

function! s:Next_history()
	let l:cur_marker = g:tracker_history_marker[s:cursor_history_idx]
	let s:cursor_history_idx = (s:cursor_history_idx+1) % g:tracker_max_history
	return l:cur_marker
endfunction

" add cursor move event
autocmd CursorMoved * call s:Cursor_move_event()

" hook goto marker
for marker in g:tracker_history_marker
	execute "nnoremap <expr> '".marker.' <SID>Marker_goto("'.marker.'")'
endfor

nnoremap <expr> '' <SID>Marker_goto(<SID>Next_history())
