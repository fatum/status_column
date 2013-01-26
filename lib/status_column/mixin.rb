require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'status_column/available_iterator'
require 'state_machine'

module StatusColumn
  MAX_ATTEMPTS = 5

  module Mixin
    extend ActiveSupport::Concern

    included do
      def self.available
        AvailableIterator.new(self)
      end

      # TODO set column names
      class_attribute :execution_tracking
      self.execution_tracking = false

      before_create ->(record) { record.execute_at ||= Time.zone.now }

      scope :attempts_not_exceeds, -> { where("attempts <= #{StatusColumn::MAX_ATTEMPTS}") }
      scope :with_status, ->(status) { where(status: status.to_s) }
      scope :active, -> { live.with_status(:new) }

      scope :live, ->{
        attempts_not_exceeds.
        where("execute_at < ? OR execute_at IS NULL", Time.zone.now)
      }

      scope :pending, -> {
        with_status(:running).
        attempts_not_exceeds.
        where("updated_at < ?", 10.minutes.ago)
      }

      scope :rechecking, -> {
        with_status(:failed).live
      }

      state_machine :status, initial: :new do
        state :running
        state :new
        state :failed
        state :processed

        event(:run) { transition any => :running }
        event(:error) { transition :running => :failed }
        event(:finish) { transition :running => :processed }

        after_transition any => :failed do |record|
          record.increment(:attempts).save!
          record.update_attribute :execute_at, 10.minutes.from_now
        end
      end
    end
  end
end
