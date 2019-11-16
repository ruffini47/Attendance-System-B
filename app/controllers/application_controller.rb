class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}

  # beforeフィルター
    
  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end
    
  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
    
  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    unless current_user?(@user)
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    unless current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to root_url
    end
  end

  # beforeフィルター
    
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
#    if params[:month].nil?
#      if params[:date].nil?
#        @first_day = Date.current.beginning_of_month 
#      else
#        @first_day = params[:date].to_date.beginning_of_month
#      end
#      @last_day = @first_day.end_of_month
#      @month = true
#    elsif params[:month] == "true"
#      if params[:date].nil?
#        @first_day = Date.current.beginning_of_month
#      else 
#        @first_day = params[:date].to_date.beginning_of_month
#      end
#      @last_day = @first_day.end_of_month
#      @month = true
#    elsif params[:month] == "false"
#      if params[:date].nil?
#        @first_day = Date.current.beginning_of_week
#      else
#        @first_day= params[:date].to_date.beginning_of_week
#      end
#      @last_day = @first_day.end_of_week
#      @month = false
#    else
#    end
#    if @month == true
#      @first_day = @first_day_m
#      @last_day = @last_day_m
#    else
#      @first_day = @first_day_w
#      @last_day = @last_day_w
#    end

    if params[:date].nil? || params[:month].nil?
      @first_day = Date.current.beginning_of_month
      @last_day = @first_day.end_of_month
      @month = true
    elsif params[:month] == "true"
      @first_day = params[:date].to_date.beginning_of_month
      @last_day = @first_day.end_of_month
      @month = true
    elsif params[:month] == "false"
      @first_day = params[:date].to_date.beginning_of_week
      @last_day = @first_day.end_of_week
      @month = false
    end
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。  
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = nil
    if @user.attendances.count != 0
      @user.attendances.each {
        |a| a = nil}
    end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    #if @month == false
      @attendances = @attendances.distinct
    #end
    if one_month.count > @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        
        #if @attendances.count != 0
          one_month.each { |day|  
            #for n in 1..@user.attendances.count do
              #if day != @user.attendances.find(n).worked_on
                if @month == false
                  if [day, @first_day].compact.min == day && day != @first_day
                    #if day < @first_day なら
                    @user.attendances.create!(worked_on: day)
                    @user.attendances = @user.attendances.distinct
                  end
                  if @first_day.month != @last_day.month
                    if[day, @last_day.beginning_of_month].compact.min == day && day != @last_day.beginning_of_month 
                      # if day <  @last_day.beginning_of_month なら
                      @user.attendances.create!(worked_on: day)
                      @user.attendances = @user.attendances.distinct
                    end
                  elsif @first_day.month == @last_day.month
                    if day >= @first_day && day <= @last_day
                      # if @first_day <= day <= @last_day
                      @user.attendances.each do |d|
                        if d.worked_on != day
                          @user.attendances.create!(worked_on: day)
                          @user.attendances = @user.attendances.distinct
                        end
                      end
                    end
                  end
                elsif @month == true
                  @user.attendances.create!(worked_on: day)
                  @user.attendances = @user.attendances.distinct
                end
              #end
            #end
          }
          #if day != @attendances.first.worked_on              
          
        #end
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
      @attendances = @attendances.distinct
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
  #def set_month
  #  @first_day = params[:date].nil? ?
  #  Date.current.beginning_of_month : params[:date].to_date.beginning_of_month
  #  redirect_to user_url(date: @first_day, month: params[:month])
  #end
    
    
#    @month = true
#    @first_day = params[:date].to_date.beginning_of_month
#    redirect_to user_url(date: @first_day, month: @month)
#  end
  
  #def set_week
  #  @first_day = params[:date].nil? ?
  #  Date.current.beginning_of_week : params[:date].to_date.beginning_of_week
  #  redirect_to user_url(date: @first_day, month: params[:month])  
  #end

#    @month = false
#    @first_day = params[:date].to_date.beginning_of_week
#    redirect_to user_url(date: @first_day, month: @month)

end
