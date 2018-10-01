require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  include Devise::Test::ControllerHelpers

  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @current_user = FactoryBot.create(:user)
    @campaign = FactoryBot.create(:campaign, user: @current_user)
    sign_in @current_user
  end

  describe "POST #create" do  
    before(:each) do
      @member = attributes_for(:member, campaign_id: @campaign.id)
      post :create, params: {member: @member}
    end

    it "Create member with right attributes" do
      expect(Member.last.name).to eql(@member[:name])
      expect(Member.last.email).to eql(@member[:email])
      expect(Member.last.campaign.id).to eql(@member[:campaign_id])
    end

    it "Created member associated with right campaign" do 
      expect(Member.last.campaign.id).to eql(@member[:campaign_id]) 
    end  

    it "success in create" do
      member = create(:member, campaign_id: @campaign.id)
      expect(response).to have_http_status(:success)
    end  

    it "member has already been added" do
      post :create, params: { member: @member }  
      expect(response).to have_http_status(422)
    end

    it "forbidden user can't add member" do
      new_member = attributes_for(:member, campaign_id: create(:campaign, user: create(:user)).id)
      post :create, params: { member: new_member }
      expect(response).to have_http_status(:forbidden)
    end

  end

  describe "DELETE #destroy" do
    before(:each) do
      member = create(:member, campaign: @campaign)
    end

    it "deleted member" do
      member_id = member.id
      delete :destroy, params: { id: member.id }
      expect(Member.find(member_id).to eql(have_http_status(404)))
    end

    it "returns http success" do
      delete :destroy, params: {id: member.id}
      expect(response).to have_http_status(:success)
    end  
  end  

  describe "PUT #update" do
    before(:each) do
      member = create(:member, campaign: @campaign.id)
      put :update, params: {id: member.id, member: member}
    end

    it "returns http success" do
      expect(response).to be_successful
    end

    it "returns 200 OK" do
      expect(response).to have_http_status(200)
    end

    it "returns http forbidden" do
      member = create(:member)
      put :update, params: {id: member.id, email: member.email}
      expect(response).to have_http_status(:forbidden)
    end
  end

end
