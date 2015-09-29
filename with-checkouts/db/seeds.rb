cheese_attributes = [
  { name: 'Gruyere', texture: 'semi-hard', flavour: 'sweet, mild, floral' },
  { name: 'Parmigiano Reggiano', texture: 'hard', flavour: 'sharp, sweet, salty' },
  { name: 'Delice', texture: 'soft', flavour: 'rich, creamy, mild' },
  { name: 'Tallegio', texture: 'soft', flavour: 'strong, mushroom, funky' }
]

camelid_attributes = [
  { name: 'Bactrian Camel', size: 'very large', humps: 2 },
  { name: 'Dromedary', size: 'large', humps: 1 },
  { name: 'Llama', size: 'medium', humps: 0 },
  { name: 'Alpaca', size: 'small', humps: 0 },
  { name: 'Vicuña', size: 'very small', humps: 0 }
]

cheese_attributes.each { |attributes| Cheese.create(attributes) }
camelid_attributes.each { |attributes| Camelid.create(attributes) }
