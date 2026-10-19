const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = path.resolve(__dirname, '..', 'serviceAccountKey.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const categories = [
  { id: 'jollof', name: 'Jollof Bowls', iconAsset: 'assets/icons/rice_dish_icon.png' },
  { id: 'soups', name: 'Local Soups', iconAsset: 'assets/icons/rice_dish_icon.png' },
  { id: 'grills', name: 'Grills & Suya', iconAsset: 'assets/icons/plate_icon.png' },
  { id: 'snacks', name: 'Snacks & Pastries', iconAsset: 'assets/icons/pizza_icon.png' },
  { id: 'drinks', name: 'Wines & Drinks', iconAsset: null },
  { id: 'pizza', name: 'Artisan Pizza', iconAsset: 'assets/icons/pizza_icon.png' },
  { id: 'sides', name: 'Sides & Extras', iconAsset: 'assets/icons/plate_icon.png' },
];

const restaurants = [
  {
    id: 'maa-mary',
    name: 'Maa Mary Special Kitchen',
    cuisine: 'Local Ghanaian & Soups',
    address: 'Near Konongo Post Office, Kumasi-Accra Highway',
    rating: 4.9,
    reviewCount: 320,
    deliveryTime: '20-30 min',
    deliveryFee: 5.0,
    imageAsset: 'assets/images/jollof_rice.png',
    badgeText: 'POPULAR',
    isOpen: true,
    distanceKm: '0.6',
    featuredDishIds: ['1', '2', '3'],
  },
  {
    id: 'anidaso',
    name: 'Anidaso Fast Food & Jollof Hub',
    cuisine: 'Jollof, Fried Rice & Grills',
    address: 'Konongo Station Road, Opposite Commercial Bank',
    rating: 4.8,
    reviewCount: 245,
    deliveryTime: '15-25 min',
    deliveryFee: 5.0,
    imageAsset: 'assets/images/grilled_tilapia.png',
    badgeText: 'FASTEST',
    isOpen: true,
    distanceKm: '0.4',
    featuredDishIds: ['1', '4', '5'],
  },
  {
    id: 'ahenfie',
    name: 'Ahenfie Bukka & Local Delights',
    cuisine: 'Traditional Fufu, Banku & Tuo Zaafi',
    address: 'Odumase Road, Near Palace Junction',
    rating: 4.7,
    reviewCount: 198,
    deliveryTime: '25-35 min',
    deliveryFee: 6.0,
    imageAsset: 'assets/images/waakye.png',
    badgeText: 'AUTHENTIC',
    isOpen: true,
    distanceKm: '1.2',
    featuredDishIds: ['2', '3'],
  },
  {
    id: 'aseda-pastries',
    name: 'Aseda Pastries, Wines & Chillers',
    cuisine: 'Meat Pies, Cakes, Juices, Wines & Beers',
    address: 'Low Cost Junction, Konongo Bypass',
    rating: 4.9,
    reviewCount: 175,
    deliveryTime: '10-20 min',
    deliveryFee: 4.0,
    imageAsset: 'assets/images/snacks and pastries/meat pie.jpg',
    badgeText: 'FRESH BAKED',
    isOpen: true,
    distanceKm: '0.5',
    featuredDishIds: ['7', '8', '10', '13'],
  },
  {
    id: 'champion-pizza',
    name: 'Champion Pizza & Continental',
    cuisine: 'Artisan Pizza, Burgers & Wings',
    address: 'Konongo High Street, Near Total Station',
    rating: 4.6,
    reviewCount: 110,
    deliveryTime: '30-40 min',
    deliveryFee: 7.0,
    imageAsset: 'assets/images/beef_burger.png',
    badgeText: 'SPECIALTY',
    isOpen: true,
    distanceKm: '1.5',
    featuredDishIds: ['6', '4'],
  },
  {
    id: 'night-market-grills',
    name: 'Konongo Central Night Market Grills',
    cuisine: 'Spicy Suya, Khebab, Grilled Fish & Pork',
    address: 'Central Market Roundabout, Konongo',
    rating: 4.8,
    reviewCount: 290,
    deliveryTime: '15-30 min',
    deliveryFee: 5.0,
    imageAsset: 'assets/images/grilled_tilapia.png',
    badgeText: 'NIGHT GRILL',
    isOpen: true,
    distanceKm: '0.7',
    featuredDishIds: ['5', '1'],
  },
];

const menuItems = [
  {
    id: '1',
    vendorId: 'maa-mary',
    name: 'Smoky Jollof & Grilled Chicken',
    description: 'Slow-cooked firewood jollof with spiced grilled quarter chicken and golden ripe plantains',
    price: 45.0,
    imageAsset: 'assets/images/jollof_rice.png',
    categoryId: 'jollof',
    rating: 4.9,
    prepTimeMinutes: 20,
    badgeText: 'BEST SELLER',
    tags: ['Popular', 'Spiced', 'Konongo Choice'],
    isAvailable: true,
  },
  {
    id: '2',
    vendorId: 'ahenfie',
    name: 'Fufu & Goat Meat Light Soup',
    description: 'Pounded cassava and plantain fufu served in rich aromatic garden egg & goat light soup',
    price: 55.0,
    imageAsset: 'assets/images/fufu_soup.png',
    categoryId: 'soups',
    rating: 4.9,
    prepTimeMinutes: 25,
    badgeText: 'CHEF SPECIAL',
    tags: ['Traditional', 'Organic', 'Spicy'],
    isAvailable: true,
  },
  {
    id: '3',
    vendorId: 'maa-mary',
    name: 'Waakye Special with Fish, Egg & Wele',
    description: 'Authentic sorghum-cooked rice & beans with dark smoked shito, spaghetti, boiled egg, and soft wele',
    price: 40.0,
    imageAsset: 'assets/images/waakye.png',
    categoryId: 'jollof',
    rating: 4.8,
    prepTimeMinutes: 15,
    badgeText: 'LOCAL FAVORITE',
    tags: ['Breakfast', 'Hearty', 'Street Favorite'],
    isAvailable: true,
  },
  {
    id: '4',
    vendorId: 'anidaso',
    name: 'Crispy Fried Chicken & French Fries',
    description: 'Golden seasoned chicken thighs served with crunchy salted potato fries and spicy ketchup',
    price: 38.0,
    imageAsset: 'assets/images/fried_chicken.png',
    categoryId: 'grills',
    rating: 4.7,
    prepTimeMinutes: 20,
    badgeText: 'HOT CRUNCH',
    tags: ['Crispy', 'Fast', 'Kids Love'],
    isAvailable: true,
  },
  {
    id: '5',
    vendorId: 'night-market-grills',
    name: 'Spicy Suya & Grilled Sausage Platter',
    description: 'Tender sliced beef suya heavily spiced with authentic yaji pepper, fresh onions, tomatoes and grilled beef sausages',
    price: 50.0,
    imageAsset: 'assets/images/grilled_tilapia.png',
    categoryId: 'grills',
    rating: 4.9,
    prepTimeMinutes: 15,
    badgeText: 'FIRE GRILLED',
    tags: ['Suya', 'Hot', 'Evening Bite'],
    isAvailable: true,
  },
  {
    id: '6',
    vendorId: 'champion-pizza',
    name: 'Artisan Beef & Cheese Pizza (Large)',
    description: 'Thin hand-stretched crust topped with rich tomato herb sauce, spiced minced beef, mozzarella and sweet bell peppers',
    price: 85.0,
    imageAsset: 'assets/images/beef_burger.png',
    categoryId: 'pizza',
    rating: 4.6,
    prepTimeMinutes: 30,
    badgeText: 'FAMILY PACK',
    tags: ['Cheesy', 'Continental', 'Baking'],
    isAvailable: true,
  },
  {
    id: '7',
    vendorId: 'aseda-pastries',
    name: 'Golden Beef Meat Pie (2 pcs)',
    description: 'Flaky buttery pastry packed with minced seasoned beef, diced potatoes and carrots',
    price: 24.0,
    imageAsset: 'assets/images/snacks and pastries/meat pie.jpg',
    categoryId: 'snacks',
    rating: 4.9,
    prepTimeMinutes: 10,
    badgeText: 'FRESH OVEN',
    tags: ['Bakery', 'Warm', 'Snack'],
    isAvailable: true,
  },
  {
    id: '8',
    vendorId: 'aseda-pastries',
    name: 'Glazed Ring Donuts Box (4 pcs)',
    description: 'Soft pillowy donuts with sweet vanilla glaze and chocolate sprinkles',
    price: 28.0,
    imageAsset: 'assets/images/snacks and pastries/Donuts.jpg',
    categoryId: 'snacks',
    rating: 4.8,
    prepTimeMinutes: 10,
    badgeText: 'SWEET TREAT',
    tags: ['Sweet', 'Bakery', 'Dessert'],
    isAvailable: true,
  },
  {
    id: '9',
    vendorId: 'aseda-pastries',
    name: 'Crispy Spring Rolls Platter (4 pcs)',
    description: 'Golden crunchy spring rolls filled with seasoned veggies and minced chicken with chili dip',
    price: 20.0,
    imageAsset: 'assets/images/snacks and pastries/spring_rolls.jpg',
    categoryId: 'snacks',
    rating: 4.7,
    prepTimeMinutes: 15,
    badgeText: 'CRUNCHY',
    tags: ['Finger Food', 'Appetizer'],
    isAvailable: true,
  },
  {
    id: '10',
    vendorId: 'aseda-pastries',
    name: 'Chilled Zesty Sobolo Juice (500ml Bottle)',
    description: 'Infused natural hibiscus flowers with fresh pineapple, ginger, cloves and mint leaves served ice cold',
    price: 10.0,
    imageAsset: 'assets/images/snacks and pastries/Sobolo Juice.jpg',
    categoryId: 'drinks',
    rating: 4.9,
    prepTimeMinutes: 5,
    badgeText: '100% NATURAL',
    tags: ['Cold', 'Immunity', 'Local Favorite'],
    isAvailable: true,
  },
  {
    id: '11',
    vendorId: 'aseda-pastries',
    name: 'Fresh Mango Tropical Smoothie (500ml)',
    description: 'Blended ripe Ghanaian mangoes, passion fruit, honey and Greek yogurt',
    price: 18.0,
    imageAsset: 'assets/images/snacks and pastries/smoothies.jpg',
    categoryId: 'drinks',
    rating: 4.8,
    prepTimeMinutes: 8,
    badgeText: 'FRUIT FRESH',
    tags: ['Healthy', 'Vitamins', 'Smoothie'],
    isAvailable: true,
  },
  {
    id: '12',
    vendorId: 'aseda-pastries',
    name: 'Creamy Strawberry Milkshake',
    description: 'Rich whole milk, wild strawberry puree and vanilla ice cream topped with whipped cream',
    price: 20.0,
    imageAsset: 'assets/images/snacks and pastries/Milkshake.jpg',
    categoryId: 'drinks',
    rating: 4.8,
    prepTimeMinutes: 8,
    badgeText: 'CREAMY',
    tags: ['Chilled', 'Dessert Drink'],
    isAvailable: true,
  },
  {
    id: '13',
    vendorId: 'aseda-pastries',
    name: 'Heineken Cold Premium Beer (330ml Can)',
    description: 'Crisp, refreshing European lager beer chilled to perfection',
    price: 16.0,
    imageAsset: 'assets/images/wines and drinks/Heineken.jpg',
    categoryId: 'drinks',
    rating: 4.9,
    prepTimeMinutes: 5,
    badgeText: 'CHILLED',
    tags: ['Beer', 'Alcoholic', 'Canned'],
    isAvailable: true,
  },
  {
    id: '14',
    vendorId: 'aseda-pastries',
    name: 'Guinness Extra Stout (330ml Can)',
    description: 'Full-bodied dark stout brewed with roasted barley and hops',
    price: 15.0,
    imageAsset: 'assets/images/wines and drinks/guinness.jpg',
    categoryId: 'drinks',
    rating: 4.8,
    prepTimeMinutes: 5,
    badgeText: 'COLD STOUT',
    tags: ['Stout', 'Alcoholic'],
    isAvailable: true,
  },
  {
    id: '15',
    vendorId: 'aseda-pastries',
    name: 'Don Simon Sangria Wine (1L Carton)',
    description: 'Traditional Spanish red wine sangria flavored with natural citrus fruits',
    price: 35.0,
    imageAsset: 'assets/images/wines and drinks/Don Simon.jpg',
    categoryId: 'drinks',
    rating: 4.7,
    prepTimeMinutes: 5,
    badgeText: 'WINE',
    tags: ['Wine', 'Party Pack'],
    isAvailable: true,
  },
];

async function seedFirestore() {
  console.log('[Seed] Starting Cloud Firestore population for ClickBite Konongo...');

  const batch = db.batch();

  // 1. Seed Categories
  for (const cat of categories) {
    const docRef = db.collection('categories').doc(cat.id);
    batch.set(docRef, { ...cat, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
  }

  // 2. Seed Vendors
  for (const r of restaurants) {
    const docRef = db.collection('vendors').doc(r.id);
    batch.set(docRef, { ...r, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }

  // 3. Seed Menu Items
  for (const item of menuItems) {
    const docRef = db.collection('menu_items').doc(item.id);
    batch.set(docRef, { ...item, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  }

  await batch.commit();
  console.log(`[Seed] Successfully committed:`);
  console.log(` - ${categories.length} categories`);
  console.log(` - ${restaurants.length} restaurants / vendors`);
  console.log(` - ${menuItems.length} menu items`);
  console.log('[Seed] ClickBite Cloud Firestore is now live and populated!');
}

seedFirestore().catch((err) => {
  console.error('[Seed Error]:', err);
  process.exit(1);
});
