require "application_system_test_case"

class StarshipsTest < ApplicationSystemTestCase
  setup do
    @starship = starships(:one)
  end

  test "visiting the index" do
    visit starships_url
    assert_selector "h1", text: "Starships"
  end

  test "should create starship" do
    visit starships_url
    click_on "New starship"

    fill_in "Name", with: @starship.name
    fill_in "Url", with: @starship.url
    click_on "Create Starship"

    assert_text "Starship was successfully created"
    click_on "Back"
  end

  test "should update Starship" do
    visit starship_url(@starship)
    click_on "Edit this starship", match: :first

    fill_in "Name", with: @starship.name
    fill_in "Url", with: @starship.url
    click_on "Update Starship"

    assert_text "Starship was successfully updated"
    click_on "Back"
  end

  test "should destroy Starship" do
    visit starship_url(@starship)
    click_on "Destroy this starship", match: :first

    assert_text "Starship was successfully destroyed"
  end
end
