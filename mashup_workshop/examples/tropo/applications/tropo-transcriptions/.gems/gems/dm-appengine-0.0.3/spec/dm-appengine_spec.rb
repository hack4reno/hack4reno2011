#!/usr/bin/ruby1.8 -w
#
# Copyright:: Copyright 2009 Google Inc.
# Original Author:: Ryan Brown (mailto:ribrdb@google.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.dirname(__FILE__) + '/spec_helper'
require 'dm-core/spec/adapter_shared_spec'

class TextTest
  include DataMapper::Resource
  
  property :id, Serial
  property :text, Text
end

class TypeTest
  include DataMapper::Resource
  
  property :name, String, :key => true
  property :time, Time
  property :date, Date
  property :datetime, DateTime
  property :bigd, BigDecimal
  property :flower, Object
  property :klass, Class
end

class Flower
  attr_accessor :color
end

class FooBar
  include DataMapper::Resource
  
  property :id, Serial
  property :string, String
end

describe DataMapper::Adapters::AppEngineAdapter do
  before :all do
    AppEngine::Testing.install_test_env
    AppEngine::Testing.install_test_datastore
  end

  before :all do
    @adapter = DataMapper.setup(:default, "app_engine://memory")
    @repository = DataMapper.repository(@adapter.name)
    
    AppEngine::Testing.install_test_datastore
  end
  
  def pending_if(message, boolean = true)
    if boolean
      pending(message) { yield }
    else
      yield
    end
  end

  it_should_behave_like 'An Adapter'
  
  describe 'create' do
    it 'should support Text' do
      a = TextTest.new(:text => "a" * 1024)
      a.save
    end
  end
  
  describe 'update' do
    it 'should support Text' do
      a = TextTest.new(:text => "a" * 1024)
      a.save
      a.text = "A" * 1024
      a.save
      a.reload
      a.text.should be_a(AppEngine::Datastore::Text)
      a.text.should be_a(String)
    end
  end
  
  describe 'read' do
    it 'should support sorting by id' do
      FooBar.create(:string => 'a')
      FooBar.create(:string => 'c')
      FooBar.create(:string => 'b')
      foobars = FooBar.all(:order => [:id.desc])
      strings = foobars.map {|fb| fb.string}
      strings.should == ['b', 'c', 'a']
    end
    
    it 'should support sorting by property' do
      foobars = FooBar.all(:order => [:string])
      strings = foobars.map {|fb| fb.string}
      strings.should == ['a', 'b', 'c']      
    end
    
    it 'should support filtering by id' do
      a = FooBar.first
      a.string.should == 'a'
      b = FooBar.first(:id.gt => a.id)
      b.string.should == 'c'
    end
  end
  
  describe 'types' do
    it 'should support Date' do
      date = Date.parse('2007/12/23')
      a = TypeTest.new(:name => 'date', :date => date)
      a.save
      a.reload
      a.date.should == date
    end
    
    it 'should support Time' do
      time = Time.at(Time.now.to_i)  # Datastore store ms precision, not usec
      a = TypeTest.new(:name => 'time', :time => time)
      a.save
      a.reload
      a.time.should == time
    end
    
    it 'should support DateTime' do
      date = DateTime.parse('2007-12-23')
      a = TypeTest.new(:name => 'datetime', :datetime => date)
      a.save
      a.reload
      a.datetime.should == date
    end
    
    it 'should support BigDecimal' do
      one = BigDecimal.new('1.0')
      a = TypeTest.new(:name => 'bigd', :bigd => one)
      a.save
      a.reload
      a.bigd.should == one
    end
    
    it 'should support Object' do
      flower = Flower.new
      flower.color = 'red'
      a = TypeTest.new(:name => 'color', :flower => flower)
      a.save
      a.reload
      a.flower.color.should == flower.color
    end
    
    it 'should support Class' do
      a = TypeTest.new(:name => 'class', :klass => Flower)
      a.save
      a.reload
      a.klass.should == Flower
    end
  end
end
