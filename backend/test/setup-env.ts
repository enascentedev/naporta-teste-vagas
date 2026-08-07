import { config } from 'dotenv';

config({
  path: process.env.TEST_ENV_FILE ?? '.env.test',
  override: false,
  quiet: true,
});
