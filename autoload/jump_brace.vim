"=============================================================================
" FILE: jump_brace.vim
" AUTHOR: Yoshihiro Ito <yo.i.jewelry.bab@gmail.com@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:open_brace  = '({['
let s:close_brace = ')}]'

function! jump_brace#jump_brace() " {{{

  let current_char = getline('.')[col('.') - 1]

  if strlen(current_char) > 0
    if stridx(s:open_brace . s:close_brace, current_char) != -1
      normal! %
      return
    endif
  endif

  if has('lua')
    call s:jump_brace_lua()
  else
    call s:jump_brace_vim()
  endif
endfunction
" }}}

function! s:jump_brace_lua() " {{{

  let pos = [0, 0, 0, 0]

lua << EOF
  local pos    = vim.eval('pos')
  local window = vim.window()
  local buffer = window.buffer

  local open_brace  = vim.eval('s:open_brace')
  local close_brace = vim.eval('s:close_brace')

  local depth = 0

  local current_col  = window.col
  local current_lnum = window.line
  local current_line = buffer[current_lnum]

  while ((current_col == 1) and (current_lnum == 1)) == false do
    local current_char = string.sub(current_line, current_col, current_col)

    if #current_char > 0 then
      if string.find(open_brace, current_char, 1, true) ~= nil then
        if depth == 0 then
          break
        else
          depth = depth + 1
        end
      elseif string.find(close_brace, current_char, 1, true) ~= nil then
        depth = depth - 1
      end
    end

    current_col = current_col - 1
    if current_col == 0 then
      current_lnum = current_lnum - 1
      current_line = buffer[current_lnum]
      current_col  = #current_line + 1
    end
  end

  pos[1] = current_lnum
  pos[2] = current_col
EOF

  let pos[1] = float2nr(pos[1])
  let pos[2] = float2nr(pos[2])

  call setpos('.', pos)
endfunction
" }}}

function! s:jump_brace_vim() " {{{

  let depth = 0

  let current_col  = col('.')
  let current_lnum = line('.')
  let current_line = getline(current_lnum)

  while !((current_col == 1) && (current_lnum == 1))
    let current_char = current_line[current_col - 1]

    if strlen(current_char) > 0
      if stridx(s:open_brace, current_char) != -1
        if depth == 0
          break
        else
          let depth += 1
        endif

      elseif stridx(s:close_brace, current_char) != -1
        let depth -= 1
      endif
    endif

    let current_col -= 1
    if current_col == 0
      let current_lnum -= 1
      let current_line = getline(current_lnum)
      let current_col  = strlen(current_line) + 1
    endif
  endwhile

  let pos = getpos('.')
  let pos[1] = current_lnum
  let pos[2] = current_col
  let pos[3] = 0

  call setpos('.', pos)
endfunction
" }}}

" vim: set ts=2 sw=2 sts=2 et :
