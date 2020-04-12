# HierarchicalGraph

[![Gem Version](https://badge.fury.io/rb/hierarchical_graph.svg)](https://rubygems.org/gems/hierarchical_graph)
[![Build Status](https://travis-ci.org/gabynaiman/hierarchical_graph.svg?branch=master)](https://travis-ci.org/gabynaiman/hierarchical_graph)
[![Coverage Status](https://coveralls.io/repos/github/gabynaiman/hierarchical_graph/badge.svg?branch=master)](https://coveralls.io/github/gabynaiman/hierarchical_graph?branch=master)
[![Code Climate](https://codeclimate.com/github/gabynaiman/hierarchical_graph.svg)](https://codeclimate.com/github/gabynaiman/hierarchical_graph)

Hierarchical graph representation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hierarchical_graph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hierarchical_graph

## Usage

### Build graph
```ruby
graph = HierarchicalGraph.new

graph.add_node 1, name: 'Node 1', other: 1000
graph.add_node 2
graph.add_node 3

graph.add_relation parent_id: 1, child_id: 2
graph.add_relation parent_id: 2, child_id: 3
```

### Navigate graph
```ruby
graph[1] # <Node 1>
graph.roots # [<Node 1>, <Node 2>]
graph.parents_of(3) # [<Node 2>]
graph.ancestors_of(3) # [<Node 1>, <Node 2>]
graph.children_of(1) # [<Node 2>]
graph.descendants_of(1) # [<Node 2>, <Node 3>]
```

### Node
```ruby
node = graph[node_id]

node.id # node_id
node.root? # true/false

node.data # {key_1: val_1, key_2: val_2}
node.data[:key_1] # val_1
node.data[:key_3] = val_3
node[:key_1] # val_1
node[:key_3] = val_3

node.parents # [<Node>, ...]
node.ancestors # [<Node>, ...]
node.children # [<Node>, ...]
node.descendants # [<Node>, ...]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabynaiman/hierarchical_graph.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
