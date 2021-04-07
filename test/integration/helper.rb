
require "inspec/globals"
require "train"
require_relative "../helper"

# Configure Minitest to expose things like `let`
class Module
  include Minitest::Spec::DSL
end

module OscalIntegrationHelper
  libdir = File.expand_path "lib"
  let(:inspec_install_path) { Inspec.src_root }
  let(:inspec_bin_path) { "#{`bundle show inspec-bin`.chomp}/bin/inspec" }
  let(:exec_inspec) { [Gem.ruby, "-I#{libdir}", inspec_bin_path].join " " }
  let(:profile_fixtures) { "test/fixtures/profiles" }

  def run_inspec_with_vault_plugin(cmd, opts)
    opts[:env] ||= {}
    opts[:env]["INSPEC_CONFIG_DIR"] = "test/fixtures/config-files" # To pick up plugins.json
    run_inspec_process(cmd, opts)
  end

  TRAIN_CONNECTION = Train.create("local", command_runner: :generic).connection

  def run_inspec_process(command_line, opts = {})
    prefix = ""
    if opts.key?(:prefix)
      prefix = opts[:prefix]
    elsif opts.key?(:env)
      prefix = opts[:env].to_a.map { |assignment| "#{assignment[0]}=#{assignment[1]}" }.join(" ")
    end
    TRAIN_CONNECTION.run_command("#{prefix} #{exec_inspec} #{command_line} --chef-license=accept-no-persist")
  end

end
