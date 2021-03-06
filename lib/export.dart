import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klipr/models/ffmpeg.dart';

import 'package:provider/provider.dart';

import 'models/video.dart';

class Export extends StatefulWidget {
  final void Function(double size) onExport;

  const Export({Key? key, required this.onExport}) : super(key: key);

  @override
  State<Export> createState() => _ExportState();
}

class _ExportState extends State<Export> {
  double _size = 8;
  double _other = 0;

  final GlobalKey _inputKey = GlobalKey();

  void _onChanged(double? value) {
    if (value == null) return;
    setState(() {
      _size = value;
    });
  }

  Widget sizeTile(double size) {
    return RadioListTile<double>(
      title: Text(size.toStringAsFixed(0) + " MB"),
      value: size,
      groupValue: _size,
      onChanged: _onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    var video = Provider.of<VideoModel>(context, listen: true);
    return Column(children: [
      sizeTile(8),
      sizeTile(50),
      sizeTile(100),
      InkWell(
        onTap: () {
          if (-1 != _size) {
            _onChanged(-1);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: <Widget>[
              Radio<double>(
                groupValue: _size,
                value: -1,
                onChanged: _onChanged,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  key: _inputKey,
                  enabled: _size == -1,
                  onTap: () => _onChanged(-1),
                  onChanged: (val) {
                    setState(() {
                      _other = double.parse(val);
                    });
                  },
                  decoration:
                      const InputDecoration(hintText: "Enter size (MB)"),
                ),
              )),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Consumer<FFmpeg>(
          builder: (context, ffmpeg, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                      onPressed: video.path == null
                          ? null
                          : () {
                              if (ffmpeg.isRunning) {
                                ffmpeg.cancel();
                              } else {
                                widget.onExport(_size == -1 ? _other : _size);
                              }
                            },
                      child: Text(ffmpeg.isRunning ? "Cancel" : "Export")),
                ),
                LinearProgressIndicator(value: ffmpeg.progress),
              ],
            );
          },
        ),
      )
    ]);
  }
}
