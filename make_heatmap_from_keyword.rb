#!/usr/bin/env ruby

require 'erb'
require 'optparse'

class MakeHeatmapFromKeyword

  def initialize(argv)
    @params = argv.getopts("r:k:f:", "result:all_results.tsv", "keyword:", "filtering_rule:")
  end

  def extract_genes_from_keyword
    if keyword = @params["k"] || @params["keyword"]
      write_select_keyword_genes_r
      system("R --no-save < ./select_keyword_genes.r")
    else
      write_select_filtering_genes_r
      system("R --no-save < ./select_filtering_genes.r")
    end
  end

  def create_heatmaps
    if keyword = @params["k"] || @params["keyword"]
      write_heatmap_keyword_genes_r
      system("R --no-save < ./heatmap_keyword_genes.r")
    else
      write_heatmap_filtering_genes_r
      system("R --no-save < ./heatmap_filtering_genes.r")
    end
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def write_select_keyword_genes_r
      result_file = (@params["r"] || @params["result"])
      keyword = @params["k"] || @params["keyword"]
      erb = ERB.new(IO.read("#{x_seq_dir}/select_keyword_genes.r.erb"))
      File.open("./select_keyword_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_heatmap_keyword_genes_r
      keyword = @params["k"] || @params["keyword"]
      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_keyword_genes.r.erb"))
      File.open("./heatmap_keyword_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_select_filtering_genes_r
      result_file = (@params["r"] || @params["result"])
      filtering_file = (@params["f"] || @params["filtering_rule"])
      filtering_name = File.basename(filtering_file, ".*")
      filtering_rule = File.open(filtering_file, "r") {|f| f.read}
      erb = ERB.new(IO.read("#{x_seq_dir}/select_filtering_genes.r.erb"))
      File.open("./select_filtering_genes.r", "w") { |f| f.print erb.result(binding) }
    end

    def write_heatmap_filtering_genes_r
      filtering_file = (@params["f"] || @params["filtering_rule"])
      filtering_name = File.basename(filtering_file, ".*")
      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_filtering_genes.r.erb"))
      File.open("./heatmap_filtering_genes.r", "w") { |f| f.print erb.result(binding) }
    end
    
    def clean_name(keyword)
      keyword.tr("^0-9A-Za-z",'_')
    end
end

if __FILE__ == $0
  make_heatmap_from_keyword = MakeHeatmapFromKeyword.new(ARGV)
  make_heatmap_from_keyword.extract_genes_from_keyword
  make_heatmap_from_keyword.create_heatmaps
end
