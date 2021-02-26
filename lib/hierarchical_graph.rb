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
    validate_not_present! id

    clear_cache
    parent_to_children[id] = Set.new
    child_to_parents[id] = Set.new
    nodes[id] = Node.new self, id, attributes
  end

  def remove_node(id)
    validate_present! id

    parent_to_children[id].each { |child_id| child_to_parents[child_id].delete id }
    child_to_parents[id].each { |parent_id| parent_to_children[parent_id].delete id }

    parent_to_children.delete id
    child_to_parents.delete id

    nodes.delete id
    clear_cache

    nil
  end

  def add_relation(parent_id:, child_id:)
    validate_present! parent_id, child_id

    clear_cache
    parent_to_children[parent_id] << child_id
    child_to_parents[child_id] << parent_id

    nil
  end

  def remove_relation(parent_id:, child_id:)
    validate_present! parent_id, child_id

    clear_cache
    parent_to_children[parent_id].delete child_id
    child_to_parents[child_id].delete parent_id

    nil
  end

  def parents_of(id)
    validate_present! id

    child_to_parents[id].map { |node_id| nodes[node_id] }
  end

  def children_of(id)
    validate_present! id

    parent_to_children[id].map { |node_id| nodes[node_id] }
  end

  def ancestors_of(id)
    validate_present! id

    ancestors_cache[id] ||= parents_of(id).flat_map do |parent|
      ancestors_of(parent.id) + [parent]
    end.uniq(&:id)
  end

  def descendants_of(id)
    validate_present! id

    children_of(id).flat_map do |child|
      [child] + descendants_of(child.id)
    end.uniq(&:id)
  end

  def subgraph_of(ids)
    ids.each { |id| validate_present! id }

    HierarchicalGraph.new.tap do |subgraph|
      ids.each do |id|
        subgraph.add_node id, nodes[id].data
      end

      subgraph.each do |node|
        children_of(node.id).each do |child|
          subgraph.add_relation parent_id: node.id, child_id: child.id unless subgraph[child.id].nil?
        end
      end
    end
  end

  def descendants_subgraph_from(id)
    subgraph_of [id] + descendants_of(id).map(&:id)
  end

  def to_s
    "<#{self.class.name} nodes:[#{map(&:to_s).join(', ')}]>"
  end
  alias_method :inspect, :to_s

  private

  attr_reader :nodes, :parent_to_children, :child_to_parents, :ancestors_cache, :descendants_cache

  def validate_present!(*ids)
    invalid_ids = ids.reject { |id| nodes.key? id }
    raise "Nodes not found: #{invalid_ids.join(', ')}" if invalid_ids.any?
  end

  def validate_not_present!(*ids)
    invalid_ids = ids.select { |id| nodes.key? id }
    raise "Nodes already exist: #{invalid_ids.join(', ')}" if invalid_ids.any?
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