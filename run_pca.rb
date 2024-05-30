require 'erb'
require 'optparse'

class RunPCA

  def initialize
    @sample_list = IO.readlines("./sample_list.txt").map(&:chomp)
    @sample_ids  = get_sample_ids(@sample_list)
  end

  def write_pca_script
    File.open("./pca_script.r", "w") do |f|
      f.print pca_script
    end
  end

  def write_pca_2d_script
    File.open("./pca_script_2d.r", "w") do |f|
      f.print pca_script_2d
    end
  end

  def run_scripts
    system("mkdir -p results")
    system("R --no-save < ./pca_script.r")
    system("R --no-save < ./pca_script_2d.r")
  end

  private

    def x_seq_dir
      "#{Dir.home}/src/x-seq"
    end

    def pca_script
      date_string = get_date_string
      erb = ERB.new(IO.read("#{x_seq_dir}/pca_script.r.erb"))
      erb.result(binding)
    end

    def pca_script_2d
      date_string = get_date_string
      erb = ERB.new(IO.read("#{x_seq_dir}/pca_script_2d.r.erb"))
      erb.result(binding)
    end

    def get_sample_ids(sample_list)
      sample_list.map { |x| x.split("\t").first.strip }
    end

    def get_date_string
      Time.new.strftime("%Y%m%d")
    end
end

if __FILE__ == $0
  run_pca = RunPCA.new()
  run_pca.write_pca_script
  run_pca.write_pca_2d_script
  run_pca.run_scripts
end
