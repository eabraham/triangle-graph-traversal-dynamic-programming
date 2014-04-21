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

    @tCount=0
    @partialSolutions={}
    @paths=[]
    previousLevelNodes.each do |node|
      findLargestPath(node,[])
    end
    #puts @paths
    #puts @paths.map{|a| a.count}
    #puts @paths.select{|a| a.count==level-1}
    maxPath = []
    maxSum =0
    puts "zTraversal count #{@tCount}"
    @partialSolutions.keys.each do |sol|
      #if @partialSolutions[sol].size==level-1
	#@partialSolutions[sol].reduce{|a,b| puts "#{a} #{b}"}
	@partialSolutions[sol].each do |s|
          sum=s.reduce {|a,b| a+b}
	  if sum>maxSum
	    maxSum=sum
	    maxPath=s
	  end
	end
      #end
    end
    puts "Max Sum:#{maxSum} Max Path:#{maxPath}"    
  end
  def findLargestPath(node, currentPath)
    if !RubyProf.running?
      RubyProf.start
    end
    path = currentPath.push(node.value)
    nodeSol = []
    puts "Value:#{node.value} Index:#{node.index}"
    if node==@rootNode
      puts "Root found start"
      result = RubyProf.stop
      printer = RubyProf::GraphPrinter.new(result)
      printer.print(STDOUT, {})
      puts "Root found stop"
      return [[node.value]]

      #@paths.push(path)
      #puts "Sum:#{path.reduce{|a,b| a+b}} Node Count:#{path.count==100} Total Paths:#{@paths.count}"
    end
    #puts "Parent count: #{node.parentNodes.count} Parents:#{node.parentNodes.map{|a| a.value}} Nodes: #{path}"
    puts "check is there is a partial solution"
    if @partialSolutions[node.index]
      nodeSol=@partialSolutions[node.index]
      puts "#{node.value} Partial Solution Found at index #{node.index}"
    else
      node.parentNodes.each do |parentNode|
        nodeSol.concat(findLargestPath(parentNode,path.dup))
	#puts "#{node.value} results from parent #{nodeSol}"
      end
      nodeSol.map!{|a| [node.value].concat(a)}
      puts "#{node.value} No partial solution found go deeper at index #{node.index}"
    end
    puts "Merging soution start"
    @partialSolutions.merge!({node.index => nodeSol})
    puts "Merging solution complete"
    @tCount=@tCount+1
    puts "Partial Solution count:#{@partialSolutions.count}"
    puts "Sol Count: #{nodeSol}"
    return nodeSol
  end
end

if __FILE__ == $0 
  Triangle.new("./med_triangle.txt")
end
