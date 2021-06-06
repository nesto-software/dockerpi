const { waitForShh, connect, exec } = require("../utils");

let ssh2Handle;

beforeAll(async () => {
    await waitForShh();
    console.log("Connection to virtual pi established. Wait some more seconds to be sure...");
    await new Promise((resolve) => setTimeout(resolve, 10000));
    ssh2Handle = await connect();
}, 600000);

describe('SerialProxy', () => {
    test('Installation', async () => {
        const cmd = 'sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/nesto-software/SerialProxy/master/scripts/install-from-release.sh)"';
        await exec(ssh2Handle, cmd);
    }, 200000);

    test('Binary Existance', async () => {
        const cmd = 'which sersniff';
        await exec(ssh2Handle, cmd);
    }, 30000);

    /* TODO: find out why the loader is not working correctly... strace /lib/ld-linux.so.3 --verify /usr/bin/sersniff
    test('Loader', async () => {
        const cmd = 'bash -c "ldd $(which sersniff)"';
        await exec(ssh2Handle, cmd);
    }, 30000);
    */
});

afterAll(() => {
    if (ssh2Handle) {
        ssh2Handle.end();
    }
});