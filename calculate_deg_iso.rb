require 'erb'
require '~/src/x-seq/calculate_deg.rb'

class CalculateDegIso < CalculateDeg

  private

    def genes_results
      @sample_ids.map { |id| "./RSEM/#{id}.isoforms.results" }.join(" ")
    end

    def edgeR_script
      erb = ERB.new(IO.read("#{x_seq_dir}/edgeR_script_iso.r.erb"))
      erb.result(binding)
    end

    def results_format_script
      date_string = get_date_string
      erb = ERB.new(IO.read("#{x_seq_dir}/results_format_iso.r.erb"))
      erb.result(binding)
    end
end

if __FILE__ == $0
  calculate_deg = CalculateDegIso.new(ARGV[0])
  calculate_deg.generate_matrix
  calculate_deg.write_edgeR_script
  calculate_deg.write_results_format_script
  calculate_deg.run_scripts
end
