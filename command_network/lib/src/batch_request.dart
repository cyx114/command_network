import 'base_request.dart';


class BatchRequest {
  BatchRequest(this.requestList);

  final List<BaseRequest> requestList;

  Future<Result> start() async {
    await Future.wait(
        [for (BaseRequest request in requestList) request.start()]);
    bool isSuccess = true;
    for (BaseRequest request in requestList) {
      if (!request.result.isSuccess) {
        isSuccess = false;
        break;
      }
    }
    return Result(isSuccess);
  }

  void stop() async {
    for (BaseRequest request in requestList) {
      request.stop();
    }
  }

}
