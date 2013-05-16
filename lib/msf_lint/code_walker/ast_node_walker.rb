# encoding: utf-8
module MsfLint::CodeWalker

	# AstNodeWalker
	# Creates a AST node
	class AstNodeWalker < BaseWalker
		def initialize(options={})
			super
			@node_checks = {}
			@checks.each do |check|
				check.interesting_nodes.each do |node|
					@node_checks[node] ||= []
					@node_checks[node] << check
					@node_checks[node].uniq!
				end
			end
		end

		# step through the code and call the enabled test cases
		#
		# @param [String] filename is the filename of ruby code.
		# @param [String] content is the content of ruby file.
		def check(filename, content)
			node = parse(filename, content)
			check_node(node)
			check_completed
		end

		# parse ruby code.
    	#
    	# @param [String] filename is the filename of ruby code.
    	# @param [String] content is the content of ruby file.
		def parse(filename, content)
			begin
				parsed_content = Parser::Ruby19.parse(content)
				parsed_content
			rescue Exception
				# TODO: Improve me
     			# raise CodeAnalyzer::AnalyzerException.new("#{filename} looks like it's not a valid Ruby file.  Skipping...")
				notes << MsfLint::Note.new(MsfLint::Note::ERROR, "Exception when parsing the code", 0) 
			end
		end

		# recursively check AST node.
		#
		# 1. it triggers the interesting checkers' start callbacks.
		# 2. recursively check the sexp children.
		# 3. it triggers the interesting checkers' end callbacks.
		def check_node(node)
			if node.instance_of?(Parser::AST::Node) then
				checks = @node_checks[node.type] 
				if checks then
					checks.each do |check|
						check.check_node(node) 
					end
				end

				node.children.each do |child_node|
					if child_node.instance_of?(Parser::AST::Node) then
						child_node.check(self)
					end
				end
			end
		end	


		# called at last, after all other node checks are completed
		#
		# can be used to verify certain conditions, for example if 
		# a class contains a certain function.
		def check_completed
			@checks.each do |check|
				check.check_completed
			end
		end	


	end
end