// import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:nizcorp_machine_task/core/urls/urls.dart';

class HomeServices {
  final Dio dio = Dio();

  Future<Response> getTask() async {
    Response response = await dio.get(Urls.getTask);
    // log(response.data.toString());
    return response;
  }
}
