class FunctionBasicsCheck < LintWorm::Check

	interesting_nodes :def

	add_callback :check_def do |node| 
		if node.children[1].children.size > 6 then
			add_note(LintWorm::Note::WARNING, "Poorly designed argument list in '#{node.children[0]}'. Try a hash.", node.line)
		end
	end

end
