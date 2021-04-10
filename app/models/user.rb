class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         before_validation { email.downcase! }
   validates :name,  presence: true, length: { maximum: 30 }
   validates :email, presence: true, length: { maximum: 255 },
                     format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
   validates :password, presence: true, length: { minimum: 6 }

    has_many :teams
    has_many :assigns
    has_many :assign_teams, through: :assigns, source: :team
    has_many :reports
    has_many :bookmarks
    has_many :comments

    mount_uploader :icon, ImageUploader

    def self.find_or_create_by_email(email)
    user = find_or_initialize_by(email: email)
    if user.new_record?
      user.password = generate_password
      user.save
    end
    user
  end

  def self.generate_password
    SecureRandom.hex(10)
  end

  def liked_by?(report_id)
    bookmarks.where(report_id: report_id).exists?
  end

  def self.find_or_create_by_email(email)
    user = find_or_initialize_by(email: email)
    if user.new_record?
      user.password = generate_password
      user.save!
      AssignMailer.assign_mail(user.email, user.password).deliver
    end
    user
  end

  def owner_report
    owner_team = self.assign_teams.where(owner_id: self.id)
    owner_reports = Report.where(team_id: owner_team.ids, checkbox_final: false).order(created_at: :asc)
  end

  def author_report
    author_reports = self.reports.where(checkbox_final: false).order(created_at: :asc)
  end

  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = 'ゲスト'
    end
  end

  def destroy_step
    if self.assigns.empty? && undone_reports.count == 0
      self.destroy
      redirect_to new_user_session_path
      flash[:success] = "ユーザー「#{self.name}」を削除しました"
    elsif undone_reports.count > 0
      redirect_to user_path(self)
      flash[:danger] = "未完の報告書がある為、削除できません"
    else
      redirect_to user_path(self)
      flash[:danger] = "チームに所属している為、削除できません"
     end
   end
end
