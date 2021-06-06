const waitssh = require('./waitssh');
const { Client } = require('ssh2');

exports.waitForShh = async function () {
  const sshInfo = {
    port: process.env.SSH_PORT, 
    hostname: process.env.SSH_HOSTNAME,
  }

  return waitssh(sshInfo);
};

exports.connect = async function () {
  const ssh = new Client();

  ssh.connect({
      host: process.env.SSH_HOSTNAME, 
      port: process.env.SSH_PORT, 
      password: process.env.SSH_PASSWD, 
      user: process.env.SSH_USER,
      readyTimeout: 60000,
  })

  ssh.on('error', (err) => {
      ssh.end();
      console.error(err);
  })

  // wait until connection is ready
  await new Promise((resolve) => ssh.on('ready', resolve));

  return ssh;
}

exports.exec = async function (ssh, cmd) {
  console.log("Executing command: " + cmd + "\n");
  
  await new Promise((resolve, reject) => ssh.exec(cmd, (err, stream) => {
      if (err) return reject(err);

      stream.on('close', (code, signal) => {
        console.log('Stream :: close :: code: ' + code + ', signal: ' + signal);

        if (code == 0) {
          resolve();
        } else {
          reject(new Error("Received exit code " + code));
        }
      }).on('data', (data) => {
        process.stdout.write(data);
      }).stderr.on('data', (data) => {
        process.stderr.write(data);
      });
  }));
};
