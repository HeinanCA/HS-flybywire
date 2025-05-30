// Copyright (c) 2021-2023 FlyByWire Simulations
//
// SPDX-License-Identifier: GPL-3.0

'use strict';

const esbuild = require('esbuild');
const path = require('path');
const { createModuleBuild  } = require('#build-utils');

const outFile = 'build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/JS/A318HS/sentry-client/sentry-client.js';

esbuild.build(createModuleBuild ('build-a318ceo', undefined, path.join(__dirname, 'src/index.ts'), outFile, __dirname));
