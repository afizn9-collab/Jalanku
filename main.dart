import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const JalanKuApp());

class JalanKuApp extends StatelessWidget {
  const JalanKuApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'JalanKu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF087F5B), useMaterial3: true),
        home: const JalanKuHome(),
      );
}

class JalanKuHome extends StatefulWidget {
  const JalanKuHome({super.key});

  @override
  State<JalanKuHome> createState() => _JalanKuHomeState();
}

class _JalanKuHomeState extends State<JalanKuHome> {
  static const LatLng _fallback = LatLng(2.8125, 102.4047);
  GoogleMapController? _mapController;
  final TextEditingController _destination = TextEditingController();
  LatLng _current = _fallback;
  bool _locating = false;
  String _status = 'Cari destinasi untuk mula perjalanan.';
  final Set<Marker> _reports = {};

  @override
  void dispose() {
    _destination.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _locateMe() async {
    setState(() { _locating = true; _status = 'Mendapatkan lokasi...'; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _status = 'Hidupkan Location/GPS pada telefon anda.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _status = 'Kebenaran lokasi diperlukan untuk mencari kedudukan anda.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _current = LatLng(position.latitude, position.longitude);
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_current, 16));
      if (mounted) setState(() => _status = 'Lokasi anda dikemas kini.');
    } catch (_) {
      if (mounted) setState(() => _status = 'Tidak dapat mendapatkan lokasi. Cuba lagi.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _navigate() async {
    final query = _destination.text.trim();
    if (query.isEmpty) { setState(() => _status = 'Masukkan destinasi dahulu.'); return; }
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) throw Exception('not found');
      final target = locations.first;
      final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${_current.latitude},${_current.longitude}&destination=${target.latitude},${target.longitude}&travelmode=driving');
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw Exception('launch failed');
      if (mounted) setState(() => _status = 'Membuka arah perjalanan dalam Google Maps.');
    } catch (_) {
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _status = 'Membuka carian destinasi dalam Google Maps.');
    }
  }

  void _report() {
    setState(() {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      _reports.add(Marker(markerId: MarkerId(id), position: _current, infoWindow: const InfoWindow(title: 'Laporan komuniti', snippet: 'Laporan contoh pada peranti ini')));
      _status = 'Penanda laporan contoh ditambah pada peta ini.';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('JalanKu'), actions: [IconButton(tooltip: 'Lokasi saya', onPressed: _locating ? null : _locateMe, icon: const Icon(Icons.my_location))]),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            TextField(controller: _destination, textInputAction: TextInputAction.search, onSubmitted: (_) => _navigate(), decoration: InputDecoration(hintText: 'Ke mana anda mahu pergi?', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder(), suffixIcon: IconButton(onPressed: _navigate, icon: const Icon(Icons.directions)))),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: FilledButton.icon(onPressed: _navigate, icon: const Icon(Icons.navigation), label: const Text('Mula navigasi'))), const SizedBox(width: 8), OutlinedButton.icon(onPressed: _report, icon: const Icon(Icons.campaign_outlined), label: const Text('Lapor'))]),
            Align(alignment: Alignment.centerLeft, child: Text(_status, style: Theme.of(context).textTheme.bodySmall)),
          ])),
          Expanded(child: GoogleMap(initialCameraPosition: const CameraPosition(target: _fallback, zoom: 12), myLocationEnabled: true, myLocationButtonEnabled: false, markers: _reports, onMapCreated: (controller) => _mapController = controller, onTap: (point) => setState(() { _reports.add(Marker(markerId: MarkerId('pin-${point.latitude}-${point.longitude}'), position: point, infoWindow: const InfoWindow(title: 'Penanda peta'))); }))),
        ]),
      );
}
