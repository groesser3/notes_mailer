require 'log4r'
require 'fileutils'

# mock
class NotesValues
  def initialize(arr=[])
    @arr=arr
  end
  def Values
    @arr
  end
end

class NotesDocument
    attr_accessor :uid, :deleted, :notes_values
    def initialize
      @deleted = false
      @notes_values = {}
    end
    def UniversalID
       return @uid
    end
    def GetFirstItem(key)
      @notes_values[key]
    end
    def LastModified
      '2009-12-02T16:01:21+00:00'
    end
    def IsDeleted
      @deleted
    end
    def replaceItemValue(key, value)
      @notes_values[key] = value
    end
    def Send(para)
    
    end
    def CreateRichTextItem(name)
      CreateRichTextItem.new(name)
    end
end

class CreateRichTextItem
  def initialize(name)
  end
  def AppendText(text)
  end
  def AddNewLine()
  end
  def EmbedObject(type, name, filename)
  end
end

class NotesView
  def initialize
    @cursor = -1
    @elements = []    
  end
  
  def GetLastDocument
    if @elements.size == 0
      return false
    else
      @cursor = @elements.size-1
      return @elements[@cursor]
    end
  end
  def GetPrevDocument(entry)
    @cursor -= 1
    if @cursor < 0
      return false
    else
      return @elements[@cursor]
    end
  end
end

class NotesDB
  def initialize(db)
  end
  def GetView(view)
    NotesView.new
  end
  def isOpen
    true
  end
  def CreateDocument
    NotesDocument.new
  end
end


class WIN32OLE # NotesSession
  def initialize(app)
  end
  def Initialize(pwd)
  end
  def GetDatabase(server, db)
    NotesDB.new(db)
  end
  def WIN32OLE.init_logger
    FileUtils::mkdir_p("#{Dir.pwd}/log")
    @@logger = Log4r::Logger.new("win32ole_logger")      
    Log4r::FileOutputter.new('win32ole_log', 
                         :filename=>"#{Dir.pwd}/log/win32ole.log", 
                         :trunc=>false,
                         :level=>Log4r::INFO)
    @@logger.add('win32ole_log')
  end
  WIN32OLE.init_logger

end
