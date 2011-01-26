module AutocompleteHelper

  # creates the javascript for autocomplete on text field with field_id
  #
  # options:
  #
  #  :url
  #    what url to use to get the auto complete data. optional
  #
  #  :onselect
  #    what js function to run when an item is selected
  #
  #  :message
  #    the message to display, if any, before a user starts to type.
  #
  #  :container
  #    the dom id of an element that will be the container for the popup. optional
  #
  def autocomplete_entity_tag(field_id, options={})
    options[:url] ||= '/autocomplete/entities'
    # sometimes we might want to make some fancy serviceURL involving some js
    serviceurl = options[:serviceurl] || "serviceUrl:'#{options[:url]}'"
    options[:onselect] ||= 'null'
    options[:renderer] ||= render_entity_row_function
    auto_complete_js = %Q[
      #{options[:additional_js]}
      new Autocomplete('#{field_id}', {
        #{serviceurl},
        minChars:2,
        maxHeight:400,
        width:300,
        onSelect: #{options[:onselect]},
        message: '#{escape_javascript(options[:message])}',
        container: '#{options[:container]}',
        preloadedOnTop: true,
        rowRenderer: #{options[:renderer]},
        selectValue: #{extract_value_from_entity_row_function}
      }, #{autocomplete_id_number});
    ]
    javascript_tag(auto_complete_js)
  end

  def autocomplete_users_tag(field_id, options={})
    autocomplete_entity_tag(field_id, options.merge(:url => '/autocomplete/people'))
  end

  def autocomplete_friends_tag(field_id, options={})
    autocomplete_entity_tag(field_id, options.merge(:url => '/autocomplete/friends'))
  end

  def autocomplete_locations_tag(field_id, options={})
    find_selected_country_js = "function getCountry() { if ($$('option.newselected')[0]) { return $$('option.newselected')[0].readAttribute('value'); } else { return $('select_country_id').getValue(); } }"
    autocomplete_entity_tag(field_id,
      options.merge(:serviceurl => "serviceUrl:'/autocomplete/locations/?country='+getCountry()",
        :renderer => render_location_row_function,
        :additional_js => find_selected_country_js )
    )
  end

  private

  def autocomplete_id_number
    rand(100000000)
  end

  # called in order to render a popup row. it is a little too complicated.
  #
  # basically, we want to just highlight the text but not the html tags in the
  # popup row.
  #
  def render_entity_row_function
    %Q[function(value, re, data) {return '<p class=\"name_icon xsmall\" style=\"background-image: url(/avatars/'+data+'/xsmall.jpg)\">' + value.replace(/^<em>(.*)<\\/em>(<br\\/>(.*))?$/gi, function(m, m1, m2, m3){return '<em>' + Autocomplete.highlight(m1,re) + '</em>' + (m3 ? '<br/>' + Autocomplete.highlight(m3, re) : '')}) + '</p>';}]
  end

  def render_location_row_function
    %Q[function(value, re, data) {return value.replace(/^<em>(.*)<\\/em>(<br\\/>(.*))?$/gi, function(m, m1, m2, m3){return '<em>' + Autocomplete.highlight(m1,re) + '</em>' + (m3 ? '<br/>' + Autocomplete.highlight(m3, re) : '')});}]
  end

  # called to convert the row data into a value
  def extract_value_from_entity_row_function
    %Q[function(value){ var reEntity = new RegExp; if (value.match(/<br\\/>/)) { reEntity = /.*<br\\/>(\\S+).*/g; }else { reEntity = /<em>(.*)<\\/em>.*/g; } return value.replace(reEntity,'$1');}]
  end

end
