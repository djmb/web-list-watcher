watch( 'test/([^/]+/)*test_.*\.rb' )  {|md| system("ruby #{md[0]}") }
watch( 'lib/([^/]+/)*(.*)\.rb' )      {|md| system("ruby test/#{md[1]}test_#{md[2]}.rb") }