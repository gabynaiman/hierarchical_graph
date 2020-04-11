require 'minitest_helper'

describe HierarchicalGraph do

  it 'Empty graph' do
    graph = HierarchicalGraph.new

    graph.nodes.must_be_empty
  end

  it 'Add node' do
    graph = HierarchicalGraph.new
    
    node = graph.add_node 1

    graph[1].must_equal node
    graph.nodes.count.must_equal 1
  end

  it 'Remove node' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    
    graph.remove_node 1

    graph[1].must_be_nil
    graph.nodes.must_be_empty
  end

  it 'Remove invalid node' do
    graph = HierarchicalGraph.new
    
    error = proc { graph.remove_node 1 }.must_raise RuntimeError
    error.message.must_equal "Invalid nodes: 1"
  end

  it 'Add relation' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    
    graph.add_relation parent_id: 1, child_id: 2

    graph.parents_of(1).must_be_empty
    graph.children_of(1).map(&:id).must_equal [2]

    graph.parents_of(2).map(&:id).must_equal [1]
    graph.children_of(2).must_be_empty
  end

  it 'Add relation with invalid nodes' do
    graph = HierarchicalGraph.new
    
    error = proc { graph.add_relation parent_id: 1, child_id: 2 }.must_raise RuntimeError
    error.message.must_equal "Invalid nodes: 1, 2"
  end

  it 'Remove relation' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2

    graph.add_relation parent_id: 1, child_id: 2
    graph.children_of(1).count.must_equal 1

    graph.remove_relation parent_id: 1, child_id: 2
    graph.children_of(1).must_be_empty
    graph.nodes.count 2
  end

  it 'Remove relation in complex graph' do
    graph = HierarchicalGraph.new
    
    graph.add_node 0
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_node 5
    graph.add_node 6
    graph.add_node 7

    graph.add_relation parent_id: 0, child_id: 3
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 3, child_id: 4
    graph.add_relation parent_id: 3, child_id: 5
    graph.add_relation parent_id: 2, child_id: 4
    graph.add_relation parent_id: 4, child_id: 5
    graph.add_relation parent_id: 4, child_id: 6
    graph.add_relation parent_id: 6, child_id: 7

    graph.remove_node 3

    graph.ancestors_of(4).map(&:id).must_equal [1, 2]
    graph.parents_of(4).map(&:id).must_equal [2]
    graph.children_of(4).map(&:id).must_equal [5, 6]
    graph.descendants_of(4).map(&:id).must_equal [5, 6, 7]
  end

  it 'Remove relation of invalid nodes' do
    graph = HierarchicalGraph.new

    error = proc { graph.remove_relation parent_id: 1, child_id: 2 }.must_raise RuntimeError
    error.message.must_equal "Invalid nodes: 1, 2"
  end

  it 'Roots' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4

    graph.roots.map(&:id).must_equal [1, 2, 3, 4]

    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 2, child_id: 4

    graph.roots.map(&:id).must_equal [1, 2]
  end

  it 'Children' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.children_of(1).map(&:id).must_equal [2, 3]
    graph.children_of(3).map(&:id).must_equal [4]
  end

  it 'Parents' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.parents_of(2).map(&:id).must_equal [1]
    graph.parents_of(4).map(&:id).must_equal [3]
  end

  it 'Ancestors' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.ancestors_of(4).map(&:id).must_equal [1, 3]
  end

  it 'Clear ancestors Cache' do
    graph = HierarchicalGraph.new
    graph.add_node 0
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.ancestors_of(4).map(&:id).must_equal [1, 3]

    graph.add_relation parent_id: 0, child_id: 1

    graph.ancestors_of(4).map(&:id).must_equal [0, 1, 3]
  end

  it 'Descendants' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.descendants_of(1).map(&:id).must_equal [2, 3, 4]
  end

  it 'Clear descendants Cache' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_node 5
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.descendants_of(1).map(&:id).must_equal [2, 3, 4]

    graph.add_relation parent_id: 4, child_id: 5

    graph.descendants_of(1).map(&:id).must_equal [2, 3, 4, 5]
  end

  it 'Topological sort' do
    graph = HierarchicalGraph.new
    graph.add_node 1
    graph.add_node 2
    graph.add_node 3
    graph.add_node 4
    graph.add_relation parent_id: 1, child_id: 2
    graph.add_relation parent_id: 1, child_id: 3
    graph.add_relation parent_id: 3, child_id: 4

    graph.tsort.map(&:id).must_equal [2, 4, 3, 1]
  end

  describe 'Node' do

    let :graph do
      HierarchicalGraph.new.tap do |graph|
        graph.add_node 1, name: 'Node 1', code: 'node_1'
        graph.add_node 2
        graph.add_node 3
        graph.add_node 4
        graph.add_node 5
        graph.add_node 6
        graph.add_relation parent_id: 1, child_id: 2
        graph.add_relation parent_id: 1, child_id: 3
        graph.add_relation parent_id: 3, child_id: 4
        graph.add_relation parent_id: 4, child_id: 5
        graph.add_relation parent_id: 6, child_id: 4
      end
    end

    it 'Root' do
      graph[1].must_be :root?
      graph[2].wont_be :root?
    end

    it 'Parents' do
      graph[1].parents.must_be_empty
      graph[4].parents.map(&:id).must_equal [3, 6]
    end

    it 'Children' do
      graph[5].children.must_be_empty
      graph[1].children.map(&:id).must_equal [2, 3]
    end

    it 'Ancestors' do
      graph[6].ancestors.must_be_empty
      graph[4].ancestors.map(&:id).must_equal [1, 3, 6]
    end

    it 'Descendants' do
      graph[5].descendants.must_be_empty
      graph[1].descendants.map(&:id).must_equal [2, 3, 4, 5]
    end

    it 'Get data' do
      graph[1].data.must_equal name: 'Node 1', code: 'node_1'
      graph[1][:name].must_equal 'Node 1'
      graph[1][:code].must_equal 'node_1'
    end

    it 'Set data' do
      node = graph[2]
      node.data[:name] = 'Node 2'
      node[:code] = 'node_2'

      graph[2].data.must_equal name: 'Node 2', code: 'node_2'
      graph[2][:name].must_equal 'Node 2'
      graph[2][:code].must_equal 'node_2'
    end

  end

end