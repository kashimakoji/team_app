class AssignMailer < ApplicationMailer
  default from: 'from@example.com'

  def assign_mail(email, password)
    @email = email
    @password = password
    mail to: @email, subject: I18n.t('views.messages.complete_registration') # 登録完了
  end

  def change_owner_mail(email)
    @email = email
    mail to: @email, subject: 'リーダー変更'
  end

  def delete_agenda_mail(team_members)
    @members = team_members
    mail to: @members.map(&:email).join(","), subject: "アジェンダ削除通知メールです。"
  end

end
