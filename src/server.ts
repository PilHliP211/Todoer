import app from './app.js';

const port = Number(process.env.PORT ?? 3000);

const start = async () => {
  try {
    await app.listen({ port, host: '0.0.0.0' });
    app.log.info(
      {
        commitSha: process.env.APP_VERSION,
        imageTag: process.env.IMAGE_TAG,
      },
      'deployment metadata'
    );
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
};

start();
