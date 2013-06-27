"============================================================================
"File:        dartanalyzer.vim
"Description: Dart syntax checker - using dartanalyzer
"Maintainer:  Maksim Ryzhikov <rv.maksim at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if exists("g:loaded_syntastic_dart_dartanalyzer_checker")
    finish
endif
let g:loaded_syntastic_dart_dartanalyzer_checker=1

if !exists("g:syntastic_dartanalyzer_conf")
    let g:syntastic_dartanalyzer_conf = ''
endif

function! SyntaxCheckers_dart_dartanalyzer_IsAvailable()
    return executable("dartanalyzer")
endfunction

function! SyntaxCheckers_dart_dartanalyzer_GetHighlightRegex(error)
    let lcol = a:error['col'] - 1
    let rcol = a:error['nr'] + lcol + 1

    return '\%>'.lcol.'c\%<'.rcol.'c'
endfunction

function! SyntaxCheckers_dart_dartanalyzer_GetLocList()
    let args = !empty(g:syntastic_dartanalyzer_conf) ? ' ' . g:syntastic_dartanalyzer_conf : ''
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'dartanalyzer',
        \ 'args': '--machine',
        \ 'post_args': args,
        \ 'filetype': 'dart',
        \ 'subchecker': 'dartanalyzer' })

    " Machine readable format looks like:
    " SEVERITY|TYPE|ERROR_CODE|file:FILENAME|LINE_NUMBER|COLUMN|LENGTH|MESSAGE
    " SEVERITY: (WARNING|ERROR)
    " TYPE: (RESOLVER|STATIC_TYPE|...)
    " ERROR_CODE: (NO_SUCH_TYPE|...)
    " FILENAME: String
    " LINE_NUMBER: int
    " COLUMN: int
    " LENGHT: int
    " MESSAGE: String

    " We use %n to grab the error length to be able to access it in the matcher.
    let commonformat = '|%.%#|%.%#|%f|%l|%c|%n|%m'

    " TODO(amouravski): simply take everything after ERROR|WARNING as a message
    " and then parse it by hand later.
    let errorformat = '%EERROR'.l:commonformat.','.
        \'%WWARNING'.l:commonformat

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'dart',
    \ 'name': 'dartanalyzer'})
