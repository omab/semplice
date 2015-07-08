# coding: utf-8
require './lib/semplice'


Gem::Specification.new do |s|
  s.name = 'splice'
  s.version = Semplice::VERSION
  s.summary = 'Simple Template Engine.'
  s.description = 'Semplice is a mote inspired template engine with Django-like syntax and inheritance.'
  s.authors = ['Matías Aguirre']
  s.email = ['matiasaguirre@gmail.com']
  s.homepage = 'http://github.com/omab/semplice'
  s.files = Dir[
    'LICENSE',
    'README.md',
    'lib/**/*.rb',
    '*.gemspec',
    'test/**/*.rb'
  ]
  s.add_development_dependency 'minitest'
end
