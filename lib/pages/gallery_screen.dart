import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity> _images = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    // 1. 권한 요청
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth && !ps.hasAccess) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
      return;
    }

    // 2. 앨범 목록 가져오기 (최근 항목만)
    // type: RequestType.image (사진만), RequestType.video (비디오만), RequestType.common (둘 다)
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasPermission = true;
      });
      return;
    }

    // 3. 최근 앨범(보통 첫 번째)의 사진들 가져오기 (페이지네이션 없이 일단 80장만 예시로)
    final AssetPathEntity recentAlbum = albums.first;
    final List<AssetEntity> images = await recentAlbum.getAssetListPaged(page: 0, size: 80);

    if (mounted) {
      setState(() {
        _images = images;
        _hasPermission = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return const Center(child: Text("갤러리 접근 권한이 필요합니다."));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return const Center(child: Text("사진이 없습니다."));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("갤러리", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 한 줄에 3개
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return _GalleryItem(asset: _images[index]);
        },
      ),
    );
  }
}

// 개별 사진 아이템 위젯 (썸네일 로딩 최적화)
class _GalleryItem extends StatelessWidget {
  final AssetEntity asset;

  const _GalleryItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)), // 썸네일 크기 지정
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return GestureDetector(
            onTap: () {
              // TODO: 사진 클릭 시 동작 (예: 전체 화면 보기, 선택 반환 등)
              print("사진 클릭됨: ${asset.id}");
            },
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
        }
        // 로딩 중일 때 보여줄 위젯
        return Container(color: Colors.grey[200]);
      },
    );
  }
}