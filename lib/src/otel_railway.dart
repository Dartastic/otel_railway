// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_railway_suppression.dart';

class RailwayResult {
  const RailwayResult({
    this.teamId,
    this.projectId,
    this.projectName,
    this.environmentId,
    this.environmentName,
    this.serviceId,
    this.serviceName,
    this.region,
    this.builder,
    this.deploymentId,
    this.deploymentStatus,
    this.deploymentTrigger,
    this.gitProvider,
    this.gitBranch,
    this.gitCommit,
    this.replicaCount,
    this.pluginKind,
    this.volumeSizeGb,
    this.usageCpuVcpuMillis,
    this.usageMemoryGbMillis,
    this.usageNetworkGb,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? teamId;
  final String? projectId;
  final String? projectName;
  final String? environmentId;
  final String? environmentName;
  final String? serviceId;
  final String? serviceName;
  final String? region;
  final String? builder;
  final String? deploymentId;
  final String? deploymentStatus;
  final String? deploymentTrigger;
  final String? gitProvider;
  final String? gitBranch;
  final String? gitCommit;
  final int? replicaCount;
  final String? pluginKind;
  final int? volumeSizeGb;
  final int? usageCpuVcpuMillis;
  final int? usageMemoryGbMillis;
  final double? usageNetworkGb;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class RailwayCallResult<T> {
  const RailwayCallResult({required this.value, this.result});
  final T value;
  final RailwayResult? result;
}

Future<T> tracedRailway<T>({
  required String operation,
  required Future<RailwayCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (railwayInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_railway');
  final span = t.startSpan('railway $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'railway');
    span.setStringAttribute('rpc.method', operation);
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.teamId != null) {
        span.setStringAttribute('railway.team.id', res.teamId!);
      }
      if (res.projectId != null) {
        span.setStringAttribute('railway.project.id', res.projectId!);
      }
      if (res.projectName != null) {
        span.setStringAttribute('railway.project.name', res.projectName!);
      }
      if (res.environmentId != null) {
        span.setStringAttribute('railway.environment.id', res.environmentId!);
      }
      if (res.environmentName != null) {
        span.setStringAttribute(
            'railway.environment.name', res.environmentName!);
      }
      if (res.serviceId != null) {
        span.setStringAttribute('railway.service.id', res.serviceId!);
      }
      if (res.serviceName != null) {
        span.setStringAttribute('railway.service.name', res.serviceName!);
      }
      if (res.region != null) {
        span.setStringAttribute('railway.region', res.region!);
      }
      if (res.builder != null) {
        span.setStringAttribute('railway.builder', res.builder!);
      }
      if (res.deploymentId != null) {
        span.setStringAttribute('railway.deployment.id', res.deploymentId!);
      }
      if (res.deploymentStatus != null) {
        span.setStringAttribute(
            'railway.deployment.status', res.deploymentStatus!);
      }
      if (res.deploymentTrigger != null) {
        span.setStringAttribute(
            'railway.deployment.trigger', res.deploymentTrigger!);
      }
      if (res.gitProvider != null) {
        span.setStringAttribute('railway.git.provider', res.gitProvider!);
      }
      if (res.gitBranch != null) {
        span.setStringAttribute('railway.git.branch', res.gitBranch!);
      }
      if (res.gitCommit != null) {
        span.setStringAttribute('railway.git.commit', res.gitCommit!);
      }
      if (res.replicaCount != null) {
        span.setIntAttribute('railway.replica.count', res.replicaCount!);
      }
      if (res.pluginKind != null) {
        span.setStringAttribute('railway.plugin.kind', res.pluginKind!);
      }
      if (res.volumeSizeGb != null) {
        span.setIntAttribute('railway.volume.size_gb', res.volumeSizeGb!);
      }
      if (res.usageCpuVcpuMillis != null) {
        span.setIntAttribute(
            'railway.usage.cpu_vcpu_millis', res.usageCpuVcpuMillis!);
      }
      if (res.usageMemoryGbMillis != null) {
        span.setIntAttribute(
            'railway.usage.memory_gb_millis', res.usageMemoryGbMillis!);
      }
      if (res.usageNetworkGb != null) {
        span.setDoubleAttribute(
            'railway.usage.network_gb', res.usageNetworkGb!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('railway.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400) ||
          res.deploymentStatus == 'FAILED' ||
          res.deploymentStatus == 'CRASHED' ||
          res.deploymentStatus == 'REMOVED';
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'railway.error');
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
