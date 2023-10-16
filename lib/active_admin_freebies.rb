# frozen_string_literal: true

require_relative "active_admin_freebies/version"

module ActiveAdminFreebies
  class Error < StandardError; end
  # Your code goes here...

  # usage:
  #
  # Within an ActiveAdmin resource, include the module:
  #   `include ActiveAdminFreebies::AutomaticAssociationsSidebar`

  # TODO:
  # - deal with polymorphic associations
  # - automatically add the sidebar to all admin pages
  # - verify that has_many through's are working as expected
  #   - and check the inverse

  module AutomaticAssociationsSidebar
    extend ActiveSupport::Concern

    def self.build_ransack_query(resource, reflection, query_parts = [])
      return "" if reflection.nil?

      if reflection.macro == :has_many && !reflection.options[:through]
        query_parts << reflection.foreign_key + "_eq"
      elsif reflection.macro == :has_many && reflection.options[:through]
        through_association_name = reflection.options[:through]
        through_reflection = reflection.active_record.reflect_on_association(through_association_name)

        if through_reflection&.foreign_key
          # Only append if it doesn't already exist in query_parts
          query_parts << through_reflection.foreign_key + "_eq" unless query_parts.include?(through_reflection.foreign_key + "_eq")
          build_ransack_query(resource, through_reflection, query_parts)
        end
      else
        # For belongs_to or has_one
        query_parts << "#{reflection.klass.name.downcase}_id_eq"
      end

      query_parts.last
    end

    def self.admin_route_exists?(options = {})
      Rails.application.routes.url_helpers.url_for(options.merge(only_path: true))
      true
    rescue ActionController::UrlGenerationError
      false
    end

    def self.included(base)
      base.instance_eval do
        sidebar "dynamic associations", only: %i[show] do
          resource_class = resource.class

          belongs_to_reflections = resource_class.reflect_on_all_associations(:belongs_to).select do |reflection|
            !reflection.options[:polymorphic]
          end.sort_by(&:name)

          has_many_reflections = resource_class.reflect_on_all_associations(:has_many).select do |reflection|
            !reflection.options[:polymorphic] && !reflection.options[:through]
          end.sort_by(&:name)

          has_many_through_reflections = resource_class.reflect_on_all_associations(:has_many).select do |reflection|
            !reflection.options[:polymorphic] && reflection.options[:through]
          end.sort_by(&:name)

          all_has_many_reflections = has_many_reflections | has_many_through_reflections

          if all_has_many_reflections.any?
            span do
              "Children"
            end

            ul do
              all_has_many_reflections.each do |reflection|
                association_name = reflection.name.to_s.underscore

                count = resource.send(reflection.name).count

                ransack_query = ActiveAdminFreebies::AutomaticAssociationsSidebar.build_ransack_query(resource, reflection)

                if ActiveAdminFreebies::AutomaticAssociationsSidebar.admin_route_exists?(controller: "/admin/#{reflection.name}", action: "index")
                  li do
                    link_to(
                      "#{association_name.titleize} (#{count})",
                      "/admin/#{association_name.pluralize}?q[#{ransack_query}]=#{resource.id}"
                    )
                  end
                end
              end
            end
          end

          if belongs_to_reflections.any?
            span do
              "Parents"
            end

            ul do
              belongs_to_reflections.each do |reflection|
                association_name = reflection.name

                parent_id = resource.send(association_name.to_sym)&.id

                if parent_id.present?
                  li do
                    link_to(
                      "#{reflection.name.to_s.titleize}/#{parent_id}",
                      "/admin/#{association_name.to_s.pluralize}/#{parent_id}"
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

end
