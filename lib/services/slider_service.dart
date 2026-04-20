import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sungoods/utils/api_constants.dart';
import 'package:sungoods/models/slider_image.dart';

class SliderService {
  final String? _authToken;

  SliderService(this._authToken);

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {'Accept': 'application/json'};
    if (_authToken != null && _authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<List<SliderImage>> fetchSliders() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.slidersEndpoint),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> slidersJson = data['data'] ?? [];
        return slidersJson.map((json) => SliderImage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sliders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sliders: $e');
    }
  }

  Future<SliderImage> addSlider({
    required File image,
    String? title,
    String? link,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.slidersEndpoint),
    );

    request.headers.addAll(_getHeaders());
    if (title != null) request.fields['title'] = title;
    if (link != null) request.fields['link'] = link;

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SliderImage.fromJson(data['data'] ?? data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add slider');
    }
  }

  Future<SliderImage> updateSlider({
    required int id,
    File? image,
    String? title,
    String? link,
    int? status,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.slidersEndpoint}/$id'),
    );

    request.headers.addAll(_getHeaders());
    request.fields['_method'] = 'PATCH';
    if (title != null) request.fields['title'] = title;
    if (link != null) request.fields['link'] = link;
    if (status != null) request.fields['status'] = status.toString();

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SliderImage.fromJson(data['data'] ?? data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update slider');
    }
  }

  Future<void> deleteSlider(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.slidersEndpoint}/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete slider: ${response.statusCode}');
    }
  }
}
