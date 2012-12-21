module StatusColumn
  class Iterator
    include Enumerable

    def initialize(scoped_model)
      @model = scoped_model
    end

    def each(&block)
      model.each { |element| safe_call(element, block) }
    end

    def safe_call(el, block)
      el.run!
      block.call(el)
    rescue
      el.failed!
    end
  end
end
