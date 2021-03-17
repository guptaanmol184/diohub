import 'package:dio/dio.dart';
import 'package:onehub/app/Dio/cache.dart';
import 'package:onehub/app/Dio/dio.dart';
import 'package:onehub/models/commits/commit_model.dart';
import 'package:onehub/models/pull_requests/pull_request_model.dart';
import 'package:onehub/models/pull_requests/review_model.dart';
import 'package:onehub/models/repositories/commit_list_model.dart';

class PullsService {
  // Ref: https://docs.github.com/en/rest/reference/pulls#get-a-pull-request
  static Future<PullRequestModel> getPullInformation({String fullUrl}) async {
    Response response = await GetDio.getDio(
            applyBaseURL: false, options: CacheManager.defaultCache())
        .get(fullUrl);
    return PullRequestModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/pulls#list-reviews-for-a-pull-request
  static Future<ReviewModel> getPullReviews({String fullUrl}) async {
    Response response = await GetDio.getDio(
            applyBaseURL: false, options: CacheManager.defaultCache())
        .get(fullUrl + '/reviews');
    return ReviewModel.fromJson(response.data);
  }

  // Ref: https://docs.github.com/en/rest/reference/pulls#list-pull-requests
  static Future<List<PullRequestModel>> getRepoPulls(
    String repoURL, {
    int perPage,
    int pageNumber,
    bool refresh,
  }) async {
    Response response = await GetDio.getDio(
            options: CacheManager.defaultCache(refresh: refresh))
        .get('$repoURL/pulls', queryParameters: {
      'per_page': perPage,
      'page': pageNumber,
      'sort': 'popularity',
      'state': 'all',
      'direction': 'desc',
    });
    List unParsedData = response.data;
    List<PullRequestModel> parsedData =
        unParsedData.map((e) => PullRequestModel.fromJson(e)).toList();
    return parsedData;
  }

  // Ref: https://docs.github.com/en/rest/reference/pulls#list-commits-on-a-pull-request
  static Future<List<CommitListModel>> getPullCommits(
    String pullURL, {
    int perPage,
    int pageNumber,
    bool refresh,
  }) async {
    Response response = await GetDio.getDio(
            options: CacheManager.defaultCache(refresh: refresh))
        .get(
      '$pullURL/commits',
      queryParameters: {
        'per_page': perPage,
        'page': pageNumber,
      },
    );
    List unParsedData = response.data;
    List<CommitListModel> parsedData =
        unParsedData.map((e) => CommitListModel.fromJson(e)).toList();
    return parsedData;
  }

  // Ref: https://docs.github.com/en/rest/reference/pulls#list-pull-requests-files
  static Future<List<FileElement>> getPullFiles(
    String pullURL, {
    int perPage,
    int pageNumber,
    bool refresh,
  }) async {
    Response response = await GetDio.getDio(
            options: CacheManager.defaultCache(refresh: refresh))
        .get('$pullURL/files', queryParameters: {
      'per_page': perPage,
      'page': pageNumber,
    });
    List unParsedData = response.data;
    List<FileElement> parsedData =
        unParsedData.map((e) => FileElement.fromJson(e)).toList();
    return parsedData;
  }
}
