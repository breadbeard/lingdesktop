##
# Test Comment for Gold Controller
#
# @example Do something
#   Gold Controller
#
class GoldController < ApplicationController

  around_filter :neo4j_transaction, :only => [:show, :subclasses, :individuals]


  def show
    find_resource

    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => @resource.to_hash(
           :RDF_type => {:first => true, :args => {:localname => {}}},
           :RDFS_label => {:lang => @lang, :first => true, :in_contexts => @contexts},
           :RDFS_comment => {:lang => @lang, :in_contexts => @contexts})
           
      end
    end
  end


  def subclasses
    find_resource

    @subclasses = @resource.get_subjects(:RDFS_subClassOf => {:in_contexts => @contexts})

    respond_to do |format|
      format.html #subclasses.html.erb
      format.json do
        render :json => (@subclasses.collect do |sc|
          sc.to_hash(
           :RDF_type => {:first => true, :simple_value => :uri, :in_contexts => @contexts},
           :RDFS_label => {:lang => @lang, :first => true, :simple_value => :value, :in_contexts => @contexts},
           :RDFS_label => {:lang => @lang, :first => true, :rename => "text", :simple_value => :value, :in_contexts => @contexts},
           :RDFS_subClassOf => {:subjects => true, :boolean => false, :rename => "leaf", :in_contexts => @contexts},
           :localname => {})
        end)
      end
    end
  end


  def individuals
    find_resource
    
    @individuals = @resource.get_subjects(:RDF_type => {:in_contexts => @contexts})
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@individuals.collect do |ind|
            ind.to_hash(
              :RDF_type => {:first => true, :simple_value => :uri, :in_contexts => @contexts},
              :RDFS_label => {:lang => @lang, :first => true, :simple_value => :value, :in_contexts => @contexts},
              :RDFS_comment => {:first => true, :simple_value => :value, :lang => @lang, :in_contexts => @contexts},
              :localname => {})
          end),
          :total => @individuals.length
        })
      end
    end
  end


  private

  def find_resource
    gold_ns = RDF::Vocabulary.new("http://purl.org/linguistics/gold/")
    @resource = RDF_Resource.find(:uri => gold_ns[params[:id]].to_s).first

    if !@resource then
      respond_to do |format|
        format.html #error.html.erb
        format.json do
          render :json => {:error => "Resource '#{params[:id]}' not found."}
        end
      end
    end
  end


  def init_contexts
    @lang = "en"
    @contexts = [CTX_Context.find(:uri => "http://purl.org/linguistics/gold").first]
  end


  def neo4j_transaction
    Neo4j::Transaction.new
      init_contexts
      yield
    Neo4j::Transaction.finish
  end

end
