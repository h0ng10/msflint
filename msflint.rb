#!/usr/bin/env ruby

# msflint by Hans-Martin Muench (h0ng10)

$LOAD_PATH << File.dirname(__FILE__) + "/lib" 
$LOAD_PATH << File.dirname(__FILE__) 

require 'lint_worm'
require 'checks/for_loop_check'
require 'checks/load_usage_check'
require 'checks/line_length_check'
require 'checks/bad_indent_check'
require 'checks/end_of_line_check'
require 'checks/name_check'
require 'checks/function_basics_check'
require 'checks/ranking_check'
require 'checks/register_option_check'
require 'checks/request_cgi_check'
require 'checks/file_open_binary_check'
require 'checks/unused_parameter_check'
require 'checks/global_variable_check'
require 'checks/update_info_check'
require 'checks/empty_rescue_check'

class String
	def red
		"\e[1;31;40m#{self}\e[0m"
	end

	def yellow
		"\e[1;33;40m#{self}\e[0m"
	end

	def ascii_only?
		self =~ Regexp.new('[\x00-\x08\x0b\x0c\x0e-\x19\x7f-\xff]', nil, 'n') ? false : true
	end
end

class MsfLint

	def initialize

	end

	def check_file(filename)

		# Simple checks which that be called for each code line
		line_checks = Array.new
		line_checks << LineLengthCheck.new
		line_checks << BadIndentCheck.new
		line_checks << EndOfLineCheck.new

		# Complex/advanced checks that require a parsed AST:Node
		ast_node_checks = Array.new
		ast_node_checks << ForLoopCheck.new
		ast_node_checks << LoadUsageCheck.new
		ast_node_checks << GlobalVariableCheck.new
		ast_node_checks << FileOpenBinaryCheck.new
		ast_node_checks << FunctionBasicsCheck.new
		ast_node_checks << RankingCheck.new
		ast_node_checks << RegisterOptionCheck.new
		ast_node_checks << UnusedParameterCheck.new
		ast_node_checks << EmptyRescueCheck.new
		ast_node_checks << RequestCgiCheck.new
		ast_node_checks << UpdateInfoCheck.new
		ast_node_checks << NameCheck.new

		line_walker = LintWorm::CodeWalker::LineWalker.new(checks: line_checks)
		ast_walker = LintWorm::CodeWalker::AstNodeWalker.new(checks: ast_node_checks)

		ruby_file = open(filename, 'rb')
		content = ruby_file.read(ruby_file.stat.size)
		ruby_file.close

		line_walker.check(filename,content)
		ast_walker.check(filename, content)

		check_notes = Array.new
		check_notes.concat(line_walker.notes)
		check_notes.concat(ast_walker.notes)

		check_notes.each do |note| 
			case note.severity
			when LintWorm::Note::ERROR
				puts "#{filename}:#{note.line} - [#{note.severity.red}] #{note.message}"
			else
				puts "#{filename}:#{note.line} - [#{note.severity.yellow}] #{note.message}"
			end
		end

		# Drop the check notes afterwards
		#puts @line_walker.notes.size
		#puts @ast_walker.notes.size

	end
end


##
#
# Main program
#
##

dirs = ARGV

if dirs.length < 1 then
        $stderr.puts "Usage: #{File.basename(__FILE__)} <directory or file>"
        exit(1)
end

msflint= MsfLint.new()

dirs.each do |directory|
	file_name = nil
	old_directory = nil

	if directory
		if File.file?(directory)
			# whoa, a single file!
			file_name = File.basename(directory)
			directory = File.dirname(directory)
		end

		old_directory = Dir.getwd
		Dir.chdir(directory)
		dparts = directory.split('/')
	else
		dparts = []
	end

	# Only one file?
	if file_name
		msflint.check_file(file_name)
	else
		# Do a recursive check of the specified directory
		Dir.glob('**/*.rb') { |f|
			msflint.check_file(f)
		}
	end
 
 	Dir.chdir(old_directory)
end
