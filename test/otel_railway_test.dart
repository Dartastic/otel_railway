// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_railway/otel_railway.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_railway-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('deployments.create records builder + git', () async {
    await tracedRailway<String>(
      operation: 'deployments.create',
      invoke: () async => const RailwayCallResult(
        value: 'ok',
        result: RailwayResult(
          projectName: 'app',
          serviceName: 'web',
          region: 'us-west1',
          builder: 'nixpacks',
          deploymentStatus: 'SUCCESS',
          gitProvider: 'github',
          gitBranch: 'main',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('railway deployments.create')!);
    expect(a['railway.builder'], 'nixpacks');
    expect(a['railway.git.provider'], 'github');
  });

  test('CRASHED deployment sets span error', () async {
    await tracedRailway<String>(
      operation: 'deployments.get',
      invoke: () async => const RailwayCallResult(
        value: 'ok',
        result: RailwayResult(
          deploymentStatus: 'CRASHED',
        ),
      ),
    );
    expect(
      spans.findSpanByName('railway deployments.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('usage records cpu + memory + network', () async {
    await tracedRailway<String>(
      operation: 'usage.get',
      invoke: () async => const RailwayCallResult(
        value: 'ok',
        result: RailwayResult(
          usageCpuVcpuMillis: 8400000,
          usageMemoryGbMillis: 1200000,
          usageNetworkGb: 12.5,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('railway usage.get')!);
    expect(a['railway.usage.cpu_vcpu_millis'], 8400000);
    expect(a['railway.usage.network_gb'], 12.5);
  });

  test('suppression skips spans', () async {
    await runWithoutRailwayInstrumentationAsync(() async {
      await tracedRailway<String>(
        operation: 'projects.list',
        invoke: () async => const RailwayCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('railway '), isEmpty);
  });
}
