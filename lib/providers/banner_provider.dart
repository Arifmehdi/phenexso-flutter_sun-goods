import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sungoods/models/slider_image.dart';
import 'package:sungoods/services/database_service.dart';

class BannerProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<SliderImage> _banners = [];
  bool _isLoading = false;

  BannerProvider() {
    loadBanners();
  }

  List<SliderImage> get banners => _banners;
  List<SliderImage> get activeBanners => _banners.where((b) => b.status == 1).toList();
  bool get isLoading => _isLoading;

  Future<void> loadBanners() async {
    _isLoading = true;
    notifyListeners();
    _banners = await _dbService.getBanners();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBanner({required dynamic image, String? title, String? link}) async {
    String imageUrl = (image is File) ? image.path : image.toString();
    await _dbService.insertBanner(SliderImage(
      id: 0,
      imageUrl: imageUrl,
      title: title,
      link: link,
      status: 1,
    ));
    await loadBanners();
  }

  Future<void> updateBanner({required int id, dynamic image, String? title, String? link, int? status}) async {
    final existing = _banners.firstWhere((b) => b.id == id);
    String imageUrl = image != null 
        ? (image is File ? image.path : image.toString()) 
        : existing.imageUrl;

    await _dbService.updateBanner(SliderImage(
      id: id,
      imageUrl: imageUrl,
      title: title ?? existing.title,
      link: link ?? existing.link,
      status: status ?? existing.status,
    ));
    await loadBanners();
  }

  Future<void> toggleBannerVisibility(SliderImage banner) async {
    final newStatus = banner.status == 1 ? 0 : 1;
    await updateBanner(id: banner.id, status: newStatus);
  }

  Future<void> deleteBanner(int id) async {
    await _dbService.deleteBanner(id);
    await loadBanners();
  }
}
