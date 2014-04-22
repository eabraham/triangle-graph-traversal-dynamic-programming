require 'ruby-prof'

class TriangleNode
    #this node has special propertie, its parents are the two
    #nodes up one level and adjacent.  Its children are the two
    #node down one level and adjacent
    #i.e.             1
    #                2 3
    #               4 5 6
    #              7 8 9 10
    #the node with value 5 has parents 2 + 3 and children 8 + 9.

    attr_accessor :value, :index, :level, :parentNodes

    def initialize(value, index, level)
      @value = value
      @index = index
      @level = level
      @parentNodes = []
    end

    def addParentNode(node)
      #check if node is a valid parent
      if validParentNode(node)
	@parentNodes << node
      end
    end
private
    def validParentNode(node)
      pIndex = node.index
      pLevel = node.level

      if @level==pLevel+1 && (@index==(pIndex+@level) || @index==(pIndex+@level+1))
	return true
      else
        #puts "(index:#{pIndex} level:#{pLevel}) - Not a valid parent node"
        return false
      end
    end
end

class Triangle

  attr_accessor :rootNode, :paths, :partialSolutions

  def initialize(triangleFile)
    #load triangle file into triangle graph
    file = File.open(triangleFile,"r")
    level = 0
    previousLevelNodes = []
    file.each_line do |line|
      values = line.split(' ')
      firstIndexAtLevel = (0..level).reduce{|a,b| a+b}+1
      currentLevelNodes = []
      values.each_with_index do |value,index|
        t=TriangleNode.new(value.to_i,firstIndexAtLevel + index,level)
	currentLevelNodes.push(t)
	if level>0
          previousLevelNodes.each do |node|
            t.addParentNode(node)
	  end
	else
	  @rootNode=t
	end
      end
      previousLevelNodes=currentLevelNodes.dup
      level =level +1
    end

    #interate over each of the leaf nodes and find the largest sum path
    @partialSolutions={}
    previousLevelNodes.each do |node|
      findLargestPath(node,[])
    end

    #iterate over each nodes solution to find the path with the max sum
    maxPath = []
    maxSum =0
    @partialSolutions.keys.each do |sol|
      @partialSolutions[sol].each do |s|
        sum=s.reduce {|a,b| a+b}
        if sum>maxSum
          maxSum=sum
          maxPath=s
        end
      end
    end
    puts "Max Sum:#{maxSum} Max Path:#{maxPath}"    
  end
  def findLargestPath(node, currentPath)
    #recursive method to navigate Triangle graph
    path = currentPath.push(node.value)
    nodeSolutions = []
    if node==@rootNode
      #Found the root node
      nodeSolutions = [[node.value]]
    elsif @partialSolutions[node.index]
      #Found node with optimal path already calculated
      nodeSolutions=@partialSolutions[node.index]
    else
      #Found node that needs its optimal path calculated
      node.parentNodes.each do |parentNode|
        findLargestPath(parentNode,path.dup)
        nodeSolutions.concat(@partialSolutions[parentNode.index])
      end
      nodeSolutions.map!{|a| [node.value].concat(a)}
    end
    #only pass on most efficient route for node
    maxPath = maxSumPath(nodeSolutions)
    @partialSolutions.merge!({node.index => [maxPath]})
    return
  end

  def maxSumPath(nodeSolutions)
    #inputs: nodeSolutions is an array of node paths from the current node to root
    #outputs: maxPath is the path with the greatest sum from the current node to root
    maxPath =[]
    maxSum = 0
    nodeSolutions.each do |sol|
      sum=sol.reduce {|a,b| a+b}
      if maxSum<sum
        maxSum=sum
        maxPath=sol
      end
    end
    return maxPath
  end
end



if __FILE__ == $0 
  Triangle.new("./triangle.txt")
end
