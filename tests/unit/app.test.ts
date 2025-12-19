import { describe, expect, it } from 'vitest';

import app from '../../src/app.js';

describe('app', () => {
  it('builds a fastify instance', () => {
    expect(app).toBeDefined();
  });
});
