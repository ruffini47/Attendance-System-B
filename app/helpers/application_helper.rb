module ApplicationHelper
  def full_title(page_name = "")
    base_title = "AttendanceAppB"
    if page_name.empty?
      base_title
    else
      page_name + " | " + base_title
    end
  end

  def hour_00(at)
    at.to_s.rjust(2,'0')
  end

  def min_15(at)
    (at.min / 15 * 15).to_s.rjust(2,'0')
  end


end
