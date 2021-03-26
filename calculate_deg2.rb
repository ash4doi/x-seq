require 'erb'
require '~/src/x-seq/calculate_deg.rb'

class CalculateDeg2 < CalculateDeg

  def initialize(comp_num, disp)
    @sample_list = IO.readlines("./sample_list.txt").map(&:chomp)
    @sample_ids  = get_sample_ids(@sample_list)
    @comp_num    = comp_num.to_i
    @dispersion  = disp.nil? ? 0.01 : disp
  end

  private

    def comp_list
      comp = IO.readlines("./comp_list.txt").map(&:chomp)
      comp.map.with_index(@comp_num) { |pair, i| [i, pair_to_array(pair)] }.to_h
    end
end

if __FILE__ == $0
  calculate_deg2 = CalculateDeg2.new(ARGV[0], ARGV[1])
  calculate_deg2.generate_matrix
  calculate_deg2.write_edgeR_script
  calculate_deg2.write_results_format_script
  calculate_deg2.run_scripts
end
