class ForLoopCheck < LintWorm::Check

  interesting_nodes :for

  add_callback :check_for do |node| 
		add_note(LintWorm::Note::WARNING, "Please try to avoid using for loops.", node.line)
  end


end
