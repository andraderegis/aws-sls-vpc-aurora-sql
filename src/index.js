const { HeroesSchema, sequelize } = require('./utils/database');
const faker = require('faker');

const handler = async event => {
  try {
    await sequelize.authenticate();
    console.log('Connection has been established successfully');
  } catch (error) {
    console.error('Unable to connect to the database', error.stack);
    return {
      statusCode: 500,
      body: 'Internal Server Error'
    };
  }

  await HeroesSchema.sync();

  const result = await HeroesSchema.create({
    name: faker.name.title(),
    power: faker.name.jobTitle()
  });

  const all = await HeroesSchema.findAll({
    raw: true,
    attributes: ['name', 'power', 'id']
  });

  return {
    body: JSON.stringify({
      result,
      all
    })
  };
};

exports.handler = handler;
