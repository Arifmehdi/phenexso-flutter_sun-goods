import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sungoods/models/slider_image.dart';
import 'package:sungoods/services/slider_service.dart';
import 'package:sungoods/services/database_service.dart';

class SliderProvider with ChangeNotifier {
  final SliderService? _sliderService;
  final DatabaseService _dbService = DatabaseService();

  List<SliderImage> _apiSliders = [];
  List<SliderImage> _localSliders = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Toggle for API vs Local
  bool _isApiEnabled = false;

  SliderProvider(this._sliderService) {
    _loadLocalSliders();
  }

  List<SliderImage> get sliders => _isApiEnabled ? _apiSliders : _localSliders;
  
  // Return active sliders based on the current mode
  List<SliderImage> get activeSliders => 
      (_isApiEnabled ? _apiSliders : _localSliders).where((s) => s.status == 1).toList();
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isApiEnabled => _isApiEnabled;

  void setApiEnabled(bool value) {
    _isApiEnabled = value;
    notifyListeners();
    if (_isApiEnabled && _apiSliders.isEmpty) {
      fetchSliders();
    }
  }

  Future<void> _loadLocalSliders() async {
    _localSliders = await _dbService.getSliders();
    notifyListeners();
  }

  Future<void> fetchSliders() async {
    if (!_isApiEnabled) {
      await _loadLocalSliders();
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _apiSliders = await _sliderService!.fetchSliders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSlider({required dynamic image, String? title, String? link}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_isApiEnabled) {
        await _sliderService!.addSlider(image: image as File, title: title, link: link);
        await fetchSliders();
      } else {
        // If it's a file, we should probably save it to local storage first,
        // but for now let's just use the path as imageUrl
        String imageUrl = (image is File) ? image.path : image.toString();
        await _dbService.insertSlider(SliderImage(
          id: 0, 
          imageUrl: imageUrl, 
          title: title, 
          link: link, 
          status: 1
        ));
        await _loadLocalSliders();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSlider({
    required int id, 
    dynamic image, 
    String? title, 
    String? link, 
    int? status
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_isApiEnabled) {
        final updated = await _sliderService!.updateSlider(
          id: id, 
          image: image as File?, 
          title: title, 
          link: link, 
          status: status
        );
        final index = _apiSliders.indexWhere((s) => s.id == id);
        if (index != -1) _apiSliders[index] = updated;
      } else {
        final existing = _localSliders.firstWhere((s) => s.id == id);
        String imageUrl = image != null 
            ? (image is File ? image.path : image.toString()) 
            : existing.imageUrl;

        final updated = SliderImage(
          id: id,
          imageUrl: imageUrl,
          title: title ?? existing.title,
          link: link ?? existing.link,
          status: status ?? existing.status,
        );
        await _dbService.updateSlider(updated);
        await _loadLocalSliders();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSliderVisibility(SliderImage slider) async {
    final newStatus = slider.status == 1 ? 0 : 1;
    await updateSlider(id: slider.id, status: newStatus);
  }

  Future<void> deleteSlider(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_isApiEnabled) {
        await _sliderService!.deleteSlider(id);
        _apiSliders.removeWhere((s) => s.id == id);
      } else {
        await _dbService.deleteSlider(id);
        _localSliders.removeWhere((s) => s.id == id);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
