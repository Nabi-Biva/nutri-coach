puts "🌱 Seeding..."

# -------------------------------------------------------------------
# 1. NETTOYAGE (décommente si tu veux relancer les seeds)
# -------------------------------------------------------------------
Message.destroy_all
Recipe.destroy_all
Chat.destroy_all
Profile.destroy_all
User.destroy_all

# -------------------------------------------------------------------
# 2. USERS
# -------------------------------------------------------------------
emma = User.create!(
  email:                 "emma@example.com",
  first_name:            "Emma",
  last_name:             "Martin",
  password:              "password123",
  password_confirmation: "password123"
)

lucas = User.create!(
  email:                 "lucas@example.com",
  first_name:            "Lucas",
  last_name:             "Dubois",
  password:              "password123",
  password_confirmation: "password123"
)

sofia = User.create!(
  email:                 "sofia@example.com",
  first_name:            "Sofia",
  last_name:             "Bernard",
  password:              "password123",
  password_confirmation: "password123"
)

thomas = User.create!(
  email:                 "thomas@example.com",
  first_name:            "Thomas",
  last_name:             "Petit",
  password:              "password123",
  password_confirmation: "password123"
)

puts "✅ #{User.count} users créés"

# -------------------------------------------------------------------
# 3. PROFILES (1 par user)
# -------------------------------------------------------------------
emma.create_profile!(
  sex:       "female",
  birthday:  Date.parse("1995-03-15"),
  weight:    65.0,
  height:    1.68,
  goal:      "Perdre 3 kg, manger plus équilibré",
  allergy:   "lactose, gluten",
  lifestyle: "Actif (sport 3x/semaine)"
)

lucas.create_profile!(
  sex:       "male",
  birthday:  Date.parse("1990-07-22"),
  weight:    82.0,
  height:    1.82,
  goal:      "Prise de masse musculaire",
  allergy:   "arachides",
  lifestyle: "Très actif (muscu 5x/semaine)"
)

sofia.create_profile!(
  sex:       "female",
  birthday:  Date.parse("1988-11-08"),
  weight:    58.0,
  height:    1.63,
  goal:      "Maintien du poids, réduire le sucre",
  allergy:   "aucun",
  lifestyle: "Sédentaire (bureau)"
)

thomas.create_profile!(
  sex:       "male",
  birthday:  Date.parse("1993-06-30"),
  weight:    95.0,
  height:    1.75,
  goal:      "Perdre 10 kg, contrôler le cholestérol",
  allergy:   "crustacés",
  lifestyle: "Modéré (marche quotidienne)"
)

puts "✅ #{Profile.count} profiles créés"

# -------------------------------------------------------------------
# 4. CHATS
# -------------------------------------------------------------------
chat_emma_1 = emma.chats.create!(
  title: "Menu semaine équilibré sans lactose"
)

chat_emma_2 = emma.chats.create!(
  title: "Idées petit-déjeuner healthy"
)

chat_lucas_1 = lucas.chats.create!(
  title: "Plan prise de masse"
)

chat_sofia_1 = sofia.chats.create!(
  title: "Snacks sans sucre pour le bureau"
)

chat_thomas_1 = thomas.chats.create!(
  title: "Rééquilibrage alimentaire"
)

puts "✅ #{Chat.count} chats créés"

# -------------------------------------------------------------------
# 5. MESSAGES (alterner user / assistant)
# -------------------------------------------------------------------
chat_emma_1.messages.create!(
  role: "user",
  content: "Salut, peux-tu me proposer un menu pour la semaine ? Je suis allergique au lactose et au gluten."
)
chat_emma_1.messages.create!(
  role: "assistant",
  content: "Bien sûr Emma ! Voici une proposition de menu sans lactose ni gluten pour la semaine. Lundi : buddha bowl quinoa-poulet, Mardi : curry de légumes au lait de coco..."
)
chat_emma_1.messages.create!(
  role: "user",
  content: "Super merci ! Tu peux détailler la recette du buddha bowl ?"
)
chat_emma_1.messages.create!(
  role: "assistant",
  content: "Bien sûr ! Voici la recette détaillée du Buddha Bowl quinoa-poulet..."
)

chat_lucas_1.messages.create!(
  role: "user",
  content: "Je fais de la muscu 5 fois par semaine, j'ai besoin d'un plan alimentaire pour la prise de masse."
)
chat_lucas_1.messages.create!(
  role: "assistant",
  content: "Salut Lucas ! Pour une prise de masse avec ton rythme d'entraînement, voici un plan à ~3000 kcal/jour avec 180g de protéines..."
)

chat_sofia_1.messages.create!(
  role: "user",
  content: "Des idées de snacks sains pour le bureau ? J'essaie d'arrêter le sucre."
)
chat_sofia_1.messages.create!(
  role: "assistant",
  content: "Hello Sofia ! Excellente démarche. Voici 5 snacks sans sucre ajouté : amandes et noix, bâtonnets de légumes + houmous, yaourt nature + fruits rouges..."
)

chat_thomas_1.messages.create!(
  role: "user",
  content: "Je dois perdre 10 kg et mon médecin m'a dit de surveiller mon cholestérol. Tu peux m'aider ?"
)
chat_thomas_1.messages.create!(
  role: "assistant",
  content: "Bien sûr Thomas. On va combiner déficit calorique modéré et aliments bons pour le cholestérol. Voici un plan sur 3 mois..."
)

puts "✅ #{Message.count} messages créés"

# -------------------------------------------------------------------
# 6. RECIPES
# -------------------------------------------------------------------
chat_emma_1.recipes.create!(
  name: "Buddha Bowl quinoa poulet",
  content: "**Ingrédients** : 100g quinoa, 150g filet poulet, 1 avocat, 1 patate douce, 100g pois chiches, roquette, huile d'olive, citron, sel, poivre.\n\n**Préparation** : 1. Cuire le quinoa 12 min. 2. Rôtir la patate douce au four 25 min à 200°C. 3. Poêler le poulet 5 min par face. 4. Dresser le tout dans un bol, ajouter avocat coupé et pois chiches. 5. Assaisonner huile d'olive + citron."
)

chat_emma_1.recipes.create!(
  name: "Porridge flocons d'avoine fruits rouges",
  content: "**Ingrédients** : 50g flocons d'avoine, 200ml lait d'amande, 1 banane, fruits rouges surgelés, 1 c.à.s. graines de chia.\n\n**Préparation** : 1. Chauffer le lait d'amande avec les flocons 5 min. 2. Ajouter les graines de chia. 3. Servir avec banane en rondelles et fruits rouges."
)

chat_emma_2.recipes.create!(
  name: "smoothie bowl",
  content: "**Ingrédients** : 1 banane surgelée, 100g fruits rouges surgelés, 150ml lait d'amande, 1 c.à.s. graines de chia, 30g granola sans sucre, 1c.à.c. miel.\n\n**Préparation** : 1. Mixer la banane, les fruits rouges et le lait d'amande jusqu'à texture lisse. 2. Verser dans un bol. 3. Topping : granola, graines de chia, filet de miel."
)

chat_lucas_1.recipes.create!(
  name: "Shaker protéiné banane-avoine",
  content: "**Ingrédients** : 30g whey vanille, 1 banane, 40g flocons d'avoine, 300ml lait demi-écrémé, 1 c.à.s. beurre de cacahuète.\n\n**Préparation** : Tout mixer 30 secondes. Boire dans l'heure qui suit l'entraînement."
)

chat_lucas_1.recipes.create!(
  name: "Poulet riz complet brocolis",
  content: "**Ingrédients** (meal prep x4) : 800g filet poulet, 400g riz complet, 4 têtes de brocoli, huile d'olive, épices.\n\n**Préparation** : 1. Cuire le riz 25 min. 2. Cuire les brocolis vapeur 10 min. 3. Poêler le poulet 6 min par face. 4. Répartir dans 4 tupperwares."
)

chat_sofia_1.recipes.create!(
  name: "Energy balls cacao-dattes",
  content: "**Ingrédients** : 200g dattes, 50g amandes, 30g noix, 2 c.à.s. cacao cru, 1 c.à.s. huile de coco.\n\n**Préparation** : 1. Mixer tous les ingrédients. 2. Former des boules. 3. Réfrigérer 1h. Se conserve 1 semaine."
)

chat_thomas_1.recipes.create!(
  name: "Saumon vapeur légumes verts",
  content: "**Ingrédients** : 150g filet saumon, 200g haricots verts, 150g épinards frais, 1 citron, aneth, sel, poivre.\n\n**Préparation** : 1. Cuire le saumon vapeur 12 min. 2. Cuire les haricots vapeur 8 min. 3. Poêler les épinards 2 min. 4. Servir avec citron et aneth."
)

puts "✅ #{Recipe.count} recipes créés"

puts "🎉 Seeds terminées !"
