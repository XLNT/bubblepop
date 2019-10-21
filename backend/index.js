const Koa = require('koa');
const Router = require('@koa/router');
const bodyParser = require('koa-bodyparser');
const fetch = require('isomorphic-fetch');
const BN = require('bn.js');

const app = new Koa();
const router = new Router();

const hexToBN = (hexString) => new BN(hexString.slice(2), 16);

const get = async (url) => {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`Error ${res.status}: ${res.statusText}`);
  }
  return await res.json();
}

router.post('/location', async (ctx, next) => {
  console.log(ctx.request.body);
  try {
    const data = await get(`https://map-api-direct.foam.space/poi/filtered?${new URLSearchParams({
      ...ctx.request.body,
      offset: 0,
      limit: 100,
    })}&status=challenged&status=application`);

    if (!data.length) {
      ctx.body = {
        status: 'NOT_FOUND'
      }
      return;
    }

    // sort by deposit
    const poi = data.sort((a, b) => hexToBN(a.state.deposit).gte(hexToBN(b.state.deposit)))[0];

    try {
      const info = await get(`https://map-api-direct.foam.space/poi/${poi.listingHash}`);
      ctx.body = {
        poi,
        info: info.data.data,
      };
      return;
    } catch (error) {
      console.error(error);
    }
  } catch (error) {
    ctx.status = 400;
    ctx.body = error.message;
  }
});

app.use(bodyParser());
app.use(router.routes());
app.use(router.allowedMethods());

app.listen(3000);
