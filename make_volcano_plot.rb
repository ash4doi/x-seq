#!/usr/bin/env ruby

require 'erb'
require 'optparse'

class MakeVolcanoPlot

  def initialize(argv)
    @params = argv.getopts("i:", "ident:GeneSymbol")
  end

  def create_volcano_plot
    write_volcano_plot_r
    system("R --no-save < ./volcano_plot.r")
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def comp_list
      comp = IO.readlines("./comp_list.txt").map(&:chomp)
      comp.map.with_index(1) { |pair, i| [i, pair_to_array(pair)] }.to_h
    end

    def pair_to_array(pair)
      pair.split(" vs ").map(&:strip)
    end

    def write_volcano_plot_r
      uniq_id = @params["i"] || @params["ident"]
      erb = ERB.new(IO.read("#{x_seq_dir}/volcano_plot.r.erb"))
      File.open("./volcano_plot.r", "w") { |f| f.print erb.result(binding) }
    end
end

if __FILE__ == $0
  make_volcano_plot = MakeVolcanoPlot.new(ARGV)
  make_volcano_plot.create_volcano_plot
end
