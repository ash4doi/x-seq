#!/usr/bin/env ruby

require 'erb'
require 'http'
require 'optparse'


class PcaPlotly

  def initialize(pca_file)
    @pca_data = IO.readlines(pca_file).map(&:chomp).drop(1)
    @pos_file = "pca_pos.txt"
  end

  def create_plotly_html
    convert_position
    write_plotly_html
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def convert_position
      header = generate_header(@pca_data.size)
      pca_data = extract_pcs(@pca_data)
      pos_result = header + "\n" + pca_data
      write_pos_file(pos_result)
    end

    def generate_header(sample_size)
      x_y_z = (1..sample_size).to_a.map { |i|"x#{i},y#{i},z#{i}" }
      x_y_z.join(",")
    end

    def extract_pcs(pca_data)
      pc1_pc2_pc3 = pca_data.map { |line| line.split("\t").drop(1).join(",") }
      pc1_pc2_pc3.join(",")
    end

    def write_pos_file(pos_result)
      pos_file = "./pca_pos.txt"
      File.open(pos_file, "w"){ |f| f.puts pos_result }
    end

    def generate_sample_ids
      n = @pca_data.size
      sample_ids = []
      (1..n).each { |n| samples_ids = sample_ids << "sample#{n}" }
      sample_ids.join(", ")
    end

    def generate_html
      color_data = read_color_list
      erb = ERB.new(IO.read("#{x_seq_dir}/pca_plotly.html.erb"))
      erb.result(binding)
    end

    def write_plotly_html
      plotly_html = generate_html
      plotly_file = "./pca_plotly.html"
      File.open(plotly_file, "w"){ |f| f.puts plotly_html }
    end

    def read_color_list
      color_list = IO.readlines("color_list.txt").drop(1).map(&:chomp)
      color_list.map.with_index(1) { |x, i| name_color_hash(x, i) }
    end

    def name_color_hash(x, i)
      n, c = x.split
      {index: i, name: n, color: c}
    end

end

if __FILE__ == $0
  pca_plotly = PcaPlotly.new(ARGV[0])
  pca_plotly.create_plotly_html
end
