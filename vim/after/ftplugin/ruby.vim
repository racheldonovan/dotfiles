" functions
function! SpecDescribed()
  let curline = line(".")
  let curcol  = col(".")
  let line = search("describe", "bW")
  if line > 0
    let line = getline(line)
    let subject = substitute(matchstr(line, "describe [^, ]*"), "^describe ", "", "")
    call cursor(curline, curcol)
    return subject
  else
    return 'subject'
  endif
endfunction

function! SpecSubject()
  return rails#underscore(SpecDescribed())
endfunction

function! SpecDescribedType()
  let curline = line(".")
  let curcol  = col(".")
  let line = search("describe", "bW")
  call cursor(curline, curcol)
  if line > 0
    let line = getline(line)
    return substitute(matchstr(line, "describe [^, ]*"), "^describe ", "", "")
  else
    return rails#camelize(substitute(expand("%:t:r"), "_spec$", "", ""))
  endif
endfunction

function! InSpecBlock()
  if match(getline("."), "^\\s") != -1
    return 1
  else
    return 0
  endif
endfunction

function! DefaultSpecDescribe(suffix)
  if InSpecBlock()
    return "describe"
  else
    return "describe " . SpecDescribedType() . a:suffix
  endif
endfunction

function! IterVar()
  let line = getline('.')
  let col = col('.')
  let collection = line[0 : col]
  " remove .each/.map
  let collection = substitute(collection,"\\.[^.]*$","","")
  " remove lead up
  let collection = substitute(collection, "^.*\\W", "", "")
  " singularize
  return rails#singularize(collection)
endfunction

function! RubyTrim(string)
  return substitute(a:string, "^\\s\\+\\|\\s\\+$", "", "g")
endfunction

function! RubySplitOneliner()
  let lineno = line(".")
  let line = getline(lineno)
  let leftBrace = stridx(line, "{")
  let rightBrace = strridx(line, "}")
  let indent = matchstr(line, "^\\s\\+")
  let open = strpart(line, len(indent), leftBrace - len(indent))
  let content = strpart(line, leftBrace + 1, rightBrace - leftBrace - 1)
  call setline(lineno, indent . RubyTrim(open) . " do")
  call append(lineno, [indent . "  " . RubyTrim(content), indent . "end"])
endfunction

function! RubyJoinOneliner()
  let pos = getpos(".")
  call cursor(pos[1] + 1, 0)
  let lineno = search("do$", "bW")
  let line = getline(lineno)
  let indent = matchstr(line, "^\\s\\+")
  let open = RubyTrim(substitute(line, "do\\s*$", "", ""))
  let contents = RubyTrim(getline(lineno + 1))
  call setline(lineno, indent . open . " { " . contents . " }")
  exec (lineno + 1) . "," . (lineno + 2) . "d"
  let pos = getpos(".")
  call cursor(pos[1] - 1, 0)
endfunction

function! RubyIsOneliner()
  return match(getline(line(".")), "^\\s\\+[a-zA-Z0-9_.]\\+\\s\\+{")
endfunction

function! RubyToggleOneliner()
  if RubyIsOneliner() == -1
    call RubyJoinOneliner()
  else
    call RubySplitOneliner()
  endif
endfunction

nmap <buffer> <Bar> :call RubyToggleOneliner()<CR>

" general ruby snippets
Snippet each each do |``IterVar()``|<CR><{}><CR>end
Snippet map map do |``IterVar()``|<CR><{}><CR>end
Snippet eachl each { |``IterVar()``| <{}> }
Snippet mapl map { |``IterVar()``| <{}> }
Snippet @ @<{attribute}> = <{attribute}><{}>

" active record associations
Snippet bt belongs_to :<{}>
Snippet ho has_one :<{}>
Snippet hm has_many :<{}>
Snippet habtm has_and_belongs_to_many :<{}>
Snippet hmt has_many :<{association}>, :through => <{}>

" active record validations
Snippet vpo validates_presence_of :<{}>
Snippet vuo validates_uniqueness_of :<{}>

" shoulda validation matchers
Snippet shvpo it { should validate_presence_of(:<{}>) }
Snippet shal should_allow_values_for :<{attribute}>, <{}>
Snippet should_ensure_length_at_least should_ensure_length_at_least :<{attribute}>, <{length}><CR><{}>
Snippet should_ensure_length_in_range  should_ensure_length_in_range :<{attribute}>, <{range}><CR><{}>
Snippet should_ensure_length_is should_ensure_length_is :<{attribute}>, <{length}><CR><{}>
Snippet should_ensure_value_in_range should_ensure_value_in_range :<{attribute}>, <{range}><CR><{}>
Snippet shnal should_not_allow_values_for :<{attribute}>, <{}>
Snippet shalnum should_only_allow_numeric_values_for :<{}>
Snippet shprot should_protect_attributes :<{}>
Snippet shreqacc should_require_acceptance_of :<{}>
Snippet shreq should_require_attributes :<{}>
Snippet shvuo it { should validate_uniqueness_of(:<{}>) }

" Factory girl
Snippet c create(:<{}>)
Snippet b build(:<{}>)
Snippet bs build_stubbed(:<{}>)

" shoulda association macros
Snippet shbt it { should belong_to(:<{}>) }
Snippet shhabtm should_have_and_belong_to_many :<{association}><CR><{}>
Snippet shhm it { should have_many(:<{}>) }
Snippet shho should_have_one :<{association}><CR><{}>

" shoulda controller macros
Snippet shass should assign_to(:<{var}>).with(<{}>)
Snippet shnfl should_not_set_the_flash<{}>
Snippet shred should redirect_to(<{}>_url)
Snippet shrend should render_template(:<{}>)
Snippet shlay should_render_without_layout :<{}>
Snippet shres should respond_with(:<{}>)
Snippet shroute should route(:<{method}>, "<{path}>").to(:action => :<{}>)
Snippet shfl should set_the_flash.to(/<{}>/i)

"rspec
Snippet desc ``DefaultSpecDescribe(",")`` '<{description}>' do<CR><{}><CR>end
Snippet descn ``DefaultSpecDescribe("")`` do<CR><{}><CR>end
Snippet bef before do<CR><{}><CR>end
Snippet let let(:<{actor}>) { <{}> }
Snippet let! let!(:<{actor}>) { <{}> }
Snippet sub subject { <{}> }
Snippet it it '<{description}>' do<CR><{}><CR>end
Snippet itsh it '<{description}>' do<CR>``SpecSubject()``.should <{}><CR>end
Snippet itshbe it '<{description}>' do<CR>``SpecSubject()``.should be_<{}><CR>end
Snippet atsh it '<{description}>' do<CR>``SpecSubject()``.<{attr}>.should <{}><CR>end
Snippet atshbe it '<{description}>' do<CR>``SpecSubject()``.<{attr}>.should be_<{}><CR>end
Snippet sheq should == <{}>
Snippet cont context "<{description}>" do<CR><{}><CR>end

"" bourne
Snippet shrec should have_received(:<{}>)

" controller responses
Snippet renda render :action => '<{}>'
Snippet rendn render :nothing => true<{}>
Snippet rendf render :file => '<{}>'
Snippet rendt render :template => '<{}>'
Snippet rendl render :layout => '<{}>'
Snippet red redirect_to <{}>_url
Snippet fl flash[:<{key}>] = "<{}>"

" Cucumber step definitions
Snippet Given Given /^<{}>$/ do<CR>end
Snippet When When /^<{}>$/ do<CR>end
Snippet Then Then /^<{}>$/ do<CR>end
iabbr "( "([^"]+)"

" Search shortcuts
nmap m/ /^\s*\(def \\| def self\.\)

" Start a new method in a Ruby class
" <Leader>nm
nmap <Leader>nm gg/^\s\+\(private\\|protected\)\\|^end<Enter>O

" Surround a variable in a string with inspect
nmap <buffer> yiv ysiw}i#<Esc>f}i.inspect<Esc>

nmap <buffer> yh lF:xEpf=dW

