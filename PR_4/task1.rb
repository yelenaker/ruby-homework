# -----------------------------
# RecipeCraft Console App
# -----------------------------

# Клас для інгредієнтів
class Ingredient
  attr_reader :name, :unit, :calories_per_unit

  def initialize(name, unit, calories_per_unit)
    @name = name
    @unit = unit
    @calories_per_unit = calories_per_unit
  end
end

# Клас для рецептів
class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps, items)
    @name = name
    @steps = steps
    # items - масив хешів {ingredient: Ingredient, qty: number, unit: symbol}
    @items = items
  end

  # Метод повертає потребу в інгредієнтах у базових одиницях (:g, :ml, :pcs)
  def need
    @items.map do |item|
      {
        name: item[:ingredient].name,
        qty: UnitConverter.to_base(item[:qty], item[:unit]),
        unit: UnitConverter.base_unit(item[:unit]),
        calories: UnitConverter.to_base(item[:qty], item[:unit]) * item[:ingredient].calories_per_unit
      }
    end
  end
end

# Клас для комори
class Pantry
  def initialize
    @stock = {} # {name => {qty, unit}}
  end

  def add(name, qty, unit)
    base_qty = UnitConverter.to_base(qty, unit)
    base_unit = UnitConverter.base_unit(unit)
    if @stock[name]
      @stock[name][:qty] += base_qty
    else
      @stock[name] = {qty: base_qty, unit: base_unit}
    end
  end

  def available_for(name)
    @stock[name] ? @stock[name][:qty] : 0
  end
end

# Модуль для конвертації одиниць
module UnitConverter
  def self.to_base(qty, unit)
    case unit
    when :kg then qty * 1000
    when :g then qty
    when :l then qty * 1000
    when :ml then qty
    when :pcs then qty
    else
      raise "Unknown unit #{unit}"
    end
  end

  def self.base_unit(unit)
    case unit
    when :kg, :g then :g
    when :l, :ml then :ml
    when :pcs then :pcs
    else
      raise "Unknown unit #{unit}"
    end
  end
end

# Клас для планування
class Planner
  def self.plan(recipes, pantry, price_list)
    total_calories = 0
    total_cost = 0

    recipes.each do |recipe|
      recipe.need.each do |need_item|
        name = need_item[:name]
        qty_needed = need_item[:qty]
        qty_have = pantry.available_for(name)
        deficit = [qty_needed - qty_have, 0].max

        total_calories += need_item[:calories]
        total_cost += deficit * price_list[name]

        puts "#{name}: need #{qty_needed}#{need_item[:unit]} / have #{qty_have}#{need_item[:unit]} / deficit #{deficit}#{need_item[:unit]}"
      end
    end

    puts "Total calories: #{total_calories}"
    puts "Total cost: #{total_cost.round(2)}"
  end
end

# -----------------------------
# Demo
# -----------------------------
# Створюємо інгредієнти
flour = Ingredient.new("flour", :g, 3.64)
milk = Ingredient.new("milk", :ml, 0.06)
egg = Ingredient.new("egg", :pcs, 72)
pasta = Ingredient.new("pasta", :g, 3.5)
sauce = Ingredient.new("sauce", :ml, 0.2)
cheese = Ingredient.new("cheese", :g, 4.0)

# Створюємо комору
pantry = Pantry.new
pantry.add("flour", 1, :kg)
pantry.add("milk", 0.5, :l)
pantry.add("egg", 6, :pcs)
pantry.add("pasta", 300, :g)
pantry.add("cheese", 150, :g)

# Ціни за базову одиницю
prices = {
  "flour" => 0.02,
  "milk" => 0.015,
  "egg" => 6.0,
  "pasta" => 0.03,
  "sauce" => 0.025,
  "cheese" => 0.08
}

# Створюємо рецепти
omelet = Recipe.new("Omelet", ["Mix ingredients", "Cook"], [
  {ingredient: egg, qty: 3, unit: :pcs},
  {ingredient: milk, qty: 100, unit: :ml},
  {ingredient: flour, qty: 20, unit: :g}
])

pasta_recipe = Recipe.new("Pasta", ["Boil pasta", "Add sauce and cheese"], [
  {ingredient: pasta, qty: 200, unit: :g},
  {ingredient: sauce, qty: 150, unit: :ml},
  {ingredient: cheese, qty: 50, unit: :g}
])

# Плануємо
Planner.plan([omelet, pasta_recipe], pantry, prices)
