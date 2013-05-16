module AST
	class Node
		# check current node.
  		#
  		# @param [RubyLinter::Codewalker::AstNodeWalker] code_walker the code_walker to check current node
		def check(code_walker)
			code_walker.check_node(self)
		end

		# The code line, actually just a short version for src.line
		def line
			self.src.line
		end

		# Has the node any children
		def children?
			@children.size > 0 ? true : false
		end
	end
end