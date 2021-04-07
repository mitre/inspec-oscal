require_relative "./helper"

describe "the inspec-oscal plugin" do
  include VaultIntegrationHelper

  let(:env) do
    {
      # VAULT_ADDR: "https://127.0.0.1:8200" # These should already be set by rakefile
      # VAULT_TOKEN: ""                      # These should already be set by rakefile
    }
  end
  describe "when run with a profile mentioning the inputs" do
    it "should find the values in oscal" do
      cmd = "exec #{profile_fixtures}/profile-01"
      result = run_inspec_with_oscal_plugin(cmd, env: env)
      assert_empty result.stderr
      assert_equal result.exit_status, 0
    end
  end

  # Try inheritance
  # Try custom prefix

  describe "when run with custom priority values" do
    def run_priority_test(priority, first_should_pass)
      cmd = "exec #{profile_fixtures}/priority --reporter json"
      env["INSPEC_VAULT_PRIORITY"] = priority
      result = run_inspec_with_oscal_plugin(cmd, env: env)
      json = JSON.parse(result.stdout)
      ctls = json.dig("profiles", 0, "controls")
      assert_equal "passed", ctls.dig(0, "results", 0, "status"), ctls.dig(0, "id")
      assert_equal "passed", ctls.dig(1, "results", 0, "status"), ctls.dig(1, "id")
      assert_equal (first_should_pass ? "passed" : "failed"), ctls.dig(2, "results", 0, "status"), ctls.dig(2, "id")
      assert_equal (first_should_pass ? "failed" : "passed"), ctls.dig(2, "results", 1, "status"), ctls.dig(2, "id")
    end

    it "should be overridden by DSL when the priority is low" do
      run_priority_test(25, true)
    end

    it "should override DSL when the priority is high" do
      run_priority_test(75, false)
    end
  end

  describe "when run with default priority" do
    it "should pass the threshold tests" do
      cmd = "exec #{profile_fixtures}/priority --reporter json"
      cmd_result = run_inspec_with_oscal_plugin(cmd, env: env)
      json = JSON.parse(cmd_result.stdout)
      results = json.dig("profiles", 0, "controls", 3, "results")
      results.each do |rslt|
        assert_equal "passed", rslt.dig("status")
      end
    end
  end
end
