

class TriangleNode
    #this node has special propertie, its parents are the two
    #nodes up one level and adjacent.  Its children are the two
    #node down one level and adjacent
    #i.e.             1
    #                2 3
    #               4 5 6
    #              7 8 9 10
    #the node with value 5 has parents 2 + 3 and children 8 + 9.

    attr_accessor :value, :index, :level, :parentNodes, :childNodes

    def initialize(value, index, level)
      @value = value
      @index = index
      @level = level
      @childNodes = []
      @parentNodes = []
    end

    def addParentNode(node)
      #check if node is a valid parent
      if validParentNode(node)
	@parentNodes << node
	node.addChildNode(self)
      end
    end

    def addChildNode(node)
      #check if node is a valid child
      childNodeIndex = node.index
      if validChildNode(node)
        @childNodes << node
      end
    end
private
    def validChildNode(node)
      cIndex = node.index
      cLevel = node.level

      if cLevel==@level-1 && (cIndex==(@index-level) || cIndex==(@index-level-1))
        #child's level is one less than parent and its index must be the parents index
        #minus the parents level - 0 and - 1
        return true
      else
    	#puts "(index:#{cIndex} level:#{cLevel}) - Not a valid child node"
        return false
      end
    end
    
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

  attr_accessor :rootNode, :paths

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
    @tCount=0
    @paths=[]
    previousLevelNodes.each do |node|
      findLargestPath(node,[])
    end
    #puts @paths
    #puts @paths.map{|a| a.count}
    #puts @paths.select{|a| a.count==level-1}
    @paths.each {|a| puts a.reduce{|b,c| "#{b} #{c}"}}
    maxPath = []
    maxSum =0
    @paths.each do |path|
      sum=path.reduce {|a,b| a+b}
      if sum>maxSum
	maxSum=sum
	maxPath = path
      end
    end
    puts "Max Sum:#{maxSum} Max Path:#{maxPath}"
    puts @tCount
  end
  def findLargestPath(node, currentPath)
    path = currentPath.push(node.value)
    if node==@rootNode
      @paths.push(path)
      #puts "Sum:#{path.reduce{|a,b| a+b}} Node Count:#{path.count==100} Total Paths:#{@paths.count}"
    end
    #puts "Parent count: #{node.parentNodes.count} Parents:#{node.parentNodes.map{|a| a.value}} Nodes: #{path}"
    node.parentNodes.each do |parentNode|
      findLargestPath(parentNode,path.dup)
    end
    @tCount=@tCount+1
  end
end

if __FILE__ == $0 
  Triangle.new("./mini_triangle.txt")
end
