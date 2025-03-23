// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FormData {
  final int n;
  final int p;
  final int k;
  final double temperature;
  final double humidity;
  final double ph;
  final double rainfall;

  FormData({
    required this.n,
    required this.p,
    required this.k,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.rainfall,
  });

  FormData copyWith({
    int? n,
    int? p,
    int? k,
    double? temperature,
    double? humidity,
    double? ph,
    double? rainfall,
  }) {
    return FormData(
      n: n ?? this.n,
      p: p ?? this.p,
      k: k ?? this.k,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      ph: ph ?? this.ph,
      rainfall: rainfall ?? this.rainfall,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'n': n,
      'p': p,
      'k': k,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'rainfall': rainfall,
    };
  }

  factory FormData.fromMap(Map<String, dynamic> map) {
    return FormData(
      n: map['Nitrogen(N)'] as int,
      p: map['Phosphorus(P)'] as int,
      k: map['Potassium(K)'] as int,
      temperature: map['Temperature'] as double,
      humidity: map['Humidity'] as double,
      ph: map['pH'] as double,
      rainfall: map['Rainfall'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormData.fromJson(String source) =>
      FormData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FormData(n: $n, p: $p, k: $k, temperature: $temperature, humidity: $humidity, ph: $ph, rainfall: $rainfall)';
  }

  @override
  bool operator ==(covariant FormData other) {
    if (identical(this, other)) return true;

    return other.n == n &&
        other.p == p &&
        other.k == k &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.ph == ph &&
        other.rainfall == rainfall;
  }

  @override
  int get hashCode {
    return n.hashCode ^
        p.hashCode ^
        k.hashCode ^
        temperature.hashCode ^
        humidity.hashCode ^
        ph.hashCode ^
        rainfall.hashCode;
  }
}
