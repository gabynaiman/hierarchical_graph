require_relative 'hierarchical_graph/version'
require_relative 'hierarchical_graph/node'

class HierarchicalGraph

  include Enumerable
  include TSort

  def initialize
    @nodes = {}
    @parent_to_children = {}
    @child_to_parents = {}
    @ancestors_cache = {}
    @descendants_cache = {}
  end

  def [](id)
    nodes[id]
  end

  def each(&block)
    nodes.each_value(&block)
  end

  def empty?
    nodes.empty?
  end

  def roots
    select(&:root?)
  end

  def add_node(id, attributes={})
    clear_cache
    parent_to_children[id] ||= Set.new
    child_to_parents[id] ||= Set.new
    nodes[id] = Node.new self, id, attributes
  end

  def remove_node(id)
    validate! id

    parent_to_children[id].each { |child_id| child_to_parents[child_id].delete id }
    child_to_parents[id].each { |parent_id| parent_to_children[parent_id].delete id }

    parent_to_children.delete id
    child_to_parents.delete id

    nodes.delete id
    clear_cache

    nil
  end

  def add_relation(parent_id:, child_id:)
    validate! parent_id, child_id

    clear_cache
    parent_to_children[parent_id] << child_id
    child_to_parents[child_id] << parent_id

    nil
  end

  def remove_relation(parent_id:, child_id:)
    validate! parent_id, child_id

    clear_cache
    parent_to_children[parent_id].delete child_id
    child_to_parents[child_id].delete parent_id

    nil
  end

  def parents_of(id)
    child_to_parents.fetch(id, Set.new).map { |node_id| nodes[node_id] }
  end

  def children_of(id)
    parent_to_children.fetch(id, Set.new).map { |node_id| nodes[node_id] }
  end

  def ancestors_of(id)
    ancestors_cache[id] ||= parents_of(id).flat_map do |parent|
      ancestors_of(parent.id) + [parent]
    end.uniq(&:id)
  end

  def descendants_of(id)
    children_of(id).flat_map do |child|
      [child] + descendants_of(child.id)
    end.uniq(&:id)
  end

  def to_s
    "<#{self.class.name} nodes:[#{map(&:to_s).join(', ')}]>"
  end
  alias_method :inspect, :to_s

  private

  attr_reader :nodes, :parent_to_children, :child_to_parents, :ancestors_cache, :descendants_cache

  def validate!(*ids)
    invalid_ids = ids.reject { |id| nodes.key? id }
    raise "Invalid nodes: #{invalid_ids.join(', ')}" if invalid_ids.any?
  end

  def clear_cache
    descendants_cache.clear
    ancestors_cache.clear
  end

  def tsort_each_child(node, &block)
    children_of(node.id).each(&block)
  end

  def tsort_each_node(&block)
    each(&block)
  end

end