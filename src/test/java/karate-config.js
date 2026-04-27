function fn() {
  var env = karate.env; // get system property 'karate.env'

  if (!env) {
    env = 'dev';
  }

  var config = {
    baseUrl: 'http://localhost:8080'
  };

  return config;
}