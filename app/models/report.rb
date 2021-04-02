class Report < ApplicationRecord
  acts_as_taggable
  belongs_to :user
  belongs_to :team
  has_many :bookmarks, -> {order(created_at: :desc)}, dependent: :destroy
  has_many :comments,                                 dependent: :destroy
  has_many :attachments,                              dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: :all_blank

  enum search_item: {タイトル: 1, チーム名: 2, 責任者: 3, 担当者: 4}
  # enum step: {第一報告: 1, 中間報告: 2, 有効性の確認: 3}

  scope :sort_by_deadline_date_asc, lambda { all.sort_by(&:deadline_date) }
  scope :sort_by_deadline_date_desc, lambda { all.sort_by(&:deadline_date).reverse }

  def deadline_date
    if self.checkbox_final
      return '--------------------'
    elsif self.checkbox_first
     if self.checkbox_interim && self.confirmed_date
       return (self.confirmed_date).strftime("%Y年 %m月 %d日")
     elsif self.checkbox_interim && self.confirmed_date.nil?
       return '未定'
     else
       return (self.accrual_date + 14.day).strftime("%Y年 %m月 %d日")
     end
    else
     return (self.accrual_date + 7.day).strftime("%Y年 %m月 %d日")
    end
  end

  def build_attachment_for_form
   self.attachments.build if saved_attachments.length < 5 && unsaved_attachments.length == 0
  end

  def saved_attachments
   self.attachments.select(&:id)
  end

  def unsaved_attachments
   self.attachments.select { |attachment| attachment.id.nil? }
  end

  def bookmarked_by(user)
    Bookmark.find_by(user_id: user.id, report_id: id)
  end

  def step_string
    if self.checkbox_interim && self.checkbox_first
      return self.update(step:"3: 有効性の確認" )
    elsif self.checkbox_first
      return self.update(step:"2: 中間報告" )
    else
      return self.update(step:"1: 第一報告" )
    end
  end

  def status_string
    if self.approval
      return self.update(status:"承認依頼中")
    else
      return self.update(status:"作成中")
    end
  end
end

  # def step_string
  #   case self.step
  #   when 0 then return  self.step = "有効性の確認"
  #   when 1 then return  self.step = "中間報告"
  #   when 2 then return  self.step = "第一報"
  #   end
  # end
