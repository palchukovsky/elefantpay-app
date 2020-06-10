import 'package:url_launcher/url_launcher.dart';

writeEmail(String address) async {
  address = 'mailto:' + address;
  if (await canLaunch(address)) {
    launch(address);
  }
}
