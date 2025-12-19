import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import request from 'supertest';

import app from '../../src/app.js';

const originalDatabaseUrl = process.env.DATABASE_URL;
const originalTimeout = process.env.READINESS_TIMEOUT_MS;

beforeAll(async () => {
  await app.ready();
});

afterAll(async () => {
  process.env.DATABASE_URL = originalDatabaseUrl;
  process.env.READINESS_TIMEOUT_MS = originalTimeout;
  await app.close();
});

describe('GET /healthz', () => {
  it('returns status ok with uptime', async () => {
    const response = await request(app.server).get('/healthz');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      status: 'ok',
      uptimeSeconds: expect.any(Number),
    });
  });
});

describe('GET /readiness', () => {
  it('returns ok when no database url is configured', async () => {
    delete process.env.DATABASE_URL;

    const response = await request(app.server).get('/readiness');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      status: 'ok',
      uptimeSeconds: expect.any(Number),
    });
  });

  it('returns 503 when database is unreachable', async () => {
    process.env.DATABASE_URL = 'postgres://user:pass@127.0.0.1:1/todoer';
    process.env.READINESS_TIMEOUT_MS = '100';

    const response = await request(app.server).get('/readiness');

    expect(response.status).toBe(503);
    expect(response.body).toEqual({
      status: 'unready',
      uptimeSeconds: expect.any(Number),
    });
  });
});
