import '../../../models/tv_app.dart';

/// Curated list of popular apps for Samsung Tizen TVs.
///
/// Tizen doesn't expose a reliable "list installed apps" API over the
/// remote-control WebSocket, so the Tizen controller's `listApps` returns
/// `null` and callers fall back to this static catalog. App IDs are launched
/// via `ms.channel.emit` / `ed.apps.launch` regardless of whether they're
/// actually installed - launching an app that isn't installed typically
/// opens its page in the TV's app store instead.
const tizenAppCatalog = <TvApp>[
  TvApp(id: '11101200001', name: 'Netflix'),
  TvApp(id: '111299001912', name: 'YouTube'),
  TvApp(id: '3201512006785', name: 'Prime Video'),
  TvApp(id: '3201901017640', name: 'Disney+'),
  TvApp(id: '3201601007625', name: 'Hulu'),
  TvApp(id: '3201606009684', name: 'Spotify'),
  TvApp(id: '3201807016597', name: 'Apple TV'),
  TvApp(id: '3201910019365', name: 'HBO Max'),
  TvApp(id: '3201512006963', name: 'Plex'),
];
