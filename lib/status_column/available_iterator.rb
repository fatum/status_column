require 'status_column/iterator'

module StatusColumn
  class AvailableIterator < Iterator
    def initialize(model)
      @model = model.class
    end

    def each(&block)
      callback = lambda { |el| safe_call(el, block) }

      @model.active.each(callback)
      @model.pending.each(callback)
      @model.rechecking.each(callback)
    end
  end
end
