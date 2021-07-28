require "#{Rails.root}/lib/c_p_f_helper"

class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.is_a?(String)
      value.strip!
      raise ArgumentError unless value =~ /^\d{11}$/
      raise ArgumentError unless validate_cpf(value)
    end
  rescue ArgumentError
    record.errors.add attribute, :invalid
  end

  def validate_cpf(value)
    v1, v2 = CPFHelper.calculate_digits(value)
    value[9].to_i == v1 && value[10].to_i == v2
  end

  private :validate_cpf
end
