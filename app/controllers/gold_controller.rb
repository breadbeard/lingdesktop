##
# Gold Controller
#
class GoldController < ApplicationController

  def show
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    
    respond_to do |format|
      format.html #show.html.erb
      format.json do
        render :json => {
          :data => @resource.to_hash(
           "rdf:type" => {
             :first => true,
             :simple_value => :uri,
             :context => context},
           
           "rdfs:label" => {
             :first => true,
             :simple_value => :value,
             :context => context},
           
           "rdfs:comment" => {
             :first => true,
             :simple_value => :value,
             :context => context}),
             
           :success => true
         }
      end
    end
  end


  def subclasses
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    @subclasses = @resource.get_subjects(RDF::RDFS.subClassOf => {:context => context})

    respond_to do |format|
      format.html #subclasses.html.erb
      format.json do
        render :json => (@subclasses.collect do |sc|
          sc.to_hash(
           "rdf:type" => {
             :first => true, 
             :simple_value => :uri, 
             :context => context},
             
           "rdfs:label" => {
             :first => true, 
             :simple_value => :value, 
             :context => context},
             
           "text" => {
             :predicate => RDF::RDFS.label,
             :first => true, 
             :simple_value => :value, 
             :context => context},
             
           "leaf" => {
             :predicate => RDF::RDFS.subClassOf,
             :subjects => true, 
             :empty_xor => false, 
             :context => context})
        end)
      end
    end
  end


  def individuals
    @resource = RDF_Resource.find(:uri_esc => RDF::GOLD[params[:id]].uri_esc)
    @individuals = @resource.get_subjects(RDF.type => {:context => context})
    
    total = @individuals.length
    @individuals = @individuals[params[:start].to_i, params[:limit].to_i] if(params[:start] && params[:limit])
    
    respond_to do |format|
      format.html #individuals.html.erb
      format.json do 
        render :json => ({
          :data => (@individuals.collect do |ind|
            ind.to_hash(
              "rdf:type" => {
                :first => true, 
                :simple_value => :uri, 
                :context => context},
                
              "rdfs:label" => {
                :first => true, 
                :simple_value => :value, 
                :context => context},
                
              "rdfs:comment" => {
                :first => true, 
                :simple_value => :value,  
                :context => context})
          end),
          :total => total
        })
      end
    end
  end
end
