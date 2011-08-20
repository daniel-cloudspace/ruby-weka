require 'rjb'

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
Rjb::load(dir, jvmargs=["-Xmx1000m"])

#load the data using Java and Weka
fanfics_src = Rjb::import("java.io.File").new("fanfics.csv")
fanfics_csvloader = Rjb::import("weka.core.converters.CSVLoader").new
fanfics_csvloader.setFile(fanfics_src)
fanfics_data = fanfics_csvloader.getDataSet

# StringToWordVector
nts = Rjb::import("weka.filters.unsupervised.attribute.NominalToString").new
nts.setOptions ['-C last']



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
