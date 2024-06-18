"use strict";
var exec = require('child_process').exec;
var types = [
    'Document', 'Window', 'HTMLElement', 'Event', 'MouseEvent', 'KeyboardEvent'
];
exec('mkdir -p schemas', function (err, stdout, stderr) {
    if (err) {
        console.error('Error creating schemas directory:', stderr);
    }
});
types.forEach(function (type) {
    var cmd = "npx ts-json-schema-generator --path 'd-types.ts' --type '".concat(type, "Type' > schemas/").concat(type, ".json");
    exec(cmd, function (err, stdout, stderr) {
        if (err) {
            console.error("Error generating schema for ".concat(type, ":"), stderr);
        }
        else {
            console.log("Schema for ".concat(type, " generated successfully."));
        }
    });
});
