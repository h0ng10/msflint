msflint
=======

A lint tool for the metasploit framework.

msflint is a static code anlaysis tool to identify potential issues in metasploit modules. msflint is like an advanced
version of "msftity.rb", but uses abstract source trees (AST) to parse the code. This allows much better code coverage
and the creation of complex quality checks.

It is like msftidy.rb on steroids. For example it is possible to easily identify method parameters that are not used
or empty rescue bodies.

The goal of the tool is to automate as much quality checks as possible and allow contributors to write better modules
that can be reviewed faster by the metasploit team, so that pull requests can be merged faster....and to get me a 
mail address like h0ng10@metasploit.com :-)


Currently the following checks are included/working:

- bad_indent - Check for bad indentions (like msftidy)
- empty_rescue_body - Check if the rescue section contains no code
- file_open_binary - Check to ensure that a file is opened in binary mode
- for_loop_check - Check for for loops (should be avoided in ruby code)
- function_basics_check - Check for the number of method parameters (like msftidy)
- global_variable_check - Check for global variables, according to the wiki a common coding mistake  
- line_length_check - Check for code line length (like msftidy)
- load_usage_check - Check if "load" is used instead of "require" (like msftidy)
- name_check - Check for bad variable names like "thisIsMyVariable" 
- ranking_check - Check that the ranking exists and a valid rank is used (like msftidy)
- request_cgi_check - Check if request_cgi uses vars_post and vars_get
- unused_parameter_check - Check for parameters that are not called/used
- update_info_check - Various checks (twitter handles, CVE-entries etc., like msftidy)

I will implement additional/outstanding checks during the week:
- register_options_check - Check for verbose option registration (currently not working)
- msf_calls_nil_check - Check if calls to the framework are checked against nil
- encoding_method_check - Check that the Rex::Text methods are used for stuff like base64

If you have any ideas for checks, please let mek know.


## Installation/usage
msflint only requires the 'parser' gem to analyze the source code

```
gem install parser
```

The tool can be used like msftidy.rb


```
./msflint.rb ../path/to/your/metasploit/modul(s)
```

## License

The code is released under the same license as the metasploit framework. It is a goal of this project to become
an official part of the metasploit project (as a replacement for msftidy.rb)

