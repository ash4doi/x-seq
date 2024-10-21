#!/usr/bin/env ruby

require 'erb'
require 'optparse'

class MakeHeatmapFromPathway

  def initialize(argv)
    params = argv.getopts("i:", "ident:GeneSymbol")
    @uniq_id = params["i"] || params["ident"] 
  end

  def create_heatmaps
    write_heatmap_interesting_genes_r
    system("R --no-save < ./heatmap_pathway_genes.r")
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def write_heatmap_interesting_genes_r
      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_pathway_genes.r.erb"))
      File.open("./heatmap_pathway_genes.r", "w") { |f| f.print erb.result(binding) }
    end
end

if __FILE__ == $0
  make_heatmap_from_list = MakeHeatmapFromPathway.new(ARGV)
  make_heatmap_from_list.create_heatmaps
end
