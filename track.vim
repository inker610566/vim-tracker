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

function! s:BufferOpen()
	" do some initialize
	let b:tracker_is_trigger_marker = 0
	let b:cursor_history_idx = 0
	let b:cursor_prev_pos = getpos('.')
endfunction

function! s:Cursor_move_event()
	if b:tracker_is_trigger_marker == 0
		let [l:zero, l:line, l:col, l:zero] = getpos(".")
		let [l:zero, l:line1, l:col1, l:zero] = b:cursor_prev_pos
		if l:line != l:line1
			for idx in reverse(range(g:tracker_max_history-1))
				call setpos("'".g:tracker_history_marker[idx+1], getpos("'".g:tracker_history_marker[idx]))
			endfor
			call setpos("'".g:tracker_history_marker[0], [0, l:line1, l:col1, 0])
		endif
		let b:cursor_prev_pos = [0, l:line, l:col, 0]
		let b:cursor_history_idx = 0
	else
		let b:tracker_is_trigger_marker = 0
	endif
endfunction

function! s:Marker_goto(markname)
	let b:tracker_is_trigger_marker = 1
	return "'".a:markname
endfunction

function! s:Next_history()
	let l:cur_marker = g:tracker_history_marker[b:cursor_history_idx]
	let b:cursor_history_idx = (b:cursor_history_idx+1) % g:tracker_max_history
	return l:cur_marker
endfunction

function! s:Open_history()
	" get history lines from current buffer
	function! s:to_line(idx)
		return getline(line("'".g:tracker_history_marker[a:idx]))
	endfunction

	let l:history_lines = map(range(len(g:tracker_history_marker)), "(v:val+1) . ':' . s:to_line(v:val)")

	" create buffer
	execute g:tracker_max_history . "new"
	setlocal bufhidden=wipe buftype=nofile nonu fdc=0

	call setline(1, l:history_lines)

	setlocal nomodifiable
	setlocal cursorline
endfunction

" add BufRead,BUfNewFile event
autocmd BufRead,BufNewFile * call <SID>BufferOpen()
" add cursor move event
autocmd CursorMoved * call s:Cursor_move_event()

" hook goto marker
for marker in g:tracker_history_marker
	execute "nnoremap <expr> '".marker.' <SID>Marker_goto("'.marker.'")'
endfor

nnoremap <expr> '' <SID>Marker_goto(<SID>Next_history())

command Trackerlist call <SID>Open_history()
