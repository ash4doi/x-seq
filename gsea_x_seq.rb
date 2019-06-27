require 'erb'

class GseaXseq
  def initialize
    @sample_list = IO.readlines("./sample_list.txt").map(&:chomp)
    @comp_list   = comp_list
    system("mkdir -p GSEA")
  end

  def prepare_gct_file
    puts "prepare prepare_gct.r and exec."
    write_prepare_gct_r
    create_gct_files
  end

  def prepare_gsea_script
    puts "prepare shell scripts."
    write_cls_files
    write_gsea_sh
  end

  def run_gsea
    puts "cd GSEA; chmod +x ./gsea_comp*.sh && ./gsea_comp1_hall.sh ... etc."
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def write_prepare_gct_r
      File.open("./prepare_gct.r", "w") do |f|
        f.print prepare_gct_r
      end
    end

    def prepare_gct_r
      erb = ERB.new(IO.read("#{x_seq_dir}/prepare_gct.r.erb"))
      erb.result(binding)
    end

    def write_cls_files
    end

    def write_gsea_sh
    end

    def comp_list
      comp = IO.readlines("./comp_list.txt").map(&:chomp)
      comp.map.with_index(1) { |pair, i| [i, pair_to_groups(pair)] }.to_h
    end

    def pair_to_groups(pair)
      pair.split(" vs ").map(&:strip)
    end

    def create_gct_files
      system('R --no-save < prepare_gct.r')
      @comp_list.each_key { |i| write_gct_file(i) }
    end

    def write_gct_file(i)
      data = IO.readlines("./GSEA/comp#{i}_gct.tsv")
      File.open("./GSEA/comp#{i}.gct", "w") do |f|
        f.print (gct_header(data) + data).join
      end
    end

    def gct_header(data)
      row    = data.size - 1
      column = data.first.split.size - 2
      ["#1.2\n#{row}\t#{column}\n"]
    end
end

if __FILE__ == $0
  gsea_x_seq = GseaXseq.new()
  gsea_x_seq.prepare_gct_file
  gsea_x_seq.prepare_gsea_script
  gsea_x_seq.run_gsea
end
