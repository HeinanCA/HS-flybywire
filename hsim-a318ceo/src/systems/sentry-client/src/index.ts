// Copyright (c) 2021-2023 FlyByWire Simulations
//
// SPDX-License-Identifier: GPL-3.0

import { FbwAircraftSentryClient } from '@flybywiresim/fbw-sdk';

declare const process: any;

new FbwAircraftSentryClient().onInstrumentLoaded({
    dsn: process.env.SENTRY_DSN,
    buildInfoFilePrefix: 'a318hs',
    root: false,
    enableTracing: false,
});
