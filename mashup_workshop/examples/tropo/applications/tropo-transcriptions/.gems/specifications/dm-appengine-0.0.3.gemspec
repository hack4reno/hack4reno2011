# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-appengine}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Brown"]
  s.autorequire = %q{dm-appengine}
  s.date = %q{2009-08-14}
  s.description = %q{A DataMapper adapter for Google App Engine}
  s.email = %q{ribrdb@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "lib/appengine_adapter.rb", "spec/dm-appengine_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://code.google.com/p/appengine-jruby}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A DataMapper adapter for Google App Engine}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<appengine-apis>, ["~> 0.0.3"])
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.0"])
    else
      s.add_dependency(%q<appengine-apis>, ["~> 0.0.3"])
      s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
    end
  else
    s.add_dependency(%q<appengine-apis>, ["~> 0.0.3"])
    s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
  end
end
