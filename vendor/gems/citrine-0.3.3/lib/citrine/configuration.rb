# frozen-string-literal: true
require "pathname"
module Citrine
  class Configuration < Utils::Configuration
    using CoreRefinements

    %i(initializers conversion security gateway configurator schemes
       repositories interactors wardens integrators jobs).each do |section|
      define_method("has_#{section}?") { has_key?(section) and !send(section).empty? }
      define_method(section) { self[section] }
    end

    def merge(other_config)
      if base_config.nil?
        super
      else
        @config = base_config.deep_merge(convert_to_hash(other_config))
        setup_config_readers
      end
    end
    
    protected

    attr_reader :base_config

    def post_init
      @base_config = Utils.deep_clone(@config)
      setup_config_readers
    end

    def set_default_values
      %i(initializers conversion security gateway configurator schemes
         repositories interactors wardens integrators jobs).each do |section|
        config[section] ||= {}
      end
    end
    
    def setup_config_readers
      setup_repositories_readers
      setup_interactors_readers
      setup_wardens_readers
      setup_integrators_readers
      setup_gateway_readers
    end

    def setup_repositories_readers
      setup_actors_readers(:repositories)
    end

    def setup_interactors_readers
      setup_actors_readers(:interactors) do |c|
        c.deep_merge!(schemes: schemes) if has_schemes?
      end
    end

    def setup_wardens_readers
      setup_actors_readers(:wardens)
    end

    def setup_integrators_readers
      setup_actors_readers(:integrators) do |c|
        c.deep_merge!(security) if has_security?
        c.deep_merge!(conversion: conversion) if has_conversion?
      end
    end

    def setup_actors_readers(actors)
      general_config = config[actors][:general] || {}
      send(actors).each_pair do |name, config|
        next unless name.to_s =~ /_#{actors.to_s.singularize}$/
        actor_config = general_config.deep_merge(config)
        yield(actor_config) if block_given?
        define_singleton_method(name) { actor_config }
      end
    end

    def setup_gateway_readers
      setup_gateway_server_reader
      setup_gateway_router_reader
    end

    def setup_gateway_server_reader
      server_config = gateway[:server] || {}
      define_singleton_method(:gateway_server) { server_config }
    end
    
    def setup_gateway_router_reader
      router_config = 
        (gateway[:router] || {}).tap do |c|
          c.deep_merge!(security) if has_security?
          if has_conversion?
            c[:conversion] = conversion.deep_merge!(c[:conversion] || {})
          end
        end
      define_singleton_method(:gateway_router) { router_config }
    end
  end
end