#!/usr/bin/env ruby

require 'erb'
require 'optparse'

class MakeHeatmapFromList

  def initialize(argv)
    params = argv.getopts("r:g:i:", "result:all_results.tsv", "gene_list:", "ident:GeneSymbol")
    @result_file = params["r"] || params["result"]
    @list_file   = params["g"] || params["gene_list"]
    @uniq_id = params["i"] || params["ident"] 
  end

  def extract_genes_from_list
    if @list_file.nil?
      write_select_interesting_genes_r
      system("R --no-save < ./select_interesting_genes.r")
    else
      write_select_list_genes_r
      system("R --no-save < ./select_list_genes.r")
    end
  end

  def create_heatmaps
    if @list_file.nil?
      write_heatmap_interesting_genes_r
      system("R --no-save < ./heatmap_interesting_genes.r")
    else
      write_heatmap_list_genes_r
      system("R --no-save < ./heatmap_list_genes.r")
    end
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def write_select_interesting_genes_r
      erb = ERB.new(IO.read("#{x_seq_dir}/select_interesting_genes.r.erb"))
      File.open("./select_interesting_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_select_list_genes_r
      list_name = File.basename(@list_file, ".*")

      erb = ERB.new(IO.read("#{x_seq_dir}/select_list_genes.r.erb"))
      File.open("./select_list_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_heatmap_interesting_genes_r
      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_interesting_genes.r.erb"))
      File.open("./heatmap_interesting_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_heatmap_list_genes_r
      list_name = File.basename(@list_file, ".*")

      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_list_genes.r.erb"))
      File.open("./heatmap_list_genes.r", "w") { |f| f.print erb.result(binding) }
    end
end

if __FILE__ == $0
  make_heatmap_from_list = MakeHeatmapFromList.new(ARGV)
  make_heatmap_from_list.extract_genes_from_list
  make_heatmap_from_list.create_heatmaps
end
