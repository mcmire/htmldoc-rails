# Extend 'htmldoc' gem to support the edge releases of the htmldoc executable
# and to make usage a bit more intuitive
module PDF
  class HTMLDoc
    @@basic_options << :top    unless @@basic_options.include?(:top)
    @@basic_options << :bottom unless @@basic_options.include?(:bottom)
    @@all_options = @@basic_options + @@extra_options
    
    DEFAULT_OPTIONS = {
      :bodycolor => 'white',
      :toc => false,
      :portrait => true,
      :continuous => true,
      :footer => '...',
      :header => '...',
      :links => false,
      :webpage => true,
      :left => '50',
      :right => '50',
      :top => '90',
      :size => 'Letter'
    }
  end
end
