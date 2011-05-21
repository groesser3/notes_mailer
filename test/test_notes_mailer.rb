$:.unshift '../lib'

require 'rubygems'
require 'notes_mailer'

Mail.defaults do
  delivery_method Mail::NotesMailer, { :adress              => "",  # local database
                                :db         => 'notes_db.nsf',
                                :user_name       => 'myname',
                                :password         => '', 
                                #:mock_win32ole =>  true,   # test without using Lotus Notes 
                                #:logger => true,
                                #:debug => true
                                }

end

Mail.deliver do
  to 'user@test.com'
  from 'you@test.com'
  subject 'test'
  body 'hello'
  add_file File.join(Dir.pwd, 'test_notes_mailer.rb')
  
end

