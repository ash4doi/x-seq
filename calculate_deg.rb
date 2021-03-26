require 'erb'

class CalculateDeg

  def initialize(disp)
    @sample_list = IO.readlines("./sample_list.txt").map(&:chomp)
    @sample_ids  = get_sample_ids(@sample_list)
    @dispersion  = disp.nil? ? 0.01 : disp
  end

  def generate_matrix
    system("#{rsem_script} #{genes_results} > counts.matrix")
  end

  def write_edgeR_script
    File.open("./edgeR_script.r", "w") do |f|
      f.print edgeR_script
    end
  end

  def write_results_format_script
    File.open("./results_format.r", "w") do |f|
      f.print results_format_script
    end
  end

  def run_scripts
    system("mkdir -p results")
    system("R --no-save < ./edgeR_script.r")
    system("R --no-save < ./results_format.r")
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def rsem_script
      "~/src/RSEM-1.3.1/rsem-generate-data-matrix"
    end

    def genes_results
      @sample_ids.map { |id| "./RSEM/#{id}.genes.results" }.join(" ")
    end

    def edgeR_script
      erb = ERB.new(IO.read("#{x_seq_dir}/edgeR_script.r.erb"))
      erb.result(binding)
    end

    def edgeR_script_n3
      erb = ERB.new(IO.read("#{x_seq_dir}/edgeR_script_n3.r.erb"))
      erb.result(binding)
    end

    def results_format_script
      erb = ERB.new(IO.read("#{x_seq_dir}/results_format.r.erb"))
      erb.result(binding)
    end

    def to_strings(array)
      array.to_s.gsub(/\[|\]/, '')
    end

    def get_sample_ids(sample_list)
      sample_list.map { |x| x.split("\t").first.strip }
    end

    def comp_list
      comp = IO.readlines("./comp_list.txt").map(&:chomp)
      comp.map.with_index(1) { |pair, i| [i, pair_to_array(pair)] }.to_h
    end

    def pair_to_array(pair)
      pair.split(" vs ").map(&:strip)
    end
end

if __FILE__ == $0
  calculate_deg = CalculateDeg.new(ARGV[0])
  calculate_deg.generate_matrix
  calculate_deg.write_edgeR_script
  calculate_deg.write_results_format_script
  calculate_deg.run_scripts
end
