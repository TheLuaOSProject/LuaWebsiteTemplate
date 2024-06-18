const { exec } = require('child_process');
const types = [
    'Document', 'Window', 'HTMLElement', 'Event', 'MouseEvent', 'KeyboardEvent'
];

exec('mkdir -p schemas', (err: any, stdout: any, stderr: any) => {
    if (err) {
        console.error('Error creating schemas directory:', stderr);
    }
});

types.forEach(type => {
    const cmd = `npx ts-json-schema-generator --path 'd-types.ts' --type '${type}Type' > schemas/${type}.json`;
    exec(cmd, (err: any, stdout: any, stderr: any) => {
        if (err) {
            console.error(`Error generating schema for ${type}:`, stderr);
        } else {
            console.log(`Schema for ${type} generated successfully.`);
        }
    });
});
