#!/usr/bin/env ruby

require 'erb'
require 'optparse'

class MakeHeatmapDeg

  def initialize(argv)
    @params = argv.getopts("i:", "ident:GeneSymbol")
  end

  def create_deg_heatmaps
    write_heatmap_degs_r
    system("R --no-save < ./heatmap_degs.r")
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

    def get_date_string
      Time.new.strftime("%Y%m%d")
    end

    def write_heatmap_degs_r
      date_string = get_date_string
      uniq_id = @params["i"] || @params["ident"] 
      erb = ERB.new(IO.read("#{x_seq_dir}/heatmap_degs.r.erb"))
      File.open("./heatmap_degs.r", "w") { |f| f.print erb.result(binding) }
    end
end

if __FILE__ == $0
  make_heatmap_deg = MakeHeatmapDeg.new(ARGV)
  make_heatmap_deg.create_deg_heatmaps
end
