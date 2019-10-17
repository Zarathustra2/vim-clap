" Author: liuchengxu <xuliuchengxlc@gmail.com>
" Description: List the files.

let s:save_cpo = &cpo
set cpo&vim

let s:files = {}

let s:find_cmd = v:null

if get(g:, 'clap_provider_files_enable_hidden', v:false)
  let s:tools = [
        \ ['fd', '--hidden --type f'],
        \ ['rg', '--hidden --files'],
        \ ['git', 'ls-tree -r --name-only HEAD'],
        \ ['find', '. -type f'],
        \ ]
else
  let s:tools = [
        \ ['fd', '--type f'],
        \ ['rg', '--files'],
        \ ['git', 'ls-tree -r --name-only HEAD'],
        \ ['find', '. -type f'],
        \ ]
endif

let s:find_cmd = v:null

for [exe, opt] in s:tools
  if executable(exe)
    let s:find_cmd = join([exe, opt], ' ')
    break
  endif
endfor

if s:find_cmd is v:null
  let s:find_cmd = ['No usable tools found for the files provider']
endif

let s:files.source = s:find_cmd
let s:files.sink = 'e'

function! s:files.source_async() abort
  let s:lnum = 0
  let g:to_match = {}
  return 'fd --type f | /Users/xlc/src/github.com/liuchengxu/vim-clap-fuzzy-matcher/target/debug/vim-clap-fuzzy-matcher '.g:clap.input.get()
endfunction
" let s:files.source_async = 'fd --type f | /Users/xlc/src/github.com/liuchengxu/vim-clap-fuzzy-matcher/target/debug/vim-clap-fuzzy-matcher '.g:clap.input.get()

let s:ns_id = nvim_create_namespace('clap_matched')

function! s:files.converter(line) abort
  let json_decoded = json_decode(a:line)
  let g:to_match[s:lnum] = json_decoded.indices
  " echom "line: ".string(a:line). ", lnum:".s:lnum
  " for idx in json_decoded.indices
    " echom "idx: ".idx.", line: ".(g:clap.display.line_count() - 1)
    " call nvim_buf_add_highlight(g:clap.display.bufnr, s:ns_id, 'Search', s:lnum, idx, idx+1)
  " endfor
  let s:lnum += 1
  return json_decoded.text
endfunction

let s:files.enable_rooter = v:true

let g:clap#provider#files# = s:files

let &cpo = s:save_cpo
unlet s:save_cpo
