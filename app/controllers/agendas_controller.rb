class AgendasController < ApplicationController
  # before_action :set_agenda, only: %i[show edit update destroy]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    # byebug
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end


  def destroy
    @agenda = Agenda.find(params[:id])
    # byebug
    if current_user.id == @agenda.team.owner.id || current_user.id == @agenda.user_id
      @agenda.destroy
      #--------------------------------------
      # binding.irb
      AssignMailer.delete_agenda_mail(@agenda.team.members).deliver

      #--------------------------------
      redirect_to dashboard_path, notice: "アジェンダ「#{@agenda.title}」を削除しました"
    else
      I18n.t('views.messages.cannot_delete_member_4_some_reason')
    end
  end


  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
