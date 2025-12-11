module FacebookService
  class BusinessOnboard
    include HTTParty
    base_uri ENV['FB_API_URL']

    def initialize(token)
      @access_token = token
    end

    # Create a Business Manager
    def create_business(user_id, page_id, name, vertical)
      self.class.post("#{user_id}/businesses", body: {
        name: name,
        vertical: vertical,
        primary_page: page_id,
        access_token: @access_token
      })
    end

    # Check if a business already exists
    def get_owned_business(shared_page_id)
      self.class.get("/#{ENV['BUSINESS_MANAGER_ID']}/owned_businesses",
        query: {
          client_user_id: shared_page_id,
          access_token: ENV["DEV_WIZARD_TOKEN"]
        }
      )
    end

    # Create an "owned" business under parent BM
    def create_owned_businesses(name, business_id, page_id, vertical)
      self.class.post("/#{business_id}/owned_businesses", body: {
        name: "Zentap: #{name} Connection",
        vertical: vertical,
        timezone_id: '1',
        shared_page_id: page_id,
        access_token: @access_token,
        page_permitted_tasks: %w[MANAGE CREATE_CONTENT MODERATE ADVERTISE ANALYZE]
      })
    end

    # Add user to a Business Manager
    def add_child_business_users(child_bm_id, email)
      self.class.post("/#{child_bm_id}/business_users", body: {
        email: email,
        role: "EMPLOYEE",
        access_token: @access_token
      })
    end

    # Add user to a Page
    def add_user_to_page(page_id, business_id, user_id)
      self.class.post("/#{page_id}/assigned_users", body: {
        user: user_id,
        tasks: %w[MANAGE CREATE_CONTENT MODERATE ADVERTISE ANALYZE],
        business: business_id,
        access_token: @access_token
      })
    end

    # Get system users inside a Business Manager
    def get_system_users(business_id)
      self.class.get("/#{business_id}/system_users",
        query: { access_token: @access_token }
      )
    end

    # Create a system user access token
    def create_access_token(business_id)
      self.class.post("/#{business_id}/access_token", body: {
        app_id: ENV['facebook_app_id'],
        scope: "read_insights,publish_video,pages_manage_posts,ads_management,business_management",
        access_token: ENV['DEV_WIZARD_TOKEN']
      })
    end

    # Create an Ad Account under a Business Manager
    def create_ad_account(business_id, name, funding_id)
      self.class.post("/#{business_id}/adaccount", body: {
        name: "#{name} Ad Account",
        currency: "USD",
        timezone_id: "1",
        end_advertiser: "NONE",
        media_agency: ENV['facebook_app_id'],
        partner: "NONE",
        funding_id: funding_id,
        access_token: @access_token
      })
    end

    # Assign user permissions on Ad Account
    def add_user_to_ad_account(user_id, account_id, business_id)
      self.class.post("/act_#{account_id}/assigned_users", body: {
        user: user_id,
        business: business_id,
        tasks: ["DRAFT", "ANALYZE", "ADVERTISE", "MANAGE"],
        access_token: @access_token
      })
    end

    # Delete a client BM (cleanup)
    def delete_business(business_id, child_business_id)
      self.class.delete("/#{business_id}/owned_businesses", body: {
        client_id: child_business_id,
        access_token: @access_token
      })
    end
  end
end
