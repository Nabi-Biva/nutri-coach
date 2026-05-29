class UsdaFoodSearch < RubyLLM::Tool
  description <<~DESC
    Recherche des aliments dans la base USDA FoodData Central et retourne
    leurs valeurs nutritionnelles détaillées pour 100 g : macronutriments,
    minéraux, vitamines, fibres, sucres ajoutés et acides gras.
  DESC
  param :query,
        desc: "Nom de l'aliment à rechercher (ex: 'broccoli', 'poulet', 'pâtes')"
  param :page_size,
        type: :integer,
        desc: "Nombre maximum de résultats (défaut : 5)",
        required: false
  NUTRIENT_IDS = {
    # --- Macronutriments ---
    1008 => :energy_kcal,
    1003 => :protein_g,
    1004 => :total_fat_g,
    1258 => :saturated_fat_g,
    1257 => :trans_fat_g,
    1085 => :total_fat_nlea_g,
    1005 => :total_carbs_g,
    1079 => :fiber_g,
    2000 => :sugar_g,
    1235 => :added_sugar_g,
    1253 => :cholesterol_mg,
    # --- Minéraux ---
    1087 => :calcium_mg,
    1089 => :iron_mg,
    1090 => :magnesium_mg,
    1091 => :phosphorus_mg,
    1092 => :potassium_mg,
    1093 => :sodium_mg,
    1095 => :zinc_mg,
    1101 => :selenium_ug,
    1098 => :copper_mg,
    1102 => :manganese_mg,
    1103 => :iodine_ug,
    # --- Vitamines ---
    1106 => :vitamin_a_rae_ug,
    1104 => :vitamin_a_iu,
    1162 => :vitamin_c_mg,
    1110 => :vitamin_d_ug,
    1109 => :vitamin_e_mg,
    1185 => :vitamin_k_ug,
    1114 => :vitamin_b1_mg,
    1115 => :vitamin_b2_mg,
    1116 => :vitamin_b3_mg,
    1175 => :vitamin_b6_mg,
    1178 => :vitamin_b9_ug,
    1176 => :vitamin_b12_ug,
    1120 => :biotine_b7_ug,
    1177 => :vitamin_b5_mg,
    # --- Autres ---
    1051 => :water_g,
    1013 => :ash_g,
    1180 => :choline_mg,
    1170 => :caffeine_mg
  }.freeze
  def execute(query:, page_size: 5)
    return { error: "Clé API USDA non configurée" } unless ENV["USDA_API_KEY"]

    response = Faraday.post("https://api.nal.usda.gov/fdc/v1/foods/search") do |req|
      req.headers["Content-Type"] = "application/json"
      req.params["api_key"] = ENV.fetch("USDA_API_KEY")
      req.body = {
        query: query,
        pageSize: [page_size.to_i, 1].max,
        dataType: %w[Foundation SR\ Legacy Branded]
      }.to_json
    end
    return { error: "USDA API indisponible (HTTP #{response.status})" } unless response.success?

    foods = JSON.parse(response.body)["foods"] || []
    return { query: query, results: [], note: "Aucun aliment trouvé pour '#{query}'" } if foods.empty?

    results = foods.first(page_size).map do |food|
      {
        name: food["description"],
        fdc_id: food["fdcId"],
        nutrients: extract_nutrients(food["foodNutrients"]),
        serving: "100 g"
      }
    end
    { query: query, results: results }
  rescue Faraday::Error => e
    { error: "Erreur réseau USDA : #{e.message}" }
  rescue JSON::ParserError
    { error: "Réponse USDA illisible" }
  end

  private

  def extract_nutrients(food_nutrients)
    return {} unless food_nutrients

    food_nutrients.each_with_object({}) do |fn, hash|
      key = NUTRIENT_IDS[fn["nutrientId"]]
      hash[key] = fn["value"]&.round(1) if key
    end
  end
end
