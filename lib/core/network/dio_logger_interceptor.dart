import 'package:dio/dio.dart';

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    print('➡️ ${o.method} ${o.uri}');
    print('BODY: ${o.data}');
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    print('✅ ${r.statusCode} ${r.requestOptions.uri}');
    print('RESPONSE: ${r.data}');
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    print('❌ ${e.requestOptions.uri}');
    print('ERROR: ${e.message}');
    h.next(e);
  }
}
