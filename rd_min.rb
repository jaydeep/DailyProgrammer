  def createAlphaHash
    @alphaHash = {}

    ('A'..'Z').to_a.each_with_index do |letter, index|
      @alphaHash[index] = letter
    end
    @alphaHash
  end

  # parse the input, and create the matrix
  def importMatrix
    num_vertices = gets.chomp!.to_i
    matrix = []

    num_vertices.times do |x| 
      matrix << gets.chomp!.split(',').map(&:to_i)
    end

    p matrix
  end

  #given the matrix as an input, create a nested hash of edges and 
  #a list in decreasing order of which edges to attack first
  def listEdges(matrix)
    edges = {}
    hitList = {}

    matrix.each_with_index do |line, i|
      aI = @alphaHash[i]
      line.each_with_index do |node, j|
        dist = matrix[i][j]
        aJ = @alphaHash[j]
        if dist != -1
          edge = (i < j ? "#{aI}#{aJ}" : "#{aJ}#{aI}")
          edges[aI] = {} if edges[aI].nil?
          edges[aJ] = {} if edges[aJ].nil?
          edges[aI][aJ] = dist
          edges[aJ][aI] = dist
          hitList[edge] = dist
        end
      end
    end

    hitList = Hash[hitList.sort_by {|k,v| v*-1}]
    [edges,hitList]
  end

  #given the nested hash and hitlist, iterate over the list and check if deleting
  #an edge results in a broken connection or not
  def reverse_delete(result)
    edges = result[0]
    hitList = result[1]

    hitList.each do |k, dist|
      edges[k[0]].delete(k[-1])
      edges[k[-1]].delete(k[0])

      unless path_exists?(edges, k[0], k[-1]) #check if connection still path
        p "path does not exist, reconnecting #{k[0]} to #{k[-1]} "
        edges[k[0]][k[-1]] = dist
        edges[k[-1]][k[0]] = dist
      end
    end

    edges
  end

  #this implements a breadth first search to ensure that the connection between
  #two vertices still exists
  def path_exists?(edges, start, finish) 
    nodes = edges[start].keys
    touchedNodes = nodes + [start]
    newNodes = nodes

    until newNodes.length == 0
      return true  if touchedNodes.include?(finish)
      newNodes = []
      nodes.each do |node|
        newNodes += edges[node].keys - touchedNodes
      end
      touchedNodes += newNodes
      nodes = newNodes
    end
    false
  end

  #prints the distance of the MST and the edges that remain
  def printResult(edges)
    sum = 0
    graph = []
    edges.each do |k,v|
      edges[k].each do |key,value|
        sum += value
        graph << "#{k}#{key}"
        edges[key].delete(k)
      end
    end
    p sum
    p graph
  end

  def run
    createAlphaHash
    matrix = importMatrix
    result = listEdges(matrix)
    edges = reverse_delete(result)
    printResult(edges)
  end
  run