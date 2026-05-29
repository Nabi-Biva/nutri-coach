class OpenFoodFactsSearch < RubyLLM::Tool
  description <<~DESC
    Recherche des produits alimentaires dans la base Open Food Facts (plus
    de 3 millions de produits). Retourne les valeurs nutritionnelles pour
    100 g, le Nutri-Score (A à E), le groupe NOVA (1 = non transformé à
    4 = ultra-transformé), la liste d'ingrédients et les allergènes.
    Accepte un nom de produit ou un code-barres.
  DESC
  param :query,
        desc: "Nom du produit ou code-barres (ex: 'pizza margherita', 'nutella', '3017620422003')"
  param :page_size,
        type: :integer,
        desc: "Nombre de résultats (défaut : 5)",
        required: false
  USER_AGENT = "NutriCoach/1.0 (contact@nutricoach.app)".freeze
  BASE_URL   = "https://world.openfoodfacts.org".freeze
  NOVA_LABELS = {
    1 => "Aliments non / peu transformés",
    2 => "Ingrédients culinaires transformés",
    3 => "Aliments transformés",
    4 => "Aliments ultra-transformés"
  }.freeze
  def execute(query:, page_size: 5)
    if query.match?(/\A\d+\z/)
      lookup_barcode(query)
    else
      search_by_name(query, [page_size.to_i, 1].max)
    end
  rescue Faraday::Error => e
    { error: "Erreur réseau Open Food Facts : #{e.message}" }
  rescue JSON::ParserError
    { error: "Réponse Open Food Facts illisible" }
  end

  private

  def lookup_barcode(barcode)
    response = Faraday.get("#{BASE_URL}/api/v2/product/#{barcode}.json") do |req|
      req.headers["User-Agent"] = USER_AGENT
    end
    return { error: "Open Food Facts indisponible (HTTP #{response.status})" } unless response.success?

    product = JSON.parse(response.body)["product"]
    if product.nil? || product["product_name"].nil?
      return { query: barcode, results: [],
               note: "Code-barres '#{barcode}' introuvable" }
    end

    { query: barcode, results: [format_product(product)] }
  end

  def search_by_name(terms, page_size)
    response = Faraday.get("#{BASE_URL}/api/v2/search") do |req|
      req.params["search_terms"] = terms
      req.params["page_size"]    = page_size
      req.params["fields"]       =
        "product_name,brands,nutriscore_grade,nova_group,nutriments,ingredients_text,allergens_tags,quantity"
      req.headers["User-Agent"]  = USER_AGENT
    end
    return { error: "Open Food Facts indisponible (HTTP #{response.status})" } unless response.success?

    products = JSON.parse(response.body)["products"] || []
    return { query: terms, results: [], note: "Aucun produit trouvé pour '#{terms}'" } if products.empty?

    results = products.first(page_size).map { |p| format_product(p) }
    { query: terms, results: results }
  end

  def format_product(product)
    nutriments = product["nutriments"] || {}
    {
      name: product["product_name"],
      brand: product["brands"],
      quantity: product["quantity"],
      nutriscore: product["nutriscore_grade"]&.upcase,
      nova_group: product["nova_group"],
      nova_label: NOVA_LABELS[product["nova_group"]],
      ingredients: product["ingredients_text"]&.truncate(500),
      allergens: product["allergens_tags"]&.map { |tag| tag.sub("en:", "") },
      nutrients: {
        energy_kcal_100g: nutriments["energy-kcal_100g"],
        fat_100g: nutriments["fat_100g"],
        saturated_fat_100g: nutriments["saturated-fat_100g"],
        carbs_100g: nutriments["carbohydrates_100g"],
        sugars_100g: nutriments["sugars_100g"],
        proteins_100g: nutriments["proteins_100g"],
        fiber_100g: nutriments["fiber_100g"],
        salt_100g: nutriments["salt_100g"]
      }.compact
    }
  end
end
