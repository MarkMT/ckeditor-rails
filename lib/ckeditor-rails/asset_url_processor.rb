module Ckeditor
  module Rails
    # Rewrites urls in CSS files with the digested paths
    class AssetUrlProcessor
      REGEX = /url\(\s*["']?(?!(?:\#|data|http))([^"'\s)]+)\s*["']?\)/

      def self.stylesheet_files
        @stylesheet_files ||= ::Ckeditor::Rails::Asset.new.stylesheet_files
      end

      def self.assets_base_path(context = nil)
        return ::Ckeditor::Rails.assets_base_path unless context

        "#{context.assets_prefix}/ckeditor"
      end

      def self.call(input)
        return { data: input[:data] } unless stylesheet_files.include?(input[:filename])

        #puts caller(0)
        #puts "***** input filename #{input[:filename].inspect}"
        #puts "***** input environment #{input[:environment].inspect}"
        #puts "***** context_class #{input[:environment].context_class.inspect}"
        #puts "***** context_class #{input[:environment].context_class.ancestors.inspect}"
        
        context = input[:environment].context_class.new(input)
        #puts "***** context #{context.inspect}"
        path_prefix = assets_base_path()
        #puts "***** path_prefix #{path_prefix.inspect}"
        matched_folders = input[:filename].match(/\/ckeditor\/(plugins|skins)\/([\w-]+)\//)

        #puts "***** input data #{input[:data].inspect}"
        data = input[:data].gsub(REGEX) { |_match|
          #puts "***** $1 #{$1.inspect}"
          raw_asset_path = context.asset_path($1)
          #puts "***** raw_asset_path #{raw_asset_path.inspect}"
          if raw_asset_path.starts_with?(path_prefix)
            "url(#{raw_asset_path})"
          elsif matched_folders
            "url(#{path_prefix}/#{matched_folders[1]}/#{matched_folders[2]}#{raw_asset_path.gsub('/..', '')})"
          else
            "url(#{path_prefix}#{raw_asset_path})"
          end
        }

        { data: data }
      end
    end
  end
end
