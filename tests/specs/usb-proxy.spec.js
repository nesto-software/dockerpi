const { waitForShh, connect, exec } = require("../utils");

let ssh2Handle;

jest.disableAutomock();

beforeAll(async () => {
    await waitForShh();
    ssh2Handle = await connect();
}, 60000);

describe('USBProxy', () => {
    test('Installation', async () => {
        const cmd = 'sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/nesto-software/USBProxy/master/scripts/install-from-release.sh)"';
        await exec(ssh2Handle, cmd);
    }, 120000);

    test('Loader', async () => {
        const cmd = 'bash -c "ldd $(which usb-mitm)"';
        await exec(ssh2Handle, cmd);
    }, 30000);
});

afterAll(() => {
    ssh2Handle.end();
});