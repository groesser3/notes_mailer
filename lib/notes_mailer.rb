require 'mail'
require 'fileutils'
require 'log4r'

module Mail

  # == Sending Email with NotesMailer
  # 
  # NotesMailer allows you to send emails using IBM Lotus Notes. This is done by wrapping the Lotus Notes-win32ole-api.
  # The usage is very similar to the SMTP devlivery method in the mail gem.
  # 
  # require 'rubygems'
  # require 'notes_mailer'
  #
  # Mail.defaults do
  #    delivery_method Mail::NotesMailer, { :address              => "",
  #                              :user_name            => '<username>',
  #                              :password             => '<password>',
  #                              :db => '<database>'}
  # end
  #
  # === Delivering the email (from smtp.rb)
  # 
  # Once you have the settings right, sending the email is done by:
  # 
  #   Mail.deliver do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  # Or by calling deliver on a Mail message
  # 
  #   mail = Mail.new do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  # 
  #   mail.deliver!
  class Message
    alias old_initialize initialize
    attr_reader :files_to_attach
    def initialize(*args, &block)
      @files_to_attach = []
      old_initialize(*args, &block)
    end
    def add_file(filename)
      raise "Parameter must be a string" unless filename.is_a?String
      raise "File '#{filename}' does not exists" unless File.exists?(filename)
      @files_to_attach << filename
    end
  end

  class NotesMailer
    @@logger = nil
    # Provides a store of all the emails 
    def NotesMailer.deliveries
      @@deliveries ||= []
    end
    
    def NotesMailer.deliveries=(val)
      @@deliveries = val
    end

    # NotesMailer supports the following settings:
    # Mandatory: 
    #  :user_name  ... Lotus Notes user
    #  :db             ... Latus Notes database
    # Optional    
    #  :password   ... Latus Notes password
    #  :adress       ... Adress of your Lotus Notes Server, emty if you are using a local database 
    #  ::mock_win32ole => true     ... test without using Lotus Notes 
    #  :logger => true,                 ... use logger
    #  :debug => true                   ... 
    def initialize(values)
      self.settings = { :adress       => '', #server is localhost
                             :password => ''
                             }.merge(values)
                             
     
      #raise "Notes password missing" unless settings[:password]
      raise "Notes db missing" unless settings[:db]
      raise "Notes user_name missing" unless settings[:user_name]
      
      if settings[:mock_win32ole] 
        $LOAD_PATH.unshift File.dirname(__FILE__) + '/../test/mock/win32ole'
      end
      require 'win32ole'
      
      if settings[:logger] and !@@logger
        NotesMailer.init_logger(settings[:debug])
      end

      log_debug "--- settings --- "
      log_debug settings

      s = WIN32OLE.new 'Lotus.NotesSession'
      s.Initialize(settings[:password])
      
      @notes_db = s.GetDatabase(settings[:adress], settings[:db])
      raise "Cannot open #{settings[:db]}" unless @notes_db.IsOpen()

    end
    
    attr_accessor :settings

    def deliver!(mail)
      #Mail::NotesMailer.deliveries << mail
      
      destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
      if destinations.blank?
        raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message') 
      end
      
      log_debug "--- log mail ---"
      log_debug "destinations : "
      log_debug  destinations
      log_debug "mail to      : "
      log_debug mail.to
      log_debug "mail cc      : "
      log_debug mail.cc
      log_debug "mail bcc      : "
      log_debug mail.bcc
      log_debug "mail subject : "
      log_debug mail.subject
      log_debug "mail body    : " 
      log_debug mail.body.to_s 
      log_debug "--- end ---"
      
      new_mail = @notes_db.CreateDocument
      new_mail.replaceItemValue("Form",'Memo')
      new_mail.replaceItemValue("SendTo",mail.to) 
      new_mail.replaceItemValue("CopyTo",mail.cc) 
      new_mail.replaceItemValue("BlindCopyTo",mail.bcc) 
      new_mail.replaceItemValue("Subject",mail.subject)
      
      #new_mail.replaceItemValue("Body", mail.body.to_s)
      rti = new_mail.CreateRichTextItem("Body")
      rti.AppendText( mail.body.to_s)
      rti.AddNewLine()
      rti.AppendText( "\nfrom #{mail.from.to_s}\n") if mail.from.to_s.size > 0
      log_debug("\nfrom #{mail.from.to_s}\n") if mail.from.to_s.size > 0

      mail.files_to_attach.each do |filename|
        log_debug "attach: " + filename
        # EMBED_ATTACHMENT (1454), EMBED_OBJECT (1453), EMBED_OBJECTLINK (1452)
        rti.EmbedObject(1454,File.basename(filename),filename) # 1454 == EMBED_ATTACHMENT
      end      
      new_mail.Send(0) 
      
      self
    end
    
    def NotesMailer.init_logger(debug)
      FileUtils::mkdir_p("#{Dir.pwd}/log")
      @@logger = Log4r::Logger.new("notes_mailer_logger") 
      
      if debug
        puts "see logfile: #{Dir.pwd}/log/notes_mailer.log"
        log_level = Log4r::DEBUG
      else
        log_level = Log4r::INFO
      end
      
      Log4r::FileOutputter.new('logfile', 
                         :filename=>"#{Dir.pwd}/log/notes_mailer.log", 
                         :trunc=>false,
                         :level=> log_level)
                         
      @@logger.add('logfile')
    
    end
    def log_info(*args, &block)
      if @@logger
         @@logger.info(*args, &block)
      end
    end
    def log_debug(*args, &block)
      if @@logger
         p args
         @@logger.debug(*args, &block)
      end
    end
  
  end
end
