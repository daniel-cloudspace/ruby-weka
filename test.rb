require 'rjb'

Loader to use:
  weka.core.converters.CSVLoader
Filters to use:
  weka.filters.unsupervised.attribute.NominalToString -C last
  weka.filters.unsupervised.attribute.StringToWordVector -R first-last -W 1000 -prune-rate -1.0 -N 0 -L -S -stemmer weka.core.stemmers.NullStemmer -M 2 -stopwords /Users/daniellewis/stopwords.txt -tokenizer "weka.core.tokenizers.NGramTokenizer -delimiters \" \\r\\n\\t.,;:\\\'\\\"()?!\" -max 3 -min 1"
  weka.filters.unsupervised.attribute.NumericToNominal -R first-last
Attribute Selector to use:
  weka.attributeSelection.LatentSemanticAnalysis -R 0.95 -A 5
  weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1


def kmeans()
  #Load Java Jar
  dir = "./weka.jar"

  #Have Rjb load the jar file, and pass Java command line arguments
  Rjb::load(dir, jvmargs=["-Xmx1000m"])

  #make k-means classifier
  obj = Rjb::import("weka.clusterers.SimpleKMeans")
  kmeans = obj.new

  #load the data using Java and Weka
  labor_src = Rjb::import("java.io.FileReader").new("sponge.arff")
  labor_data = Rjb::import("weka.core.Instances").new(labor_src)

  #build the cluster and output the k-means data
  kmeans.buildClusterer(labor_data)
  puts kmeans.toString

  #examine the particular datapoints
  points = labor_data.numInstances

  points.times do |instance|
    cluster = kmeans.clusterInstance(labor_data.instance(instance))
    point = labor_data.instance(instance).toString
    puts "#{point} \t #{cluster}"
  end
end
