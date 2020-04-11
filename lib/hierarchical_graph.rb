require_relative 'hierarchical_graph/version'
require_relative 'hierarchical_graph/node'

class HierarchicalGraph

  include TSort

  def initialize
    @index = {}
    @parent_to_children = Hash.new { |h,k| h[k] = Set.new }
    @child_to_parents = Hash.new { |h,k| h[k] = Set.new }
    @ancestors_cache = {}
    @descendants_cache = {}
  end

  def [](id)
    index[id]
  end

  def nodes
    index.values
  end

  def roots
    nodes.select(&:root?)
  end

  def add_node(id, attributes={})
    clear_cache
    index[id] = Node.new self, id, attributes
  end

  def remove_node(id)
    validate! id

    parent_to_children[id].each { |child_id| child_to_parents[child_id].delete id }
    child_to_parents[id].each { |parent_id| parent_to_children[parent_id].delete id }

    parent_to_children.delete id
    child_to_parents.delete id

    index.delete id
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
    child_to_parents[id].map { |node_id| index[node_id] }
  end

  def children_of(id)
    parent_to_children[id].map { |node_id| index[node_id] }
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

  private

  attr_reader :index, :parent_to_children, :child_to_parents, :ancestors_cache, :descendants_cache

  def validate!(*ids)
    invalid_ids = ids.reject { |id| index.key? id }
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
    nodes.each(&block)
  end

end