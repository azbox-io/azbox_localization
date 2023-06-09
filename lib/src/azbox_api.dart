
import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:azbox/azbox.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/response_status_code.dart';

const _apiURL = "https://api.azbox.io/";

const _getProjects = "v1/projects";
const _getKeywords = "v1/projects/{projectId}/keywords";

class AzboxAPI {

  /// The AZbox API Key.
  /// create it here https://azbox.io/
  final String _apiKey;

  /// The project Id associated with your project.
  final String _project;

  /// Provides an instance of this class.
  /// The instance of the class created with this constructor will send the events on the fly.
  /// [apiKey] is the AZbox API Key.
  /// [project] is the project Id associated with your project.
  AzboxAPI({
    required String apiKey,
    required String project,
  }) : _apiKey = apiKey,
       _project = project;

  String get projectId => _project;

  Future<Result<void>> projects() async {
    var headers = <String, String>{};
    headers['Content-Type'] = 'application/json';

    try {
      final response = await http.get(
        Uri.parse('$_apiURL$_getProjects?token=$_apiKey'),
        headers: headers,
      );

      if (ResponseStatusCode.SUCCESS_CODES.contains(response.statusCode)) {
        final List<dynamic> body = json.decode(response.body);
        return Result<List<dynamic>>.value(body);
      } else if (ResponseStatusCode.ERROR_CODES.contains(response.statusCode)) {
        final Map<String, dynamic> body = json.decode(response.body);
        return Result<void>.error(
            body['errors'].map((e) => AZError.fromJson(e)));
      } else {
        return Result<void>.error(
          [
            AZError(message: 'Status Code: ${response.statusCode}'),
          ],
        );
      }
    } catch (e) {
      return Result<void>.error([
          AZError(message: 'Error : ${e}'),
        ]);
    }
  }

  Future<Result<void>> keywords({required String projectId, required String language}) async {
    if (projectId.isNotEmpty) {
      var headers = <String, String>{};
      headers['Content-Type'] = 'application/json';

      try {
        final response = await http.get(
          Uri.parse('$_apiURL${_getKeywords.replaceAll("{projectId}", projectId)}?token=$_apiKey&language=$language'
          ),
          headers: headers,
        );

        if (kDebugMode) {
          print(response.body);
        }

        if (ResponseStatusCode.SUCCESS_CODES.contains(response.statusCode)) {
          final List<dynamic> body = json.decode(response.body);
          return Result<List<dynamic>>.value(body);
        } else if (ResponseStatusCode.ERROR_CODES.contains(response.statusCode)) {
          final Map<String, dynamic> body = json.decode(response.body);
          return Result<void>.error(
              body['errors'].map((e) => AZError.fromJson(e)));
        } else {
          return Result<void>.error([
              AZError(message: 'Status Code: ${response.statusCode}'),
            ],
          );
        }
      } catch (e) {
        return Result<void>.error([
            AZError(message: 'Error : ${e}'),
          ]);
      }
    } else {
      return Result<void>.value({});
    }
  }

  Future<List<dynamic>> getProjects() async {
    var prjects = (await projects()) as ValueResult;

    if (prjects.isValue) {
      return prjects.value;
    }
    return [];
  }

  Future<Map<String, dynamic>> getKeywords({required String language}) async {
    var projectsResult = (await keywords(projectId:_project, language: language)) as ValueResult;

    if (projectsResult.isValue) {
      List<dynamic> projectList = projectsResult.value;
      Map<String, dynamic> projects = {};
      for (var project in projectList) {
        project['data']['id'] = project['id'];
        projects[project['data']['keyword']] = project['data'];
      }
      return projects;
    }
    return {};
  }
}