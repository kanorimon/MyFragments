# coding: utf-8
module ApplicationHelper
  
def br(text)
  return text if text.blank?
  text = h text
  text.gsub(/\r\n|\r|\n/, "<br />").html_safe
end

end