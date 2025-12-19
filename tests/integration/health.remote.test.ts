import { describe, expect, it } from 'vitest';

const baseUrl = process.env.INTEGRATION_BASE_URL;

const describeWhenConfigured = baseUrl ? describe : describe.skip;

const requestJson = async (path: string) => {
  if (!baseUrl) {
    throw new Error('INTEGRATION_BASE_URL is not set');
  }

  const response = await fetch(`${baseUrl}${path}`);
  const body = await response.json();

  return { response, body };
};

describeWhenConfigured('deployed health endpoints', () => {
  it('returns ok for /healthz', async () => {
    const { response, body } = await requestJson('/healthz');

    expect(response.status).toBe(200);
    expect(body).toMatchObject({ status: 'ok' });
  });

  it('returns ok for /readiness', async () => {
    const { response, body } = await requestJson('/readiness');

    expect(response.status).toBe(200);
    expect(body).toMatchObject({ status: 'ok' });
  });
});
