class HierarchicalGraph
  class Node

    attr_reader :id, :data

    def initialize(graph, id, data={})
      @graph = graph
      @id = id
      @data = data
    end

    def [](key)
      data[key]
    end

    def []=(key, value)
      data[key] = value
    end

    def parents
      graph.parents_of id
    end

    def children
      graph.children_of id
    end

    def ancestors
      graph.ancestors_of id
    end

    def descendants
      graph.descendants_of id
    end

    def root?
      parents.empty?
    end

    def descendants_subgraph
      graph.descendants_subgraph_from id
    end

    def to_s
      "<#{self.class.name} #{id} parents:[#{parents.map(&:id).join(', ')}] children:[#{children.map(&:id).join(', ')}]>"
    end
    alias_method :inspect, :to_s

    private

    attr_reader :graph

  end
end