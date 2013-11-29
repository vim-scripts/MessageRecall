" MessageRecall/MappingsAndCommands.vim: Setup for message buffer and preview.
"
" DEPENDENCIES:
"   - EditSimilar/Next.vim autoload script
"   - ingo/escape/command.vim autoload script
"   - MessageRecall.vim autoload script
"   - MessageRecall/Buffer.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.02.005	09-Aug-2013	Allow to change / disable the defined mappings
"				by using intermediate <Plug>-mappings. This also
"				prevents escaping issues with my buffer-local
"				UniversalIteratorMapping iteration mode.
"				Use ingo#escape#command#mapescape().
"				Trigger User autocmds, e.g. to allow to easily
"				define alternative mappings for <C-p> / <C-n>,
"				as there's no fixed filetype one could use here.
"   1.02.004	05-Aug-2013	Pass range and whenRangeNoMatch options to the
"				<C-p> / <C-n> mappings, too.
"				Mark previewed stored messages with
"				b:MessageRecall_Buffer to be able to recognize
"				them in MessageRecall#Buffer#Replace().
"   1.01.003	12-Jul-2012	The :MessageRecall command in the message buffer
"				needs access to the a:whenRangeNoMatch option.
"   1.00.002	19-Jun-2012	Define :MessageView command in preview buffer,
"				too, as a more discoverable alternative to
"				CTRL-P / CTRL-N navigation.
"				Prune unnecessary a:range argument.
"				Pass in a:targetBufNr to
"				MessageRecall#Buffer#Preview(), now that it is
"				also used from inside the preview window, and do
"				the same to MessageRecall#Buffer#Replace() for
"				consistency.
"   1.00.001	19-Jun-2012	file creation

function! MessageRecall#MappingsAndCommands#PreviewSetup( targetBufNr, filetype )
    let l:messageStoreDirspec = expand('%:p:h')
    execute printf('command! -buffer -bang MessageRecall call MessageRecall#Buffer#PreviewRecall(<q-bang>, %d)', a:targetBufNr)
    execute printf('command! -buffer       -count=1 -nargs=? -complete=customlist,%s MessageView call MessageRecall#Buffer#Preview(1, <count>, <q-args>, %s, %d)', MessageRecall#GetFuncrefs(l:messageStoreDirspec)[1], string(l:messageStoreDirspec), a:targetBufNr)

    let l:command = 'view +' . ingo#escape#command#mapescape(escape(MessageRecall#Buffer#GetPreviewCommands(a:targetBufNr, a:filetype), ' \'))
    execute printf('nnoremap <silent> <buffer> <Plug>(MessageRecallPreviewPrev) :<C-u>call EditSimilar#Next#Open(%s, 0, expand("%%:p"), v:count1, -1, MessageRecall#Glob())<CR>', string(l:command))
    execute printf('nnoremap <silent> <buffer> <Plug>(MessageRecallPreviewNext) :<C-u>call EditSimilar#Next#Open(%s, 0, expand("%%:p"), v:count1,  1, MessageRecall#Glob())<CR>', string(l:command))
    if ! hasmapto('<Plug>(MessageRecallPreviewPrev)', 'n')
	nmap <buffer> <C-p> <Plug>(MessageRecallPreviewPrev)
    endif
    if ! hasmapto('<Plug>(MessageRecallPreviewNext)', 'n')
	nmap <buffer> <C-n> <Plug>(MessageRecallPreviewNext)
    endif

    let b:MessageRecall_Buffer = 1

    if v:version == 703 && has('patch438') || v:version > 703
	silent doautocmd <nomodeline> User MessageRecallPreview
    else
	silent doautocmd              User MessageRecallPreview
    endif
endfunction

function! MessageRecall#MappingsAndCommands#MessageBufferSetup( messageStoreDirspec, range, whenRangeNoMatch, CompleteFuncref )
    let l:targetBufNr = bufnr('')

    execute printf('command! -buffer -bang -count=1 -nargs=? -complete=customlist,%s MessageRecall  call MessageRecall#Buffer#Recall(<bang>0, <count>, <q-args>, %s, %s, %s)', a:CompleteFuncref, string(a:messageStoreDirspec), string(a:range), string(a:whenRangeNoMatch))
    execute printf('command! -buffer       -count=1 -nargs=? -complete=customlist,%s MessageView    call MessageRecall#Buffer#Preview(1, <count>, <q-args>, %s, %d)', a:CompleteFuncref, string(a:messageStoreDirspec), l:targetBufNr)

    execute printf('nnoremap <silent> <buffer> <Plug>(MessageRecallGoPrev) :<C-u>call MessageRecall#Buffer#Replace(1, v:count1, %s, %s, %s, %d)<CR>', string(a:messageStoreDirspec), string(a:range), string(a:whenRangeNoMatch), l:targetBufNr)
    execute printf('nnoremap <silent> <buffer> <Plug>(MessageRecallGoNext) :<C-u>call MessageRecall#Buffer#Replace(0, v:count1, %s, %s, %s, %d)<CR>', string(a:messageStoreDirspec), string(a:range), string(a:whenRangeNoMatch), l:targetBufNr)
    if ! hasmapto('<Plug>(MessageRecallGoPrev)', 'n')
	nmap <buffer> <C-p> <Plug>(MessageRecallGoPrev)
    endif
    if ! hasmapto('<Plug>(MessageRecallGoNext)', 'n')
	nmap <buffer> <C-n> <Plug>(MessageRecallGoNext)
    endif

    if v:version == 703 && has('patch438') || v:version > 703
	silent doautocmd <nomodeline> User MessageRecallBuffer
    else
	silent doautocmd              User MessageRecallBuffer
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
