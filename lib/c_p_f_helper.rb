class CPFHelper
  def self.build(value = random_value)
    v1, v2 = calculate_digits(value)
    [value, v1, v2].join
  end

  # https://pt.wikipedia.org/wiki/Cadastro_de_Pessoas_F%C3%ADsicas
  def self.calculate_digits(value)
    reversed_cpf = value[0..8].split(//).map(&:to_i).reverse

    v1, v2 =
      reversed_cpf
        .each_with_index
        .reduce([0, 0]) do |(v1, v2), (num, index)|
          v1 += (num * (9 - (index % 10)))
          v2 += (num * (9 - ((index + 1) % 10)))
          [v1, v2]
        end

    v1 = (v1 % 11) % 10
    v2 = ((v2 + v1 * 9) % 11) % 10

    [v1, v2]
  end

  def self.random_value
    (100_000_000 + SecureRandom.rand(1_000_000_000 - 100_000_000)).to_i.to_s
  end

  private_class_method :random_value
end
