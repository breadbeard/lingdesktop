class RDF_Literal < Neo4j::Model

  property :value
  property :value_downcase
  property :lang
  property :created_at

  index :value, :type => :exact
  index :value_downcase, :type => :exact
  index :lang
  
  validates_presence_of :value
  validates_presence_of :lang
  validates_uniqueness_of :value, :scope => :lang
  
  before_save {|record| record.value_downcase = record.value.downcase}

  def to_hash(args = [])
    {:value => self.value, :lang => self.lang}
  end


  def self.find_or_create(args)
    RDF_Literal.find(args) || RDF_Literal.create(args)  
  end

end
