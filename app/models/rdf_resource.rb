class RDF_Resource < Neo4jNode

  property :uri

  index :uri

  def self.find_or_create(uri)
    return RDF_Resource.find(:uri => uri).first || RDF_Resource.new(:uri => uri)
  end

  def to_hash(args = [])
    resource_hash = {:uri => self.uri}

    args.each do |predicate_and_args|
      predicate, args = predicate_and_args
      result = nil
      
      # handle local values
      if predicate == :localname then
        result = self.uri.gsub(/([^\/]*\/|[^#]*#)/, "")

      # traverse subject or objects
      else
        result = (args[:subjects] ? self.get_subjects(predicate => args) : self.get_objects(predicate => args))
      end

      #set the name or rename the key of the hash
      name = args[:rename] || predicate

      # handle array result
      if result.kind_of?(Array) then
        resource_hash.merge!({name => result.collect{|r| r.to_hash(args[:args])}})

      # handle boolean result
      elsif result.kind_of?(TrueClass) || result.kind_of?(FalseClass) then
        resource_hash.merge!({name => result})

      # handle string result
      elsif result.kind_of?(String) then
        resource_hash.merge!({name => result})

      # handle rdf result
      elsif !result.nil?
        resource_hash.merge!({name => result.to_hash(args[:args])})
      end
    end

    return resource_hash
  end
  
  def get_subjects(predicate_and_args)
    predicate, args = predicate_and_args.first
    
    #collect subjects
    result = CTX_Statement.find([nil, predicate, self], args[:in_contexts]).collect do |st| 
      st.subject
    end
    
    #process
    self.process_args(result, args)
  end

  def get_objects(predicate_and_args)
    predicate, args = predicate_and_args.first
    
    #collect objects
    result = CTX_Statement.find([self, predicate, nil], args[:in_contexts]).collect do |st| 
      st.object
    end
    
    
    #process
    self.process_args(result, args)
  end
  
  def process_args(result, args)

    #filter by lang
    if args.has_key?(:lang) then
      result = result.delete_if{|node| !node.property?("lang") || (node.lang != args[:lang])}
    end

    #filter simple values
    if args.has_key?(:simple_value) then
      result = result.delete_if do |node| 
        !node.property?(args[:simple_value].to_s)
      end
      result = result.collect{|node| node[args[:simple_value]]}
    end
    
    #filter first
    if args.has_key?(:first) then
      result = result.first

    #filter boolean
    elsif args.has_key?(:boolean) then
      result = (result.empty? ^ args[:boolean])
    end

    return result
  end

end