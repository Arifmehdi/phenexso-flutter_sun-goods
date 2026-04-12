class Shipment {
  final String id;
  final String trackingNumber;
  final String carrier;
  final DateTime shipmentDate;
  final DateTime? deliveryDate;
  final String status;
  final String origin;
  final String destination;
  final List<String> orderIds; // To link with Order

  Shipment({
    required this.id,
    required this.trackingNumber,
    required this.carrier,
    required this.shipmentDate,
    this.deliveryDate,
    required this.status,
    required this.origin,
    required this.destination,
    required this.orderIds,
  });
}
