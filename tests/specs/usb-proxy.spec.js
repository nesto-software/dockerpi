const { waitForShh, connect, exec } = require("../utils");

let ssh2Handle;

beforeAll(async () => {
    await waitForShh();
    console.log("Connection to virtual pi established. Wait some more seconds to be sure...");
    await new Promise((resolve) => setTimeout(resolve, 10000));
    ssh2Handle = await connect();
}, 600000);

describe('USBProxy', () => {
    test('Installation', async () => {
        const cmd = 'sudo bash -c "while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done; $(curl -fsSL https://raw.githubusercontent.com/nesto-software/USBProxy/master/scripts/install-from-release.sh)"';
        await exec(ssh2Handle, cmd);
    }, 600000);

    test('Binary Existance', async () => {
        const cmd = 'which usb-mitm';
        await exec(ssh2Handle, cmd);
    }, 30000);

    test('Loader', async () => {
        const cmd = 'bash -c "ldd $(which usb-mitm)"';
        await exec(ssh2Handle, cmd);
    }, 30000);
});

afterAll(() => {
    if (ssh2Handle) {
        ssh2Handle.end();
    }
});