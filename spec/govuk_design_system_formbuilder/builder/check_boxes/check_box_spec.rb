describe GOVUKDesignSystemFormBuilder::FormBuilder do
  include_context 'setup builder'
  include_context 'setup examples'

  describe '#govuk_check_box' do
    let(:method) { :govuk_check_box }
    let(:attribute) { :projects }
    let(:value) { project_x.id }
    let(:args) { [method, attribute, value] }

    subject { builder.send(*args) }

    specify 'output should contain a check box item group with a check box input' do
      expect(subject).to have_tag('div', with: { class: 'govuk-checkboxes__item' }) do |ci|
        expect(ci).to have_tag('input', with: {
          id: "person-projects-#{value}-field",
          type: 'checkbox',
          value: value
        })
      end
    end

    include_examples 'HTML formatting checks'

    it_behaves_like 'a field that supports custom branding'

    it_behaves_like 'a field that supports labels' do
      let(:label_text) { 'Project X' }
      let(:field_type) { "input[type='checkbox']" }

      specify 'the label should have a check box label class' do
        expect(subject).to have_tag('label', with: { class: 'govuk-checkboxes__label' })
      end
    end

    it_behaves_like 'a field that supports setting the label via localisation'

    context 'labels set via procs' do
      let(:label_text) { 'Project Y' }
      let(:label_proc) { -> { label_text } }
      subject { builder.send(*args, label: label_proc) }

      specify 'the label should have a check box label class' do
        expect(subject).to have_tag('label', with: { class: 'govuk-checkboxes__label' })
      end

      specify %(the label's for attribute should match the checkbox's id) do
        label_for = parsed_subject.at_css('label')['for']
        checkbox_id = parsed_subject.at_css('input')['id']

        expect(label_for).to eql(checkbox_id)
      end
    end

    context 'check box hints' do
      let(:hint_text) { project_x.description }

      subject do
        builder.send(*args, hint: { text: hint_text })
      end

      specify 'should contain a hint with the correct text' do
        expect(subject).to have_tag('span', text: hint_text)
      end

      specify 'the hint should have the correct classes' do
        expect(subject).to have_tag('span', with: { class: %w(govuk-hint govuk-checkboxes__hint) })
      end

      context 'when the hint is supplied in a proc' do
        subject do
          builder.govuk_check_box(attribute, value, hint: -> { builder.tag.section(project_x.description) })
        end

        specify 'the proc-supplied hint content should be present and contained in a div' do
          expect(subject).to have_tag('div', with: { class: %w(govuk-hint govuk-checkboxes__hint) }) do
            with_tag('section', text: project_x.description)
          end
        end
      end
    end

    context 'multiple' do
      context 'default to multiple' do
        specify 'check box name should allow multiple values' do
          expect(subject).to have_tag('input', with: {
            type: 'checkbox',
            name: "#{object_name}[#{attribute}][]"
          })
        end
      end

      context 'overridden to false' do
        subject { builder.send(*args, multiple: false) }

        specify 'check box name should allow a single value only' do
          expect(subject).to have_tag('input', with: {
            type: 'checkbox',
            name: "#{object_name}[#{attribute}]"
          })
        end
      end
    end

    context 'conditionally revealing content' do
      context 'when a block is given' do
        subject do
          builder.send(*args) do
            builder.govuk_text_field(:project_responsibilities)
          end
        end

        specify 'should place the conditional content at the same level as the checkbox container' do
          expect(parsed_subject).to have_root_element_with_class('govuk-checkboxes__conditional')
        end

        specify 'should include content provided in the block in a conditional div' do
          expect(subject).to have_tag('div', with: { class: 'govuk-checkboxes__conditional govuk-checkboxes__conditional--hidden' }) do |cd|
            expect(cd).to have_tag('label', with: { class: 'govuk-label' }, text: 'Project_responsibilities')
            expect(cd).to have_tag('input', with: { type: 'text' })
          end
        end

        specify "the data-aria-controls attribute should match the conditional block's id" do
          input_data_aria_controls = parsed_subject.at_css("input[type='checkbox']")['data-aria-controls']
          conditional_id = parsed_subject.at_css('div.govuk-checkboxes__conditional')['id']
          expect(input_data_aria_controls).to eql(conditional_id)
        end

        specify 'conditional_id contains the object, attribute and value name' do
          expect(
            parsed_subject.at_css("input[type='checkbox']")['data-aria-controls']
          ).to eql("#{object_name}-#{attribute}-#{value}-conditional")
        end
      end

      context 'when no block is given' do
        subject { builder.send(*args) }

        specify "the data-aria-controls attribute should be blank" do
          input_data_aria_controls = parsed_subject.at_css("input[type='checkbox']")['data-aria-controls']
          expect(input_data_aria_controls).to be_nil
        end

        specify "the conditional container should not be present" do
          expect(subject).not_to have_tag('.govuk-checkboxes__conditional')
        end
      end
    end
  end
end
