module SimpleCalendar
  module ViewDayHelpers

    def day_calendar(events, options={}, &block)
      raise 'SimpleCalendar requires a block to be passed in' unless block_given?


      opts = {
          :year       => (params[:year] || Time.zone.now.year).to_i,
          :month      => (params[:month] || Time.zone.now.month).to_i,
          :day        => (params[:day] || Time.zone.now.day).to_i,
          :prev_text  => raw("&laquo;"),
          :next_text  => raw("&raquo;"),
          :per_day  => false
      }
      options.reverse_merge! opts
      events       ||= []
      selected_month = Date.civil(options[:year], options[:month])
      selected_day   = Date.civil(options[:year], options[:month], options[:day])
      hours_array    = build_day()

      draw_day_calendar(selected_month, hours_array, selected_day, events, options, block)
    end

    private

    def build_day()
      hours = []
      
      (0..23).each do |t|
        hours << Time.new(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, t, 0).strftime("%H:%M")
      end
      
      hours
    end

    # Renders the calendar table
    def draw_day_calendar(selected_month, hours, selected_day, events, options, block)
      tags = []
      content_tag(:table, :class => "table table-bordered table-striped day_calendar") do
        tags << day_header(selected_day, options)
        tags << content_tag(:thead, content_tag(:tr, content_tag(:th, "", :class => "span1") + content_tag(:th, I18n.t("date.abbr_day_names")[selected_day.strftime("%w").to_i])))
        tags << content_tag(:tbody, :'data-day' => selected_day.day, :'data-month' => selected_month.month, :'data-year' => selected_month.year) do
          
          hours.collect do |hour|
            content_tag(:tr, :class => "hour") do
              divs = []
              divs << hour_events(selected_day, hour, events).collect { |event| block.call(event) }
              
              concat content_tag(:td, content_tag(:div, hour.to_s, :class => "hour_number"), :class => "hour", :'data-date-iso' => selected_day.to_s, 'data-date' => selected_day.to_s.gsub('-', '/')) + content_tag(:td, content_tag(:div, divs.join.html_safe))
            end #content_tag :tr
            
          end.join.html_safe
        end #content_tag :tbody
        
        tags.join.html_safe
      end #content_tag :table
    end

    # Returns an array of events for a given day
    def hour_events(selected_day, hour, events)
      h = hour.split(":")
      hour_end = "#{h[0]}:59"
      events.select { |e| e.start_time.to_date == selected_day && (e.start_time.to_time.strftime("%H:%M") >= hour) && (e.start_time.to_time.strftime("%H:%M") < hour_end) }
    end

    # Generates the header that includes the month and next and previous months
    def day_header(selected_day, options)
      content_tag :h3 do
        previous_day = selected_day.advance :days => -1
        next_day = selected_day.advance :days => 1
        tags = []

        tags << "#{I18n.t("date.day_names")[selected_day.strftime("%w").to_i]} #{selected_day.day} #{I18n.t("date.month_names")[selected_day.month]}"
        tags << day_link(options[:next_text], next_day, {:class => "next-day #{options[:next_nav]}", :remote => (options[:remote] || false)})
        tags << day_link(options[:prev_text], previous_day, {:class => "previous-day #{options[:prev_nav]}", :remote => (options[:remote] || false)})
        #tags << day_link(options[:prev_text], previous_day, {:class => "previous-day", :remote => (options[:remote] || false)})

        tags.join.html_safe
      end
    end

    # Generates the link to next and previous months
    def day_link(text, day, opts={})
      link_to(text, "#{simple_day_calendar_path}?per_day=#{opts[:per_day]}&day=#{day.day}month=#{day.month}&year=#{day.year}", opts)
    end

    # Returns the full path to the calendar
    # This is used for generating the links to the next and previous months
    def simple_day_calendar_path
      request.fullpath.split('?').first
    end
  end
end
