#!/usr/bin/env ruby

require 'erb'
require 'http'
#require 'nokogiri'
require 'optparse'

class KeggPathwayAnalysis

  def initialize(argv)
    system("mkdir -p pathway")
    @pathway_ids = IO.readlines("./pathway_list.txt").map(&:chomp).drop(1)
    @params = argv.getopts("lp", "logFC", "pvalue", "result:all_results.tsv")
    @pathway_hash = get_pathway_hash(@pathway_ids.first)
  end

  def write_entrez_ids
    @pathway_ids.each do |pathway_id|
      STDOUT.puts "get #{pathway_id} ids..."
      entrez_ids = get_entrez_ids(pathway_id)
      filename = "./pathway/#{pathway_id}_ids.txt"
      File.open(filename, "w"){ |f| f.puts entrez_ids }
      sleep 1
    end
  end

  def extract_pathway_results
    write_pathway_genes_script
    system("R --no-save < ./pathway_genes.r")
  end

  def write_pathway_list
    @pathway_ids.each do |pathway_id|
      STDOUT.puts "generate #{pathway_id} list..."
      html = generate_pathway_list_html(pathway_id)
      filename = "./pathway/#{pathway_id}_list.html"
      File.open(filename, "w"){ |f| f.puts html }
      sleep 1
    end
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def kegg_link
      "https://rest.kegg.jp/link"
    end

    def kegg_show_pathway
      "https://www.kegg.jp/kegg-bin/show_pathway"
    end

    def pathway_uri(pathway_id)
      org_id = pathway_id.gsub(/\d/, "")
      "#{kegg_link}/#{org_id}/#{pathway_id}"
    end

    def rest_kegg_list(pathway_id)
      org_id = pathway_id.gsub(/\d/, "")
      "https://rest.kegg.jp/list/pathway/#{org_id}"
    end

    def get_entrez_ids(pathway_id)
      pathway_genes = HTTP.get(pathway_uri(pathway_id)).to_s.lines
      pathway_genes.map {|x| x.split("\t").last.split(':').last.chomp}
    end

    def get_pathway_hash(pathway_id)
      pathway_list = HTTP.get(rest_kegg_list(pathway_id)).to_s.lines
      pathway_hash = pathway_list.map {|x| x.chomp.split("\t")}.to_h
    end

    def read_logFC_data(pathway_id)
      data = IO.readlines("./pathway/pathway_#{pathway_id}_logFC.tsv").map(&:chomp)
      data.map { |x| x.split("\t") }
    end

    def rest_url(logFC_data, col_num, pathway_id)
      comp_size = (logFC_data.first.size - 1) / 2
      comp_data  = logFC_data.map { |x| {entrez_id: x[0],
                                         logFC: x[col_num].to_f,
                                         PValue: x[comp_size + col_num].to_f} }
      deg_data   = select_deg(comp_data)
      color_data = deg_data.map { |x| "#{x[:entrez_id]}+#{kegg_color_code(x[:logFC])}" }
      rest_data  = color_data.join("%0A").gsub("#", "%23").gsub(",", "%2C")
      url = "#{kegg_show_pathway}?map=#{pathway_id}&multi_query=#{rest_data}"
    end

    def select_deg(comp_data)
      if @params["l"] || @params["logFC"] 
        comp_data.select { |x| x[:logFC] > 1 || x[:logFC] < -1 }
      elsif @params["p"] || @params["pvalue"]
        comp_data.select { |x| x[:PValue] < 0.05 }
      else
        comp_data.select { |x| (x[:logFC] > 1  && x[:PValue] < 0.05) ||
                               (x[:logFC] < -1 && x[:PValue] < 0.05) }
      end
    end

    def kegg_color
      {bg_up:   "#FF6699",
       bg_down: "#6699FF",
       fg:      "#000000"}
    end

    def kegg_color_code(logFC)
      if logFC > 0
        [kegg_color[:bg_up]].join(",")
      else
        [kegg_color[:bg_down]].join(",")
      end
    end

    def create_rest_urls(pathway_id)
      logFC_data = read_logFC_data(pathway_id)
      header = logFC_data.first
      comp_size = (header.size - 1) / 2
      col_names = header.take(comp_size + 1).map { |x| x.gsub("_logFC", "") }
      rest_urls = (1..comp_size).map { |i| [col_names[i],
                                            rest_url(logFC_data.drop(1), i, pathway_id)] }
    end

    def generate_pathway_list_html(pathway_id)
      erb = ERB.new(IO.read("#{x_seq_dir}/pathway_list.html.erb"))
      erb.result(binding)
    end

    def get_pathway_title(pathway_id)
      title = @pathway_hash[pathway_id]
      pathway_title = pathway_id + ": " + title
    end

    def write_pathway_genes_script
      result_file = (@params["r"] || @params["result"])
      erb = ERB.new(IO.read("#{x_seq_dir}/pathway_genes.r.erb"))
      File.open("./pathway_genes.r", "w") { |f| f.print erb.result(binding) }
    end
end

if __FILE__ == $0
  kegg_pathway_analysis = KeggPathwayAnalysis.new(ARGV)
  kegg_pathway_analysis.write_entrez_ids
  kegg_pathway_analysis.extract_pathway_results
  kegg_pathway_analysis.write_pathway_list
end
