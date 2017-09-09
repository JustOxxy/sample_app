class Family
  attr_accessor :first, :last

  def initialize(person1 = {})
    @first = person1[:first]
    @last = person1[:last]

    params = {}
    params[:father] = person1
    puts params[:father][:first]
  end

end
#
# fam = Family.new
# fam.first = "hey"
# fam.last = "bro"
# f
#
# my_hash = {
#     "name" => "Eric",
#     "age" => 26,
#     "hungry?" => true
# }
#
# puts my_hash["name"]
# puts my_hash["age"]
# puts my_hash["hungry?"]