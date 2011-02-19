namespace :sem4r do
  #
  # examples
  #
  desc 'run all sem4r example'
  task :examples do

    Dir['examples_sem4r/*.rb'].sort.each do |filename|
      next unless filename =~ /\d\d.+\.rb$/
      unless system "ruby #{filename}"
        exit
      end
    end
    puts "All examples run successfull"

  end

  desc "Start an IRB shell"
  task :shell do
    sh 'IRBRC=`pwd`/config/irbrc.rb irb'
  end
end
