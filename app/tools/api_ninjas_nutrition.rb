class ApiNinjasNutrition < RubyLLM::Tool
  description <<~DESC
    Analyse nutritionnelle à partir d'une description en langage naturel.
    Calcule automatiquement les calories, macronutriments, fibres et minéraux
    pour les aliments mentionnés. Supporte les quantités naturelles
    ('200g chicken breast', '3 eggs', '1 avocado').
    Les queries doivent être en ANGLAIS pour des résultats optimaux.
  DESC
  param :query,
        desc: "Description en ANGLAIS des aliments à analyser (ex: '200g grilled chicken and 100g rice', '3 eggs scrambled')"
  def execute(query:)
    return { error: "Clé API Ninjas non configurée" } unless ENV["API_NINJAS_KEY"]

    response = Faraday.get("https://api.api-ninjas.com/v1/nutrition") do |req|
      req.params["query"] = query
      req.headers["X-Api-Key"] = ENV.fetch("API_NINJAS_KEY")
    end
    return { error: "API Ninjas indisponible (HTTP #{response.status})" } unless response.success?

    items = JSON.parse(response.body)
    return { query: query, results: [], note: "Aucun résultat pour '#{query}'" } if items.empty?

    results = items.map { |item| format_item(item) }
    { query: query, results: results }
  rescue Faraday::Error => e
    { error: "Erreur réseau API Ninjas : #{e.message}" }
  rescue JSON::ParserError
    { error: "Réponse API Ninjas illisible" }
  end

  private

  def format_item(item)
    {
      name: item["name"],
      serving_size_g: item["serving_size_g"],
      calories: item["calories"]&.to_f&.round(1),
      protein_g: item["protein_g"],
      fat_total_g: item["fat_total_g"],
      fat_saturated_g: item["fat_saturated_g"],
      carbs_total_g: item["carbohydrates_total_g"],
      fiber_g: item["fiber_g"],
      sugar_g: item["sugar_g"],
      cholesterol_mg: item["cholesterol_mg"],
      sodium_mg: item["sodium_mg"],
      potassium_mg: item["potassium_mg"]
    }.compact
  end
end
