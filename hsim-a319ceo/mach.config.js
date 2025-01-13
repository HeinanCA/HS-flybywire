const imagePlugin = require('esbuild-plugin-inline-image');
const postCssPlugin = require('esbuild-style-plugin-v2');
const tailwind = require('tailwindcss');
const postCssColorFunctionalNotation = require('postcss-color-functional-notation');
const postCssInset = require('postcss-inset');
const { typecheckingPlugin } = require('#build-utils');

// process.env.FBW_TYPECHECK = "1";

/** @type { import('@synaptic-simulations/mach').MachConfig } */
module.exports = {
    packageName: 'A319HS',
    packageDir: 'out/lvfr-horizonsim-airbus-a319-ceo',
    plugins: [
        imagePlugin({ limit: -1 }),
        postCssPlugin({
            extract: true,
            postcss: {
                plugins: [
                    tailwind('../fbw-common/src/systems/instruments/src/EFB/tailwind.config.js'),

          // transform: hsl(x y z / alpha) -> hsl(x, y, z, alpha)
          postCssColorFunctionalNotation(),

          // transform: inset: 0; -> top/right/left/bottom: 0;
          postCssInset(),
        ],
      },
    }),
    typecheckingPlugin(),
  ],
  instruments: [
    msfsAvionicsInstrument('PFD'),
    msfsAvionicsInstrument('ND'),
    msfsAvionicsInstrument('EWDcfm'),
    msfsAvionicsInstrument('EWDiae'),
    msfsAvionicsInstrument('Clock'),
    msfsAvionicsInstrument('OANC'),

    reactInstrument('SD'),
    reactInstrument('DCDU'),
    reactInstrument('RTPI'),
    reactInstrument('RMP'),
    reactInstrument('ISIS'),
    reactInstrument('BAT'),
    reactInstrument('ATC'),
    reactInstrument('EFB', ['/Pages/VCockpit/Instruments/Shared/Map/MapInstrument.html']),
  ],
};

function msfsAvionicsInstrument(name, index = 'instrument.tsx') {
    return {
        name,
        index: `src/systems/instruments/src/${name}/${index}`,
        simulatorPackage: {
            type: 'baseInstrument',
            templateId: `A319HS_${name}`,
            mountElementId: `${name}_CONTENT`,
            fileName: name.toLowerCase(),
            imports: ['/JS/dataStorage.js'],
        },
    };
}

function reactInstrument(name, additionalImports) {
    return {
        name,
        index: `src/systems/instruments/src/${name}/index.tsx`,
        simulatorPackage: {
            type: 'react',
            isInteractive: false,
            fileName: name.toLowerCase(),
            imports: ['/JS/dataStorage.js','/JS/A319HS/A32NX_Simvars.js', ...(additionalImports ?? [])],
        },
    };
}
