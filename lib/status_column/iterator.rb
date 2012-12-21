module StatusColumn
  class Iterator
    include Enumerable

    def initialize(scoped_model)
      @model = scoped_model
    end

    def each(&block)
      model.each { |element| safe_call(element, block) }
    end

    def safe_call(el, &block)
      if @model.execution_tracking
        begin
          el.run!
          block.call(el)
          el.finish!
        rescue
          el.error!
        end
      else
        block.call(el)
      end
    end
  end
end
