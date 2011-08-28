require 'rjb'

# A lot of help from the Using Weka in Java resources:
# * http://weka.wikispaces.com/Use+WEKA+in+your+Java+code
# *

#Loader to use:
#  weka.core.converters.CSVLoader
#Filters to use:
#  weka.filters.unsupervised.attribute.NominalToString -C last
#  weka.filters.unsupervised.attribute.StringToWordVector -R first-last -W 1000 -prune-rate -1.0 -N 0 -L -S -stemmer weka.core.stemmers.NullStemmer -M 2 -stopwords /Users/daniellewis/stopwords.txt -tokenizer "weka.core.tokenizers.NGramTokenizer -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?!\" -max 3 -min 1"
#  weka.filters.unsupervised.attribute.NumericToNominal -R first-last
#Attribute Selector to use:
#  weka.attributeSelection.LatentSemanticAnalysis -R 0.95 -A 5
#  weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1


#Load Java Jar
dir = "./weka.jar"

#Have Rjb load the jar file, and pass Java command line arguments
Rjb::load(dir, jvmargs=["-Xmx1500m"])

# loading some java classes
Filter = Rjb::import("weka.filters.Filter")
NullStemmer = Rjb::import("weka.core.stemmers.NullStemmer")
WordTokenizer = Rjb::import("weka.core.tokenizers.WordTokenizer")
AttributeSelection = Rjb::import("weka.filters.supervised.attribute.AttributeSelection")

#load the data using Java and Weka
fanfics_src = Rjb::import("java.io.File").new(ARGV[0])
fanfics_csvloader = Rjb::import("weka.core.converters.CSVLoader").new
fanfics_csvloader.setFile(fanfics_src)
fanfics_data = fanfics_csvloader.getDataSet

# NominalToString
nts = Rjb::import("weka.filters.unsupervised.attribute.NominalToString").new
nts.setOptions '-C last'.split(' ')
nts.setInputFormat(fanfics_data)
fanfics_data = Filter.useFilter(fanfics_data, nts)

# Stemmer
nullstemmer = Rjb::import("weka.core.stemmers.NullStemmer").new

# Tokenizer
wordtokenizer = Rjb::import("weka.core.tokenizers.WordTokenizer").new
wordtokenizer.setOptions ["-delimiters", "\" \\r\\n\\t.,;:\\\'\\\"()?!\""]

# StringToWordVector
stwv = Rjb::import("weka.filters.unsupervised.attribute.StringToWordVector").new
stwv.setOptions '-R first-last -W 1000 -prune-rate -1.0 -N 0 -L -M 3 -stopwords /Users/daniellewis/ruby-weka/stopwords.txt"'.split(' ')
stwv.setStemmer nullstemmer
stwv.setTokenizer wordtokenizer
stwv.setInputFormat(fanfics_data)
fanfics_data = Filter.useFilter(fanfics_data, stwv)

# NumericToNominal
ntn = Rjb::import("weka.filters.unsupervised.attribute.NumericToNominal").new
ntn.setInputFormat(fanfics_data)
fanfics_data = Filter.useFilter(fanfics_data, ntn)

# Generate a classifier for each index
puts "Generating trees"
#(0..fanfics_data.numAttributes).each do |i|
#  # ADTree
#  adtree = Rjb::import("weka.classifiers.trees.ADTree").new
#  adtree.setOptions '-B 10 -E -3'.split(' ')
#  fanfics_data.setClassIndex(i)
#  adtree.buildClassifier fanfics_data
#  
#  # Write out to a dot file
#  classname = fanfics_data.classAttribute.toString.split(' ')[1]
#  graph = adtree.graph.gsub(/digraph ADTree {/, "digraph ADTree {\n#{classname}")
#  File.open('dots/'+classname+'.dot', 'w') { |f| f.write(graph) }
#  `dot -Tgif < dots/#{classname}.dot > gifs/#{classname}.gif`
#
#  puts "Generated tree for #{classname}"
#end

# Attribute Selection
attsel = Rjb::import('weka.attributeSelection.AttributeSelection').new

# Attribute Evaluator
#cfssubseteval = Rjb::import('weka.attributeSelection.CfsSubsetEval').new
lsa = Rjb::import('weka.attributeSelection.LatentSemanticAnalysis').new
lsa.setOptions '-R 0.95 -A 1000'.split(' ')

# Search Method
#greedysearch = Rjb::import('weka.attributeSelection.GreedyStepwise').new
#greedysearch.setOptions '-T -1.7976931348623157E308 -N -1'.split(' ')
#greedysearch.setSearchBackwards true
ranker = Rjb::import('weka.attributeSelection.Ranker').new
ranker.setOptions '-T -1.7976931348623157E308 -N -1'.split(' ')

# Run 'em
#attsel.setEvaluator(cfssubseteval)
attsel.setEvaluator(lsa)
#attsel.setSearch(greedysearch)
attsel.setSearch(ranker)
#attsel.SelectAttributes(fanfics_data)
attsel.SelectAttributes(fanfics_data)

fanfics_data = attsel.reduceDimensionality(fanfics_data)
topics = fanfics_data.toString.scan(/^@.*/)
topics[1..-1].each_with_index do |topic, i|
  words = topic.gsub(/^@attribute '/,'').gsub(/ numeric$/,'').gsub('+','').scan(/(-?[0-9\.]+)([^-0-9\.]+)/).collect{|a,b| [a.to_f, b]}.sort{|a,b| b[0]<=>a[0]}
  print "Topic ##{i}:   "
  words[0..5].each {|w| print "#{w[1]} "}
  puts ''
end
#selected_attributes.each do |i|
#  puts fanfics_data.attribute(i).name
#end





#
##build the cluster and output the k-means data
#kmeans.buildClusterer(fanfics_data)
#puts kmeans.toString
#
##examine the particular datapoints
#points = fanfics_data.numInstances
#
#points.times do |instance|
#  cluster = kmeans.clusterInstance(fanfics_data.instance(instance))
#  point = fanfics_data.instance(instance).toString
##  puts "#{point} \t #{cluster}"
#end
