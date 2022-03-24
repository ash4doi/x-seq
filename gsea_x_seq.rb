require 'erb'

class GseaXseq
  def initialize
    @sample_list = IO.readlines("./sample_list.txt").map(&:chomp)
    @group_ids   = get_group_ids(@sample_list)
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

    def get_group_ids(sample_list)
      sample_list.map { |s| group_id_of(s) }
    end

    def group_id_of(sample)
      sample.split("\t").last.strip
    end

    def comp_list
      comp = IO.readlines("./comp_list.txt").map(&:chomp)
      comp.map.with_index(1) { |pair, i| [i, pair_to_groups(pair)] }.to_h
    end

    def pair_to_groups(pair)
      pair.split(" vs ").map(&:strip)
    end

    def data_is_n3?
      @group_ids.size >= @group_ids.sort.uniq.size * 3
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
      @comp_list.each do |i, groups|
        File.open("./GSEA/comp#{i}.cls", "w") do |f|
          f.print cls_data(groups).join("\n")
        end
      end
    end

    def cls_data(groups)
      data = []
      data << "#{groups.size} 2 1"
      data << "# #{groups.join(" ")}"
      data << "#{compX_group_ids(groups).join(" ")}"
    end

    def compX_group_ids(groups)
      group1_samples = @sample_list.select { |s| group_id_of(s).match?(/^#{groups.first}$/) }
      group2_samples = @sample_list.select { |s| group_id_of(s).match?(/^#{groups.last}$/) }
      get_group_ids(group1_samples + group2_samples)
    end

    def write_gsea_sh
      @comp_list.each do |i, comp_pair|
        write_gsea_sh_with_gmx_each_comp(i, comp_pair)
      end
    end

    def write_gsea_sh_with_gmx_each_comp(i, comp_pair)
      gmx_file_list.each do |listname, gmx_file_path|
        File.open("./GSEA/gsea_comp#{i}_#{listname}.sh", "w") do |f|
          f.print gsea_sh(i, comp_pair, gmx_file_path)
        end
      end
    end

    def gsea_home
      "#{Dir.home}/src/GSEA"
    end

    def gsea_sh(i, comp_pair, gmx_file_path)
      memory = gmx_file_path.include?("h.all") ? 1024 : 2048
      erb = ERB.new(IO.read("#{x_seq_dir}/gsea.sh.erb"))
      erb.result(binding)
    end

    def gsea_metric
      data_is_n3? ? "Signal2Noise" : "log2_Ratio_of_Classes"
    end

    def gmx_file_list
      list = IO.readlines("./gmx_file_list.txt").map(&:chomp)
      clean_list = list.select { |x| !(x =~ /^#|^$/) }
      clean_list.map { |x| x.split("\t") }.to_h
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
