require 'rails_helper'
RSpec.describe 'Teamモデル機能', type: :model do
  let!(:user){ FactoryBot.create(:user) }

  describe 'バリデーションのテスト' do
    context 'Teamの名前が空の場合' do
        it 'バリデーションにひっかる' do
          team = Team.new(name: '', owner_id: user.id)
          expect(team).not_to be_valid
        end
      end
      context 'Teamの名前が入力されている場合' do
        it 'バリデーションが通る' do
          team = Team.new(name: 'テスト', owner_id: user.id)
          expect(team).to be_valid
        end
      end
    end
  end
