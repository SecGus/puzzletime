#  Copyright (c) 2006-2017, Puzzle ITC GmbH. This file is part of
#  PuzzleTime and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/puzzletime.

module IntegrationHelper
  private

  def login_as(user)
    employee = user.is_a?(Employee) ? user : employees(user)
    # employee.update_passwd!('foobar')
    super(employee)
  end

  def set_period(start_date: '1.1.2006', end_date: '31.12.2006', back_url: current_url)
    visit periods_path(back_url: back_url)
    fill_in 'period_start_date', with: start_date, fill_options: { clear: :backspace }
    fill_in 'period_end_date', with: end_date, fill_options: { clear: :backspace }
    find('input[name=commit]').click
  end

  # catch some errors occuring now and then in capybara tests
  def timeout_safe
    yield
  rescue Errno::ECONNREFUSED,
         Timeout::Error,
         Capybara::FrozenInTime,
         Capybara::ElementNotFound,
         Selenium::WebDriver::Error::StaleElementReferenceError => e
    skip e.message || e.class.name
  end

  def open_selectize(id, options = {})
    element = find("##{id} + .selectize-control")
    element.find('.selectize-input').click unless options[:no_click]
    element.find('.selectize-input input').native.send_keys(:backspace) if options[:clear]
    element.find('.selectize-input input').set(options[:term]) if options[:term].present?
    if options[:assert_empty]
      page.assert_no_selector('.selectize-dropdown-content')
    else
      page.assert_selector('.selectize-dropdown-content')
      find('.selectize-dropdown-content')
    end
  end

  def selectize(id, value, options = {})
    open_selectize(id, options).find('.selectize-option,.option', text: value).click
  end

  def drag(from_node, *to_node)
    action = page.driver.browser.action.click_and_hold(from_node.native)
    to_node.each { |node| action = action.move_to(node.native) }
    action.release.perform
  end

  def accept_confirmation(expected_message = nil)
    if expected_message.present?
      assert_equal expected_message, page.driver.browser.switch_to.alert.text
    end
    page.driver.browser.switch_to.alert.accept
  end

  def dismiss_confirmation(expected_message = nil)
    if expected_message.present?
      assert_equal expected_message, page.driver.browser.switch_to.alert.text
    end
    page.driver.browser.switch_to.alert.dismiss
  end

  Capybara.add_selector(:name) do
    xpath { |name| XPath.descendant[XPath.attr(:name).contains(name)] }
  end

  def clear_cookies
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) && browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end
end
