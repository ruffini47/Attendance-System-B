module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    shour = start.hour
    fhour = finish.hour
    smin = start.min
    fmin = finish.min
    
    shour = shour + smin / 60.0
    fhour = fhour + fmin / 60.0

    format("%.2f", fhour - shour)
    
  end
end
