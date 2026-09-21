import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildingInfo {
  const BuildingInfo({
    required this.name,
    required this.imageUrl,
    required this.mapUrl,
  });

  final String name;
  final String imageUrl;
  final String mapUrl;
}

class BuildingPage extends StatelessWidget {
  const BuildingPage({super.key});

  static const buildings = [
    BuildingInfo(
      name: 'อาคารเรียนรวม 2 (LH2)',
      imageUrl: 'assets/images/LH2.jpg',
      mapUrl: 'https://maps.app.goo.gl/81MV7YGpoT1YhxKb8',
    ),
    BuildingInfo(
      name: 'อาคารเรียนรวม 3 (LH3)',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfYI1zsolT4KIvlu14Dm7COKizKpjMaIbqn5doMOVK5KDdlr_f4LHO1gI2&s=10',
      mapUrl: 'https://maps.app.goo.gl/VdApfbTfW2kiv6Qc9',
    ),
    BuildingInfo(
      name: 'อาคารเรียนรวม 4 (LH4)',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStfHaOiESY9PVHxWLciqLk9AiE93L_LG83wP5GbembZ1hHDi1cLzjhFMk&s=10',
      mapUrl: 'https://maps.app.goo.gl/WhNqz5sUz9bmnEeF6',
    ),
    BuildingInfo(
      name: 'คณะศิลปศาสตร์และวิทยาศาสตร์ (SC-9)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471261938_1344420683388681_6147408286617002131_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=100&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=ovuXhAeshKcQ7kNvwELjvUg&_nc_oc=AdpTB2yNnAh9LjMDIljuxqqUevuFTqrCESlg8HiAZEPfw4o5ICBp81lbCJuLQl3OKTw&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=3za7DbgtzRXp665UMXhCKA&_nc_ss=7b2a8&oh=00_AQLrHL5bvmhsROXbwDA7j-hn88Fe1z1RrqDaXfSEXJ8B1A&oe=6AB48729',
      mapUrl: 'https://maps.app.goo.gl/gnC5Du3jBgW7QrBu9',
    ),
    BuildingInfo(
      name: 'อาคารเทคโนโลยีสารสนเทศ (IT)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471261674_1344420673388682_8266805906638255804_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=103&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=pa3UMLEW3gUQ7kNvwENkOlT&_nc_oc=Adqjzh4Uzt88-_-OwaOn-4o8thR6HtZM-kvizD2tBEXKDk0B3Iy4CRgz3NrUS0BZJHo&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=hfTy9_hUcMLoB6KHnmOTCA&_nc_ss=7b2a8&oh=00_AQKXNrxa1LqN0exRYDDZP6sDwV78_uCMdgSNX5ixs55vlg&oe=6AB47162',
      mapUrl: 'https://maps.app.goo.gl/bCnpJ5AzFNwsvoCy7',
    ),
    BuildingInfo(
      name: 'อาคารการเรียนรู้ทางภาษา (LLB)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471248131_1344420686722014_3974510809591307143_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=100&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=tiBAT7d_E3QQ7kNvwG5rLkM&_nc_oc=AdpPDP-5FQGbAGkFdbbfnw12OeQP-_ThFAcICnRcpWKEuYEXNkRmHgOyc8wMVZteuN4&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=nFWK3Ikoo6_QBqGqJ6qUIA&_nc_ss=7b2a8&oh=00_AQL2EY__rriYhJbFEvzBEoA6FH5O51AnwYOdpjkkVKEl9w&oe=6AB48BE7',
      mapUrl: 'https://maps.app.goo.gl/m3GRBaW9tWhaBiYaA',
    ),
    BuildingInfo(
      name: 'อาคารปฏิบัติการวิทยาศาสตร์พื้นฐานทั่วไป (SC-14)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471345067_1344420736722009_3993681858642500217_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=107&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=pKxCioqZEtcQ7kNvwGylXdK&_nc_oc=Adrj0co90JyiPRSZcnwPqT5yvifZk1yXm-Z2-ypqJWs4z4KQuCblS3tqFJ1MkYMj6pg&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=fKueUmR-OAadqIX2TpybEQ&_nc_ss=7b2a8&oh=00_AQIplXe2FIpFFD-GTBhaUg27qldwFK18jojNJwQmoo6rtw&oe=6AB484B7',
      mapUrl: 'https://maps.app.goo.gl/q7ewWtNoDcHxDQ6o6',
    ),
    BuildingInfo(
      name: 'อาคาร (SC-2)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471473889_1344420730055343_7569208340167241051_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=102&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=aebaszfQ4VQQ7kNvwGi2ORc&_nc_oc=AdqM8Kp9KfruGsaw5UJ53wYM3UmUaFsYl3XiIqFCAU97wU5qZD9ApEFQ3fdft0xgTd4&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=TcDrtIiGIn60uYrDKHbN2A&_nc_ss=7b2a8&oh=00_AQIRAmOXChOx7Qd5IkRHNRibxAdQQj4A1pLbt50YcAIcZw&oe=6AB48FEA',
      mapUrl: 'https://maps.app.goo.gl/3SYFPFu7ivU3kxdD8',
    ),
    BuildingInfo(
      name: 'อาคารปฏิบัติการวิทยาศาสตร์ทั่วไป (SC-1)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/471052444_1344420810055335_1342636663253121784_n.jpg?stp=dst-jpg_tt6&cstp=mx1200x800&ctp=s1200x800&_nc_cat=108&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=fz1CO6BAxCkQ7kNvwHFGm3e&_nc_oc=Adr0YtU9psgcfBNhOkk9nmc2ZOI8X9WwzRy5q-CdyE7mqouPtcVddgrEr76vAYALsFM&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=o54nvK6S2SVBjtH1M6bKeQ&_nc_ss=7b2a8&oh=00_AQK8sKAOFFu3nqkM73rBXKGT8NQhRvxxBCceId8qVk2Gzw&oe=6AB490D8',
      mapUrl: 'https://maps.app.goo.gl/A3Lo2Kai4hueHi7i6',
    ),
    BuildingInfo(
      name: 'ห้องคอนเวนชั่น ม.เกษตร(กำแพงแสน)',
      imageUrl:
          'assets/images/ConvanHall.jpg',
      mapUrl: 'https://maps.app.goo.gl/24bdJFVcsm8UzCWP6',
    ),
    BuildingInfo(
      name: 'อาคาร 80 ปี (KH80)',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3rFs623qLaI2S8elGti9RpDkHCcZ2C1dB1ufQdmsD9fbV67Hgx8Ie0pM&s=10',
      mapUrl: 'https://maps.app.goo.gl/skPoBMiG7NLKaLoAA',
    ),
    BuildingInfo(
      name: 'ตึกอุตสาหกรรมบริการ (ตึกรุ้ง)',
      imageUrl:
          'assets/images/HI.jpg',
      mapUrl: 'https://maps.app.goo.gl/ER4wJH4ddWwPnQrp7',
    ),
    BuildingInfo(
      name: 'ตึกคณะวิทยาศาสตร์การกีฬาและสุขภาพ',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTDZmzOWk47Tnd0zZ9dsO9hmaVTKoydMCG7UcxQUQvGmTAttwx6I1gafi8&s=10',
      mapUrl: 'https://maps.app.goo.gl/W97oLgryiPjAHPSX8',
    ),
    BuildingInfo(
      name: 'ตึกคณะศึกษาศาสตร์และพัฒนศาสตร์ (EDS1)',
      imageUrl:
          'https://scontent.fkdt2-1.fna.fbcdn.net/v/t39.30808-6/540832401_1372653871534730_5501261249277809129_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x1536&ctp=s2048x1536&_nc_cat=110&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_ohc=sEo9bWbblsIQ7kNvwHZGDeb&_nc_oc=Adq4HUEGW8UZmGHBuFb3qHdAeFcNFWB2NRJk39RDS152jhE9ffIFH0e9L8ccmbXRcCo&_nc_zt=23&_nc_ht=scontent.fkdt2-1.fna&_nc_gid=WEkmzl6s6qQnKKUzoIbxbA&_nc_ss=7b2a8&oh=00_AQJyZa5Q29I1ycJkSV3BLj8o_Q3Q-nTj8Yww8ntVEjZ3YQ&oe=6AB69951',
      mapUrl: 'https://maps.app.goo.gl/W9vkf4pgFvaFk9FWA',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตึกเรียน')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: buildings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) =>
            BuildingCard(building: buildings[index]),
      ),
    );
  }
}

class BuildingCard extends StatelessWidget {
  const BuildingCard({super.key, required this.building});

  final BuildingInfo building;

  Future<void> _openMap(BuildContext context) async {
    final uri = Uri.parse(building.mapUrl);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildBuildingImage(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    building.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                  IconButton.filled(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 30,
                    ),
                  tooltip: 'เปิดใน Google Maps',
                  onPressed: () => _openMap(context),
                  icon: const Icon(Icons.location_on_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingImage() {
    final fallback = const ColoredBox(
      color: Color(0xffdbe2ef),
      child: Icon(Icons.business, size: 64),
    );

    if (building.imageUrl.startsWith('assets/')) {
      return Image.asset(
        building.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.network(
      building.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}