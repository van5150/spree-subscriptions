require 'spec_helper'

describe "Subscription" do
  context "as_admin_user" do
    before(:each) do
      visit spree.admin_path
    end

    context "listing subscriptions" do
      context "sorting" do
        # sort by subscription fields
      end
    end

    context "searching subscriptions" do
      # search by some fields
    end

    context "create a new subscription" do
      before(:each) do
        reset_spree_preferences do |config|
          config.default_country_id = create(:country).id
        end
        create(:state, :country_id => 1)
        create(:product, :name => 'sport magazine', :available_on => '2011-01-06 18:21:13:', :subscribable => true)
        create(:product, :name => 'web magazine', :available_on => '2011-01-06 18:21:13:', :subscribable => true)
        create(:product, :name => 'the book', :available_on => '2011-01-06 18:21:13:')
        click_link "Subscriptions"
        click_link "admin_new_subscription"
      end

      it "allow admin to go to the new subscription page" do
        within('#new_subscription') do  
          page.should have_content('Variant')
          page.should have_content('Start date')
          page.should have_content('End date')
        end
      end

      it "should allow admin to select subscribable variants only" do
        # this is an hack. The following line does not work!!
        # page.has_no_select?('Variant', :with_options => ['the book'])
        page.should have_xpath("//*[@id='subscription_variant_id']/option", :count => 2)
      end

      it "allow admin to create a new subscription" do
        select "web magazine", :from => "Variant"
        click_button "Create"
        page.should have_content("successfully created!")
        # within('table#listing_subscriptions tbody tr:nth-child(1)') { click_link("Edit") } 
        within('.sidebar') { click_link("Subscription Details") }
        # hack. The following line does not work
        # page.has_select?('Variant', :selected => "sport magazine")
        find_field('Variant').find('option[selected]').text.should == "web magazine"
      end
    end

    context "edit a subscription" do
      before(:each) do
        create(:product, :name => 'sport magazine', :available_on => '2011-01-06 18:21:13:', :subscribable => true)
        create(:product, :name => 'web magazine', :available_on => '2011-01-06 18:21:13:', :subscribable => true)
        create(:subscription)
        click_link "Subscriptions"
      end

      it "should have a link to edit subscribtion" do
        within('table#listing_subscriptions tbody tr:nth-child(1)') { page.should have_content("Edit") } 
      end

      it "should allow to edit fields" do
        within('table#listing_subscriptions tbody tr:nth-child(1)') { click_link("Edit") }
        select "web magazine", :from => "Variant"
        click_button "Update"
        page.should have_content("successfully updated!")
        find_field('Variant').find('option[selected]').text.should == "web magazine"
      end

      context "editing customer details" do
        before do
          reset_spree_preferences do |config|
            config.default_country_id = create(:country).id
          end
          create(:state, :country_id => 1)
          # Go to customer details page
          within('table#listing_subscriptions tbody tr:nth-child(1)') { click_link("Edit") }
          within('.sidebar') { click_link("Customer Details") }
        end

        it "should allow admin to go to subscription customer details page" do
          page.should have_content("Address")
        end

        it "should allow admin to edit subscription customer details" do
          fill_in "Email", :with => "johnnyrocket@stardustcompany.com"
          within('#shipping') do
            fill_in 'First Name', :with => "Johnny"
            fill_in 'Last Name', :with => "Rocket"
            fill_in 'Street Address', :with => "Stardust Street"
            fill_in 'City', :with => "Omega"
            fill_in 'Zip', :with => "66100"
            fill_in 'Phone', :with => "0871540143"
            select "United States of Foo", :from => "Country"
            select "Alabama", :from => "State"
          end
          click_button "Update"
          page.should have_content("The customer's details have been updated")
          page.should have_content("Variant")
          within('.sidebar') { click_link("Customer Details") }
          find_field("subscription_email").value.should == "johnnyrocket@stardustcompany.com"
          within('#shipping') do
            find_field("subscription_ship_address_attributes_firstname").value.should == "Johnny"
            find_field("subscription_ship_address_attributes_lastname").value.should == "Rocket"
            find_field("subscription_ship_address_attributes_address1").value.should == "Stardust Street"
            find_field("subscription_ship_address_attributes_city").value.should == "Omega"
            find_field("subscription_ship_address_attributes_zipcode").value.should == "66100"
            find_field("subscription_ship_address_attributes_phone").value.should == "0871540143"
            find_field("subscription_ship_address_attributes_state_id").find('option[selected]').text.should == "Alabama"
            find_field("subscription_ship_address_attributes_country_id").find('option[selected]').text.should == "United States of Foo"
          end
        end
      end
    end
  end
end