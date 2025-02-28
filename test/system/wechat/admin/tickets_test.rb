require "application_system_test_case"

class TicketsTest < ApplicationSystemTestCase
  setup do
    @wechat_admin_ticket = wechat_admin_tickets(:one)
  end

  test "visiting the index" do
    visit wechat_admin_tickets_url
    assert_selector "h1", text: "Tickets"
  end

  test "creating a Ticket" do
    visit wechat_admin_tickets_url
    click_on "New Ticket"

    fill_in "Finish at", with: @wechat_admin_ticket.finish_at
    fill_in "Invalid response", with: @wechat_admin_ticket.invalid_response
    fill_in "Match value", with: @wechat_admin_ticket.match_value
    fill_in "Serial start", with: @wechat_admin_ticket.serial_start
    fill_in "Start at", with: @wechat_admin_ticket.start_at
    fill_in "Valid response", with: @wechat_admin_ticket.valid_response
    click_on "Create Ticket"

    assert_text "Ticket was successfully created"
    click_on "Back"
  end

  test "updating a Ticket" do
    visit wechat_admin_tickets_url
    click_on "Edit", match: :first

    fill_in "Finish at", with: @wechat_admin_ticket.finish_at
    fill_in "Invalid response", with: @wechat_admin_ticket.invalid_response
    fill_in "Match value", with: @wechat_admin_ticket.match_value
    fill_in "Serial start", with: @wechat_admin_ticket.serial_start
    fill_in "Start at", with: @wechat_admin_ticket.start_at
    fill_in "Valid response", with: @wechat_admin_ticket.valid_response
    click_on "Update Ticket"

    assert_text "Ticket was successfully updated"
    click_on "Back"
  end

  test "destroying a Ticket" do
    visit wechat_admin_tickets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ticket was successfully destroyed"
  end
end
