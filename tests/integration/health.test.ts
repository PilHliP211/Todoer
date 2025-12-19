import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import request from 'supertest';

import app from '../../src/app.js';

describe('GET /health', () => {
  beforeAll(async () => {
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns status ok', async () => {
    const response = await request(app.server).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
