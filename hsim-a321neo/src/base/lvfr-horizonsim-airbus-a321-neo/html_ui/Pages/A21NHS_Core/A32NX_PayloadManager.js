/* eslint-disable no-undef */
class A32NX_PayloadConstructor {
    constructor() {
        this.paxStations = {
            rows1_5: {
                name: 'ROWS [1-5]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 0 + 1,
                position: 20.5,
                simVar: "A32NX_PAX_A"
            },
            rows6_10: {
                name: 'ROWS [6-10]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 1 + 1,
                position: 10,
                simVar: "A32NX_PAX_B"
            },
            rows11_15: {
                name: 'ROWS [11-15]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 2 + 1,
                position: 0,
                simVar: "A32NX_PAX_C"
            },
            rows16_20: {
                name: 'ROWS [16-20]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 3 + 1,
                position: -12,
                simVar: "A32NX_PAX_D"
            },
            rows21_25: {
                name: 'ROWS [21-25]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 4 + 1,
                position: -27,
                simVar: "A32NX_PAX_E"
            },
            rows26_30: {
                name: 'ROWS [26-30]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 5 + 1,
                position: -41,
                simVar: "A32NX_PAX_F"
            },
            rows31_35: {
                name: 'ROWS [31-35]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 6 + 1,
                position: -52,
                simVar: "A32NX_PAX_G"
            },
            rows36_40: {
                name: 'ROWS [36-40]',
                seats: 30,
                weight: Math.round(NXUnits.kgToUser(2520)),
                stationIndex: 7 + 1,
                position: -63,
                simVar: "A32NX_PAX_H"
            },
        };

        this.cargoStations = {
            fwdBag: {
                name: 'FWD BAGGAGE/CONTAINER',
                weight: Math.round(NXUnits.kgToUser(3402)),
                load: 0,
                stationIndex: 8 + 1,
                position: 13.43,
                visible: true,
                simVar: 'A32NX_CARGO_FWD_BAGGAGE_CONTAINER',
            },
            aftCont: {
                name: 'AFT CONTAINER',
                weight: Math.round(NXUnits.kgToUser(2426)),
                load: 0,
                stationIndex: 9 + 1,
                position: -41.83,
                visible: true,
                simVar: 'A32NX_CARGO_AFT_CONTAINER',
            },
            aftBag: {
                name: 'AFT BAGGAGE',
                weight: Math.round(NXUnits.kgToUser(2110)),
                load: 0,
                stationIndex: 10 + 1,
                position: -54.83,
                visible: true,
                simVar: 'A32NX_CARGO_AFT_BAGGAGE',
            },
            aftBulk: {
                name: 'AFT BULK/LOOSE',
                weight: Math.round(NXUnits.kgToUser(1497)),
                load: 0,
                stationIndex: 11 + 1,
                position: -62.13,
                visible: true,
                simVar: 'A32NX_CARGO_AFT_BULK_LOOSE',
            },
        };
    }
}

const payloadConstruct = new A32NX_PayloadConstructor();
const paxStations = payloadConstruct.paxStations;
const cargoStations = payloadConstruct.cargoStations;
const MAX_SEAT_AVAILABLE = 240;

/**
 * Calculate %MAC ZWFCG of all stations
 */
function getZfwcg() {

    const leMacZ = -17.133; // Accurate to 3 decimals, replaces debug weight values
    const macSize = 13.464; // Accurate to 3 decimals, replaces debug weight values

    const emptyWeight = (SimVar.GetSimVarValue("EMPTY WEIGHT", getUserUnit()));
    const emptyPosition = -20.5; // Value from flight_model.cfg
    const emptyMoment = emptyPosition * emptyWeight;
    const PAX_WEIGHT = SimVar.GetSimVarValue("L:A32NX_WB_PER_PAX_WEIGHT", "Number");

    const paxTotalMass = Object.values(paxStations).map((station) => new BitFlags(SimVar.GetSimVarValue(`L:${station.simVar}`, "Number")).getTotalBits() * PAX_WEIGHT).reduce((acc, cur) => acc + cur, 0);
    const paxTotalMoment = Object.values(paxStations).map((station) => new BitFlags(SimVar.GetSimVarValue(`L:${station.simVar}`, "Number")).getTotalBits() * PAX_WEIGHT * station.position).reduce((acc, cur) => acc + cur, 0);

    const cargoTotalMass = Object.values(cargoStations).map((station) => SimVar.GetSimVarValue(`PAYLOAD STATION WEIGHT:${station.stationIndex}`, getUserUnit())).reduce((acc, cur) => acc + cur, 0);
    const cargoTotalMoment = Object.values(cargoStations).map((station) => (SimVar.GetSimVarValue(`PAYLOAD STATION WEIGHT:${station.stationIndex}`, getUserUnit()) * station.position)).reduce((acc, cur) => acc + cur, 0);

    const totalMass = emptyWeight + paxTotalMass + cargoTotalMass;
    const totalMoment = emptyMoment + paxTotalMoment + cargoTotalMoment;

    const cgPosition = totalMoment / totalMass;
    const cgPositionToLemac = cgPosition - leMacZ;
    const cgPercentMac = -100 * (cgPositionToLemac / macSize);

    return cgPercentMac;
}

function getTotalCargo() {
    const cargoTotalMass = Object.values(cargoStations).filter((station) => station.visible).map((station) => SimVar.GetSimVarValue(`PAYLOAD STATION WEIGHT:${station.stationIndex}`, getUserUnit())).reduce((acc, cur) => acc + cur, 0);
    return cargoTotalMass;
}

function getTotalPayload() {
    const paxTotalMass = Object.values(paxStations).map((station) => SimVar.GetSimVarValue(`PAYLOAD STATION WEIGHT:${station.stationIndex}`, getUserUnit())).reduce((acc, cur) => acc + cur, 0);
    const cargoTotalMass = getTotalCargo();
    return paxTotalMass + cargoTotalMass;
}

function getZfw() {
    const emptyWeight = (SimVar.GetSimVarValue("EMPTY WEIGHT", getUserUnit()));
    return emptyWeight + getTotalPayload();
}

function getUserUnit() {
    const defaultUnit = (NXUnits.userWeightUnit() == "KG") ? "Kilograms" : "Pounds";
    return defaultUnit;
}
