require 'status_column/iterator'

module StatusColumn
  class AvailableIterator < Iterator
    def initialize(model)
      @model = model
    end

    def each
      callback = lambda { |el| safe_call(el, &block) }

      @model.active.each(callback)
      @model.pending.each(callback)
      @model.rechecking.each(callback)
    end
  end
end
