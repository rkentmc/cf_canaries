require 'spec_helper'
require 'cf_canaries/command_runner'

module CfCanaries
  describe CommandRunner do
    let(:dry_run) { false }
    let(:logger) { double('Logger', info: nil) }
    subject(:command_runner) { CommandRunner.new(logger, dry_run, "my-cf") }

    let(:command) { 'apps' }

    before do
      allow(Process).to receive(:spawn).and_return(1234)
      allow(Process).to receive(:wait2).with(1234)
    end

    describe "#cf!" do
      it "logs the command and waits on the spawned process" do
        expect(logger).to receive(:info).with('my-cf apps')
        expect(Process).to receive(:wait2).and_return([1234, double('Process::Status', success?: true)])

        command_runner.cf!(command)
      end

      context "when not specifying a cf_command in the initializer" do
        subject(:command_runner) { CommandRunner.new(logger, dry_run) }

        it "defaults to gcf" do
          expect(logger).to receive(:info).with('gcf apps')
          expect(Process).to receive(:wait2).and_return([1234, double('Process::Status', success?: true)])
          command_runner.cf!(command)
        end
      end

      context "running in dry_run mode" do
        let(:dry_run) { true }

        it "logs the command but does not run it" do
          expect(logger).to receive(:info).with('my-cf apps')
          expect(Process).not_to receive(:spawn)
          expect(Process).not_to receive(:wait2)

          command_runner.cf!(command)
        end
      end

      context "when the command fails" do
        it "logs the command but does not run it" do
          expect(Process).to receive(:wait2).and_return([1234, double('Process::Status', success?: false)])

          expect { command_runner.cf!(command) }.to raise_error
        end
      end
    end
  end
end
