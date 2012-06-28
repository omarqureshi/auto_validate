ActiveRecord::Base.establish_connection(:adapter  => ENV["DATABASE"] || "postgresql",
                                        :database => "auto_validate")
