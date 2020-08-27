// This source code is a part of Project Violet.
// Copyright (C) 2020. rollrat. Licensed under the MIT License.

// You can found another style downloader from this link
// https://github.com/project-violet/violet/tree/70541144c22cd91eee8a00ca99dd80e0d666c43f/lib/pages/download/downloader
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

// import 'package:communitydownloader/component/external/youtude-dl.dart';
// import 'package:communitydownloader/log/log.dart';
// import 'package:device_info/device_info.dart';
import 'package:communityexplorer/download/download_task.dart';
import 'package:communityexplorer/log/log.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart' as sync;
import 'package:path_provider/path_provider.dart';
// import 'package:communitydownloader/component/downloadable.dart';

typedef downloader_init = Void Function(Int64);
typedef DownloaderInit = void Function(int queueSize);
typedef downloader_dispose = Void Function();
typedef DownloaderDispose = void Function();
typedef downloader_status = Pointer<Utf8> Function();
typedef DownloaderStatus = Pointer<Utf8> Function();
typedef downloader_append = Pointer<Utf8> Function(Pointer<Utf8>);
typedef DownloaderAppend = Pointer<Utf8> Function(Pointer<Utf8> downloadInfo);
typedef downloader_change_thread_count = Int64 Function(Int64);
typedef DownloaderChangeThreadCount = int Function(int thread_count);

class NativeDownloadTask {
  final int id;
  final String url;
  final String fullpath;
  final Map<String, dynamic> header;

  NativeDownloadTask({this.id, this.url, this.fullpath, this.header});

  static NativeDownloadTask fromDownloadTask(int taskId, DownloadTask task) {
    var header = Map<String, String>();
    if (task.referer != null) header['referer'] = task.referer;
    if (task.accept != null) header['accept'] = task.accept;
    if (task.userAgent != null) header['user-agent'] = task.userAgent;
    if (task.headers != null) {
      task.headers.entries.forEach((element) {
        header[element.key.toLowerCase()] = element.value;
      });
    }
    return NativeDownloadTask(
      id: taskId,
      url: task.url,
      fullpath: task.downloadPath,
      header: header,
    );
  }

  String toString() {
    return jsonEncode({
      "id": id,
      "url": url,
      "fullpath": fullpath,
      "header": header,
    });
  }
}

class NativeDownloader {
  DynamicLibrary libviolet;
  DownloaderInit downloaderInit;
  DownloaderDispose downloaderDispose;
  DownloaderStatus downloaderStatus;
  DownloaderAppend downloaderAppend;
  DownloaderChangeThreadCount downloaderChangeThreadCount;
  List<DownloadTask> downloadTasks = List<DownloadTask>();

  sync.Lock lock = sync.Lock();

  static const platform =
      const MethodChannel('xyz.violet.communityexplorer/nativelibdir');
  static Directory nativeDir;

  static Future<Directory> getLibraryDirectory() async {
    if (nativeDir != null) return nativeDir;
    final String result = await platform.invokeMethod('getNativeDir');
    nativeDir = Directory(result);
    return nativeDir;
  }

  Future<void> init() async {
    var libdir = await getLibraryDirectory();
    libviolet = DynamicLibrary.open(join(libdir.path, 'libviolet.so'));

    downloaderInit = libviolet
        .lookup<NativeFunction<downloader_init>>("downloader_init")
        .asFunction();
    downloaderDispose = libviolet
        .lookup<NativeFunction<downloader_dispose>>("downloader_dispose")
        .asFunction();
    downloaderStatus = libviolet
        .lookup<NativeFunction<downloader_status>>("downloader_status")
        .asFunction();
    downloaderAppend = libviolet
        .lookup<NativeFunction<downloader_append>>("downloader_append")
        .asFunction();
    downloaderChangeThreadCount = libviolet
        .lookup<NativeFunction<downloader_change_thread_count>>(
            "downloader_change_thread_count")
        .asFunction();

    downloaderInit(16);
  }

  static NativeDownloader _instance;
  static Future<NativeDownloader> getInstance() async {
    if (_instance == null) {
      _instance = NativeDownloader();
      await _instance.init();
    }

    return _instance;
  }

  NativeDownloader() {
    Future.delayed(Duration(seconds: 1)).then((value) async {
      while (true) {
        var x = Utf8.fromUtf8(downloaderStatus());
        var ll = x.split('|');
        if (ll.length == 5) {
          var complete = ll.last.split(',');
          complete.forEach((element) {
            int v = int.tryParse(element);
            if (v != null) {
              downloadTasks[v].completeCallback();
            }
          });
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
    });
  }

  Future<bool> tryChangeThreadCount(int cc) async {
    return downloaderChangeThreadCount(cc) != -1;
  }

  Future<void> addTask(DownloadTask task) async {
    await lock.synchronized(() {
      downloadTasks.add(task);
      downloaderAppend(Utf8.toUtf8(
          NativeDownloadTask.fromDownloadTask(downloadTasks.length, task)
              .toString()));
    });
  }

  Future<void> addTasks(List<DownloadTask> tasks) async {
    await lock.synchronized(() {
      tasks.forEach((task) {
        downloadTasks.add(task);
        downloaderAppend(Utf8.toUtf8(
            NativeDownloadTask.fromDownloadTask(downloadTasks.length - 1, task)
                .toString()));
      });
    });
  }
}
