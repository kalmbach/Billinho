class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _)
    if record.send("#{attribute}_before_type_cast").is_a?(String)
      value = Date.parse(record.send("#{attribute}_before_type_cast"))
      record.send("#{attribute}=", value)
    end
  rescue ArgumentError
    record.errors.add attribute, :invalid
  end
end
