class PricingCategory {
  final String category;
  final double price;
  final String currency;

  const PricingCategory({
    required this.category,
    required this.price,
    this.currency = 'NGN',
  });
}

class ServiceItem {
  final String name;
  final double? price;
  final String currency;
  final String? unit;
  final String? pricingString;
  final List<PricingCategory>? pricingCategories;

  const ServiceItem({
    required this.name,
    this.price,
    this.currency = 'NGN',
    this.unit,
    this.pricingString,
    this.pricingCategories,
  });

  bool get contactForQuote => pricingString != null;
}

class ServiceCategory {
  final String name;
  final List<String> items;
  final List<ServiceItem> services;

  const ServiceCategory({
    required this.name,
    required this.items,
    required this.services,
  });
}

const List<ServiceCategory> serviceCatalog = [
  ServiceCategory(
    name: 'Automotive',
    items: ['Sedan', 'SUV / Truck', 'Coupe / Sports Car', 'Van'],
    services: [
      ServiceItem(name: 'Ordinary car cleaning service', price: 3000),
      ServiceItem(name: 'Vacuum and pressure washing', price: 4500),
      ServiceItem(name: 'Detailing (general cleaning)', price: 30000),
      ServiceItem(name: 'Steaming engine only', price: 10000),
      ServiceItem(name: 'Under carriage cleaning', price: 10000),
      ServiceItem(name: 'Buffing', price: 10000),
      ServiceItem(name: 'Interior vacuum and polishing', price: 6000),
      ServiceItem(name: 'Exterior only pressure washing', price: 2000),
    ],
  ),
  ServiceCategory(
    name: 'Facility',
    items: [
      'Residential Home',
      'Commercial Office',
      'Industrial/Warehouse',
      'Luxury Estate',
    ],
    services: [
      ServiceItem(
        name: 'Carpet vacuum radaial and pressure washing',
        price: 1200,
        unit: 'per meter square',
      ),
      ServiceItem(
        name: 'House cleaning services',
        pricingString: 'base on inspection',
      ),
      ServiceItem(
        name: 'Metro politant cleaning',
        pricingString: 'base on inspection',
      ),
    ],
  ),
  ServiceCategory(
    name: 'Waste Management',
    items: ['Standard Pick-up', 'Industrial Waste'],
    services: [
      ServiceItem(
        name: 'Waste management services',
        pricingCategories: [
          PricingCategory(category: 'house hold', price: 10000),
          PricingCategory(category: 'Corporate office', price: 25000),
          PricingCategory(category: 'schools', price: 30000),
          PricingCategory(category: 'Hospital', price: 50000),
        ],
      ),
    ],
  ),
];
