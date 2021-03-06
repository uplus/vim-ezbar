" GUARD:
if expand("%:p") ==# expand("<sfile>:p")
  unlet! g:loaded_ezbar
endif
if exists('g:loaded_ezbar')
  finish
endif

let g:loaded_ezbar = 1
let s:old_cpo = &cpo
set cpo&vim

" Main:
let s:options = {
      \ 'g:ezbar':       {},
      \ 'g:ezbar_enable': 1,
      \ 'g:ezbar_enable_default_config': 1,
      \ }

function! s:set_options(options) "{{{
  for [varname, value] in items(a:options)
    if !exists(varname)
      let {varname} = value
    endif
    unlet value
  endfor
endfunction

function! s:startup() "{{{1
  call s:set_options(s:options)
  if !g:ezbar_enable
    return
  endif
  call ezbar#enable()
endfunction
"}}}

call s:startup()

" Command:
command!
      \ EzbarDisable call ezbar#disable()

command!
      \ EzbarEnable  call ezbar#enable()

command! -range
      \ EzbarColorCheck :<line1>,<line2>call ezbar#color#check()

command! -nargs=1 -complete=highlight
      \ EzbarColorCapture call ezbar#color#capture(<f-args>)

command! -nargs=? -complete=customlist,ezbar#theme#list
      \ EzbarTheme :call ezbar#load_theme(<f-args>)

" Finish:
let &cpo = s:old_cpo
" vim: foldmethod=marker
