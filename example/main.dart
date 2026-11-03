// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_railway/otel_railway.dart';

/// Traces Railway calls with OpenTelemetry.
///
/// `otel_railway` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Railway call in
/// [tracedRailway]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'railway-example');

  // Traces a Railway call.
  final railwayId = await tracedRailway<String>(
    operation: 'create',
    invoke: () async {
      // Make the Railway call here, then report what it returned.
      const id = 'railway_8f3a2c';
      return const RailwayCallResult(
          value: id,
          result: RailwayResult(
              teamId: 'team_8f3a2c',
              projectId: 'project_8f3a2c',
              projectName: 'example',
              environmentId: 'environment_8f3a2c',
              environmentName: 'example',
              serviceId: 'service_8f3a2c',
              serviceName: 'example',
              region: 'us-east-1',
              builder: 'example',
              deploymentId: 'deployment_8f3a2c',
              deploymentStatus: 'succeeded',
              deploymentTrigger: 'example',
              gitProvider: 'example',
              gitBranch: 'example',
              gitCommit: 'example',
              replicaCount: 3,
              pluginKind: 'example',
              volumeSizeGb: 512,
              usageCpuVcpuMillis: 1,
              usageMemoryGbMillis: 1,
              usageNetworkGb: 0.5,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedRailway create returned $railwayId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRailwayInstrumentationAsync.
  await runWithoutRailwayInstrumentationAsync(
    () => tracedRailway<String>(
      operation: 'create',
      invoke: () async {
        const id = 'railway_8f3a2c';
        return const RailwayCallResult(
            value: id,
            result: RailwayResult(
                teamId: 'team_8f3a2c',
                projectId: 'project_8f3a2c',
                projectName: 'example',
                environmentId: 'environment_8f3a2c',
                environmentName: 'example',
                serviceId: 'service_8f3a2c',
                serviceName: 'example',
                region: 'us-east-1',
                builder: 'example',
                deploymentId: 'deployment_8f3a2c',
                deploymentStatus: 'succeeded',
                deploymentTrigger: 'example',
                gitProvider: 'example',
                gitBranch: 'example',
                gitCommit: 'example',
                replicaCount: 3,
                pluginKind: 'example',
                volumeSizeGb: 512,
                usageCpuVcpuMillis: 1,
                usageMemoryGbMillis: 1,
                usageNetworkGb: 0.5,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
