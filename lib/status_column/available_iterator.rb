require 'status_column/iterator'

module StatusColumn
  class AvailableIterator < Iterator
    def initialize(model)
      @model = model
    end

    def each(&block)
      @model.active.each { |el| safe_call(el, block) }
      @model.pending.each { |el| safe_call(el, block) }
      @model.rechecking.each { |el| safe_call(el, block) }
    end
  end
end
