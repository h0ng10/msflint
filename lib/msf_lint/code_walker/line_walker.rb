# encoding: utf-8
module MsfLint::CodeWalker

	# AstNodeWalker
	class LineWalker < BaseWalker
		def initialize(options={})
			super
		end


		def check(filename, content)
			line_number = 1
			in_comment = false
			in_literal = false
			src_ended = false

			content.each_line do |line|

				# block comment awareness
				if line =~ /^=end$/
					in_comment = false
					next
				end
				
				in_comment = true if line =~ /^=begin$/
				next if in_comment

				# block string awareness (ignore indentation in these)
				in_literal = false if line =~ /^EOS$/
				next if in_literal
				in_literal = true if line =~ /\<\<-EOS$/

				# ignore stuff after an __END__ line
				src_ended = true if line =~ /^__END__$/
				next if src_ended

				@checks.each {|check| check.check_line(filename, line_number, line) }
				line_number += 1
			end
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
     		#	$stderr.print "Parsing of code failed: " + $!.to_s
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

	end
end