##TODO: put this onto string?
module CamelCase
  #CamelCase
  def cc(str)
    str=str.gsub(/[^a-zA-Z ]/," ")
    str = " " + str.split.join(" ") #remove duplicate spaces?
    str.gsub(/ (.)/) { $1.upcase }
  end
end