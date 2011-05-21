require "rubygems"

spec = Gem::Specification.new do |s|
  s.name = %q{notes_mailer}
  s.version = "0.0.1"
  s.authors = ["Elias Kugler"]
  s.email = %q{groesser3@gmail.com}
  s.files =   Dir["lib/**/*"] + Dir["bin/**/*"] + Dir["test/**/*"]+ Dir["*.rb"] + ["MIT-LICENSE","notes_mailer.gemspec"]
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc"]
  s.require_paths = ["lib"]
  s.summary = %q{Small gem that uses IBM Lotus Notes to deliver your e-mails.}
  s.description = %q{NotesMailer allows you to send emails using your local IBM Lotus Notes installation. It is implemented by wrapping the Lotus Notes-win32ole-api as a custom delivery method for Mail. The usage is very similar to the SMTP delivery method in the popular Mail-gem.}
  s.files.reject! { |fn| fn.include? "CVS" }
  s.require_path = "lib"
  #s.default_executable = %q{}
  #s.executables = [""]
  s.homepage = %q{http://rubyforge.org/projects/notesmailer/}
  s.rubyforge_project = %q{notesmailer}
  s.add_dependency("mail", ">= 2.2.1")
  s.add_dependency("log4r", ">=1.0.5")

end


if $0 == __FILE__
   Gem.manage_gems
   Gem::Builder.new(spec).build
end
