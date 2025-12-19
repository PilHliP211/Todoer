import Fastify from 'fastify';
import net from 'node:net';

const app = Fastify({
  logger: true,
  requestIdHeader: 'x-request-id',
});

const getVersion = () => process.env.APP_VERSION;

const buildStatusPayload = (status: 'ok' | 'unready') => {
  const payload: {
    status: 'ok' | 'unready';
    uptimeSeconds: number;
    version?: string;
  } = {
    status,
    uptimeSeconds: Math.floor(process.uptime()),
  };

  const version = getVersion();
  if (version) {
    payload.version = version;
  }

  return payload;
};

const parseDatabaseConfig = (databaseUrl?: string) => {
  if (!databaseUrl) {
    return null;
  }

  try {
    const url = new URL(databaseUrl);
    const defaultPort = url.protocol.startsWith('mysql')
      ? 3306
      : url.protocol.startsWith('postgres')
        ? 5432
        : 5432;
    const port = Number(url.port || defaultPort);

    if (!url.hostname || Number.isNaN(port)) {
      return null;
    }

    return { host: url.hostname, port };
  } catch {
    return null;
  }
};

const checkDatabaseConnectivity = async (databaseUrl?: string) => {
  const config = parseDatabaseConfig(databaseUrl);
  if (!config) {
    return databaseUrl ? false : true;
  }

  const timeoutMs = Number(process.env.READINESS_TIMEOUT_MS ?? 1000);

  return await new Promise<boolean>((resolve) => {
    const socket = net.connect({ host: config.host, port: config.port });

    const finalize = (result: boolean) => {
      socket.removeAllListeners();
      if (!socket.destroyed) {
        socket.destroy();
      }
      resolve(result);
    };

    const timeout = setTimeout(() => finalize(false), timeoutMs);

    socket.once('connect', () => {
      clearTimeout(timeout);
      finalize(true);
    });

    socket.once('error', () => {
      clearTimeout(timeout);
      finalize(false);
    });
  });
};

app.addHook('onRequest', (request, _reply, done) => {
  request.log.info({ requestId: request.id }, 'request started');
  done();
});

app.get('/healthz', async () => buildStatusPayload('ok'));

app.get('/readiness', async (_request, reply) => {
  const isReady = await checkDatabaseConnectivity(process.env.DATABASE_URL);

  if (!isReady) {
    return reply.status(503).send(buildStatusPayload('unready'));
  }

  return buildStatusPayload('ok');
});

export default app;
