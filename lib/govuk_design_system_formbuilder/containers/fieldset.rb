module GOVUKDesignSystemFormBuilder
  module Containers
    class Fieldset < GOVUKDesignSystemFormBuilder::Base
      LEGEND_DEFAULTS = { text: nil, tag: 'h1', size: 'xl' }.freeze
      LEGEND_SIZES = %w(xl l m s)

      def initialize(builder, object_name, attribute_name, legend: {})
        super(builder, object_name, attribute_name)
        @legend = LEGEND_DEFAULTS.merge(legend)
      end

      def html
        @builder.content_tag('div', class: fieldset_classes) do
          @builder.safe_join([
            build_legend,
            yield
          ])
        end
      end

    private

      def build_legend
        if @legend.dig(:text).present?
          @builder.content_tag('legend', class: legend_classes) do
            @builder.tag.send(@legend.dig(:tag), @legend.dig(:text), class: legend_heading_classes)
          end
        end
      end

      def fieldset_classes
        %w(govuk-fieldset)
      end

      def legend_classes
        size = @legend.dig(:size)
        fail "invalid size #{size}, must be #{LEGEND_SIZES.join(', ')}" unless size.in?(LEGEND_SIZES)
        "govuk-fieldset__legend govuk-fieldset__legend--#{size}"
      end

      def legend_heading_classes
        %(govuk-fieldset__heading)
      end
    end
  end
end
