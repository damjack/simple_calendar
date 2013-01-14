module SimpleCalendar
  class Railtie < Rails::Railtie
    initializer "simple_calendar.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
      ActionView::Base.send :include, ViewDayHelpers
    end
  end
end
