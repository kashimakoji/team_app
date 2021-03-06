class TeamsController < ApplicationController
  before_action :authenticate_user! # deviseのメソッド
  before_action :set_team, only: %i[show edit update destroy change_owner]
  before_action :ensure_owner, only: %i[edit update]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    # if current_user == team.owner #追加

    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team') # 'チーム更新に成功しました！'
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team') # '保存に失敗しました、、'
      render :edit
    end
    # else
    #   redirect_to @team
    # end #追加
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def change_owner # チームIDとアサインID
    # @team = Team.find(params[:id])
    if @team.update(owner_id: params[:user_id])
      # binding.irb
      AssignMailer.change_owner_mail(@team.owner.email).deliver
      redirect_to @team, notice: 'ownerを更新しました'
    end
    # params[team_id] == @team.id
    # params[id] == assign.id
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id]) # paramsは今自分がブラウザで見ているチームの情報を探す。friendlyはgem(ドメイン表示されるidを特定の名前に変える)
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

  def ensure_owner
    set_team
    #@team.owner.id == current_user.id
    redirect_to @team, notice: 'チームリーダーのみ編集可能です' if @team.owner != current_user
  end

end
