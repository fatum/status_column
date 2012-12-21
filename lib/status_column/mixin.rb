require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'status_column/available_iterator'
require 'state_machine'

module StatusColumn
  module Mixin
    extend ActiveSupport::Concern

    def available
      AvailableIterator.new(self)
    end

    included do |base|
      # TODO set column names
      class_attribute :status, :execute_at, :attempts

      before_create ->(record) { record.execute_at ||= Time.zone.now }

      MAX_ATTEMPTS = 5

      scope :live, ->{
        where("attempts <= #{MAX_ATTEMPTS}").
        where("execute_at < ? OR execute_at IS NULL", Time.zone.now)
      }

      scope :active, -> { live.where(status: :new) }

      scope :pending, -> {
        where(status: :running).
        where("attempts <= #{MAX_ATTEMPTS}").
        where("updated_at < ?", 10.minutes.ago)
      }

      scope :rechecking, -> {
        where(status: :failed).live
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
