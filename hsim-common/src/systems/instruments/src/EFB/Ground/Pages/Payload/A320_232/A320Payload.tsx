// Copyright (c) 2023-2024 FlyByWire Simulations
// SPDX-License-Identifier: GPL-3.0

/* eslint-disable max-len */
import { SeatFlags, Units, usePersistentNumberProperty, usePersistentProperty, useSeatFlags, useSimVar } from '@flybywiresim/fbw-sdk';
import { Card, PromptModal, SelectGroup, SelectItem, TooltipWrapper, t, useModals } from '@flybywiresim/flypad';
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { CloudArrowDown } from 'react-bootstrap-icons';
import { SeatOutlineBg } from '../../../../Assets/SeatOutlineBg';
import { ChartWidget } from '../Chart/ChartWidget';
import { BoardingInput, MiscParamsInput, PayloadInputTable } from '../PayloadElements';
import { CargoStationInfo, PaxStationInfo } from '../Seating/Constants';
import { CargoWidget } from './CargoWidget';

import Loadsheet from './a320v55.json';

import { SeatMapWidget } from './SeatMapWidget';

interface A320Props {
    simbriefUnits: string,
    simbriefBagWeight: number,
    simbriefPaxWeight: number,
    simbriefPax: number,
    simbriefBag: number,
    simbriefFreight: number,
    simbriefDataLoaded: boolean,
    massUnitForDisplay: string,
    isOnGround: boolean,

    boardingStarted: boolean,
    boardingRate: string,
    setBoardingStarted: (boardingStarted: any) => void,
    setBoardingRate: (boardingRate: any) => void,
}
export const A320IAEPayload: React.FC<A320Props> = ({
    simbriefUnits,
    simbriefBagWeight,
    simbriefPaxWeight,
    simbriefPax,
    simbriefBag,
    simbriefFreight,
    simbriefDataLoaded,
    massUnitForDisplay,
    isOnGround,
    boardingStarted,
    boardingRate,
    setBoardingStarted,
    setBoardingRate,
}) => {
    const { showModal } = useModals();

    const [aFlags] = useSeatFlags(`L:${Loadsheet.seatMap[0].simVar}`, Loadsheet.seatMap[0].capacity, 609);
    const [bFlags] = useSeatFlags(`L:${Loadsheet.seatMap[1].simVar}`, Loadsheet.seatMap[1].capacity, 623);
    const [cFlags] = useSeatFlags(`L:${Loadsheet.seatMap[2].simVar}`, Loadsheet.seatMap[2].capacity, 631);
    const [dFlags] = useSeatFlags(`L:${Loadsheet.seatMap[3].simVar}`, Loadsheet.seatMap[3].capacity, 643);
    const [eFlags] = useSeatFlags(`L:${Loadsheet.seatMap[4].simVar}`, Loadsheet.seatMap[4].capacity, 651);
    const [fFlags] = useSeatFlags(`L:${Loadsheet.seatMap[5].simVar}`, Loadsheet.seatMap[5].capacity, 667);
    const [gFlags] = useSeatFlags(`L:${Loadsheet.seatMap[6].simVar}`, Loadsheet.seatMap[6].capacity, 693);

    const [aFlagsDesired, setAFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[0].simVar}_DESIRED`, Loadsheet.seatMap[0].capacity, 679);
    const [bFlagsDesired, setBFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[1].simVar}_DESIRED`, Loadsheet.seatMap[1].capacity, 717);
    const [cFlagsDesired, setCFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[2].simVar}_DESIRED`, Loadsheet.seatMap[2].capacity, 729);
    const [dFlagsDesired, setDFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[3].simVar}_DESIRED`, Loadsheet.seatMap[3].capacity, 747);
    const [eFlagsDesired, setEFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[4].simVar}_DESIRED`, Loadsheet.seatMap[4].capacity, 753);
    const [fFlagsDesired, setFFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[5].simVar}_DESIRED`, Loadsheet.seatMap[5].capacity, 767);
    const [gFlagsDesired, setGFlagsDesired] = useSeatFlags(`L:${Loadsheet.seatMap[6].simVar}_DESIRED`, Loadsheet.seatMap[6].capacity, 787);

    const activeFlags = useMemo(() => [aFlags, bFlags, cFlags, dFlags, eFlags, fFlags, gFlags], [aFlags, bFlags, cFlags, dFlags, eFlags, fFlags, gFlags]);
    const desiredFlags = useMemo(() => [aFlagsDesired, bFlagsDesired, cFlagsDesired, dFlagsDesired, eFlagsDesired, fFlagsDesired, gFlagsDesired], [aFlagsDesired, bFlagsDesired, cFlagsDesired, dFlagsDesired, eFlagsDesired, fFlagsDesired, gFlagsDesired]);
    const setDesiredFlags = useMemo(() => [setAFlagsDesired, setBFlagsDesired, setCFlagsDesired, setDFlagsDesired, setEFlagsDesired, setFFlagsDesired, setGFlagsDesired], []);

    const [fwdBag] = useSimVar(`L:${Loadsheet.cargoMap[0].simVar}`, 'Number', 719);
    const [aftCont] = useSimVar(`L:${Loadsheet.cargoMap[1].simVar}`, 'Number', 743);
    const [aftBag] = useSimVar(`L:${Loadsheet.cargoMap[2].simVar}`, 'Number', 769);
    const [aftBulk] = useSimVar(`L:${Loadsheet.cargoMap[3].simVar}`, 'Number', 797);

    const [fwdBagDesired, setFwdBagDesired] = useSimVar(`L:${Loadsheet.cargoMap[0].simVar}_DESIRED`, 'Number', 619);
    const [aftContDesired, setAftContDesired] = useSimVar(`L:${Loadsheet.cargoMap[1].simVar}_DESIRED`, 'Number', 631);
    const [aftBagDesired, setAftBagDesired] = useSimVar(`L:${Loadsheet.cargoMap[2].simVar}_DESIRED`, 'Number', 641);
    const [aftBulkDesired, setAftBulkDesired] = useSimVar(`L:${Loadsheet.cargoMap[3].simVar}_DESIRED`, 'Number', 677);

    const cargo = useMemo(() => [fwdBag, aftCont, aftBag, aftBulk], [fwdBag, aftCont, aftBag, aftBulk]);
    const cargoDesired = useMemo(() => [fwdBagDesired, aftContDesired, aftBagDesired, aftBulkDesired], [fwdBagDesired, aftContDesired, aftBagDesired, aftBulkDesired]);
    const setCargoDesired = useMemo(() => [setFwdBagDesired, setAftContDesired, setAftBagDesired, setAftBulkDesired], []);

    const [paxWeight, setPaxWeight] = useSimVar('L:A32NX_WB_PER_PAX_WEIGHT', 'Kilograms', 739);
    const [paxBagWeight, setPaxBagWeight] = useSimVar('L:A32NX_WB_PER_BAG_WEIGHT', 'Kilograms', 797);
    // const [destEfob] = useSimVar('L:A32NX_DESTINATION_FUEL_ON_BOARD', 'Kilograms', 5_000);

    const [emptyWeight] = useState(SimVar.GetSimVarValue('A:EMPTY WEIGHT', 'Kilograms'));

    const [seatMap] = useState<PaxStationInfo[]>(Loadsheet.seatMap);
    const [cargoMap] = useState<CargoStationInfo[]>(Loadsheet.cargoMap);

    const maxPax = useMemo(() => seatMap.reduce((a, b) => a + b.capacity, 0), [seatMap]);
    const maxCargo = useMemo(() => cargoMap.reduce((a, b) => a + b.weight, 0), [cargoMap]);

    // Calculate Total Pax from Pax Flags
    const totalPax = useMemo(() => {
        let p = 0;
        activeFlags.forEach((flag) => {
            p += flag.getTotalFilledSeats();
        });
        return p;
    }, [...activeFlags]);

    const totalPaxDesired = useMemo(() => {
        let p = 0;
        desiredFlags.forEach((flag) => {
            p += flag.getTotalFilledSeats();
        });
        return p;
    }, [...desiredFlags]);

    const totalCargoDesired = useMemo(() => ((cargoDesired && cargoDesired.length > 0) ? cargoDesired.reduce((a, b) => a + b) : -1), [...cargoDesired]);
    const totalCargo = useMemo(() => ((cargo && cargo.length > 0) ? cargo.reduce((a, b) => a + b) : -1), [...cargo]);

    // Units
    // Weights
    const [zfw] = useSimVar('L:A32NX_AIRFRAME_ZFW', 'number', 1_553);
    const [zfwDesired] = useSimVar('L:A32NX_AIRFRAME_ZFW_DESIRED', 'number', 1_621);
    const [gw] = useSimVar('L:A32NX_AIRFRAME_GW', 'number', 1_741);
    const [gwDesired] = useSimVar('L:A32NX_AIRFRAME_GW_DESIRED', 'number', 1_787);

    // CG MAC
    const [zfwCgMac] = useSimVar('L:A32NX_AIRFRAME_ZFW_CG_PERCENT_MAC', 'number', 1_223);
    const [desiredZfwCgMac] = useSimVar('L:A32NX_AIRFRAME_ZFW_CG_PERCENT_MAC_DESIRED', 'number', 1_279);
    const [gwCgMac] = useSimVar('L:A32NX_AIRFRAME_GW_CG_PERCENT_MAC', 'number', 1_301);
    const [desiredGwCgMac] = useSimVar('L:A32NX_AIRFRAME_GW_CG_PERCENT_MAC_DESIRED', 'number', 1_447);

    const [showSimbriefButton, setShowSimbriefButton] = useState(false);
    const [displayZfw, setDisplayZfw] = useState(true);

    // GSX
    const [gsxPayloadSyncEnabled] = usePersistentNumberProperty('GSX_PAYLOAD_SYNC', 0);
    const [_, setGsxNumPassengers] = useSimVar('L:FSDT_GSX_NUMPASSENGERS', 'Number', 223);
    const [gsxBoardingState] = useSimVar('L:FSDT_GSX_BOARDING_STATE', 'Number', 227);
    const [gsxDeBoardingState] = useSimVar('L:FSDT_GSX_DEBOARDING_STATE', 'Number', 229);
    const gsxStates = {
        AVAILABLE: 1,
        NOT_AVAILABLE: 2,
        BYPASSED: 3,
        REQUESTED: 4,
        PERFORMING: 5,
        COMPLETED: 6,
    };

    const setSimBriefValues = () => {
        if (simbriefUnits === 'kgs') {
            setPaxBagWeight(simbriefBagWeight);
            setPaxWeight(simbriefPaxWeight);
            setTargetPax(simbriefPax > maxPax ? maxPax : simbriefPax);
            setTargetCargo(simbriefBag, simbriefFreight, simbriefBagWeight);
        } else {
            setPaxBagWeight(Units.poundToKilogram(simbriefBagWeight));
            setPaxWeight(Units.poundToKilogram(simbriefPaxWeight));
            setTargetPax(simbriefPax);
            setTargetCargo(simbriefBag, Units.poundToKilogram(simbriefFreight), Units.poundToKilogram(simbriefBagWeight));
        }
    };

    const [eng1Running] = useSimVar('ENG COMBUSTION:1', 'Bool', 6_581);
    const [eng2Running] = useSimVar('ENG COMBUSTION:2', 'Bool', 6_397);
    const [coldAndDark, setColdAndDark] = useState<boolean>(true);

    const chooseDesiredSeats = useCallback((stationIndex: number, fillSeats: boolean = true, numChoose: number) => {
        const seatFlags: SeatFlags = desiredFlags[stationIndex];
        if (fillSeats) {
            seatFlags.fillEmptySeats(numChoose);
        } else {
            seatFlags.emptyFilledSeats(numChoose);
        }

        setDesiredFlags[stationIndex](seatFlags);
    }, [...desiredFlags]);

    const setTargetPax = useCallback((numOfPax: number) => {
        setGsxNumPassengers(numOfPax);

        if (numOfPax === totalPaxDesired || numOfPax > maxPax || numOfPax < 0) return;

        let paxRemaining = numOfPax;

        const fillStation = (stationIndex: number, percent: number, paxToFill: number) => {
            const sFlags: SeatFlags = desiredFlags[stationIndex];
            const toBeFilled = Math.min(Math.trunc(percent * paxToFill), seatMap[stationIndex].capacity);

            paxRemaining -= toBeFilled;

            const planSeatedPax = sFlags.getTotalFilledSeats();
            chooseDesiredSeats(
                stationIndex,
                (toBeFilled > planSeatedPax),
                Math.abs(toBeFilled - planSeatedPax),
            );
        };

        for (let i = seatMap.length - 1; i > 0; i--) {
            fillStation(i, seatMap[i].fill, numOfPax);
        }
        fillStation(0, 1, paxRemaining);
    }, [maxPax, ...seatMap, totalPaxDesired]);

    const setTargetCargo = useCallback((numberOfPax: number, freight: number, perBagWeight: number = paxBagWeight) => {
        const bagWeight = numberOfPax * perBagWeight;
        const loadableCargoWeight = Math.min(bagWeight + Math.round(freight), maxCargo);

        let remainingWeight = loadableCargoWeight;

        async function fillCargo(station: number, percent: number, loadableCargoWeight: number) {
            const c = Math.round(percent * loadableCargoWeight);
            remainingWeight -= c;
            setCargoDesired[station](c);
        }

        for (let i = cargoDesired.length - 1; i > 0; i--) {
            fillCargo(i, cargoMap[i].weight / maxCargo, loadableCargoWeight);
        }
        fillCargo(0, 1, remainingWeight);
    }, [maxCargo, ...cargoMap, ...cargoDesired, paxBagWeight]);

    const processZfw = useCallback((newZfw) => {
        let paxCargoWeight = newZfw - emptyWeight;

        // Load pax first
        const pWeight = paxWeight + paxBagWeight;
        const newPax = Math.max(Math.min(Math.round(paxCargoWeight / pWeight), maxPax), 0);

        paxCargoWeight -= newPax * pWeight;
        const newCargo = Math.max(Math.min(paxCargoWeight, maxCargo), 0);

        setTargetPax(newPax);
        setTargetCargo(newPax, newCargo);
    }, [emptyWeight, paxWeight, paxBagWeight, maxPax, maxCargo]);

    const processGw = useCallback((newGw) => {
        let paxCargoWeight = newGw - emptyWeight - (gw - zfw); // new gw - empty - total fuel

        // Load pax first
        const pWeight = paxWeight + paxBagWeight;
        const newPax = Math.max(Math.min(Math.round(paxCargoWeight / pWeight), maxPax), 0);

        paxCargoWeight -= newPax * pWeight;
        const newCargo = Math.max(Math.min(paxCargoWeight, maxCargo), 0);

        setTargetPax(newPax);
        setTargetCargo(newPax, newCargo);
    }, [emptyWeight, paxWeight, paxBagWeight, maxPax, maxCargo, gw, zfw]);

    const onClickCargo = useCallback((cargoStation, e) => {
        if (gsxPayloadSyncEnabled === 1 && boardingStarted) {
            return;
        }
        const cargoPercent = Math.min(Math.max(0, e.nativeEvent.offsetX / cargoMap[cargoStation].progressBarWidth), 1);
        setCargoDesired[cargoStation](Math.round(cargoMap[cargoStation].weight * cargoPercent));
    }, [cargoMap]);

    const onClickSeat = useCallback((stationIndex: number, seatId: number) => {
        if (gsxPayloadSyncEnabled === 1 && boardingStarted) {
            return;
        }

        // TODO FIXME: This calculation does not work correctly if user clicks on many seats in rapid succession
        const oldPaxBag = totalPaxDesired * paxBagWeight;
        const freight = Math.max(totalCargoDesired - oldPaxBag, 0);

        const seatFlags: SeatFlags = desiredFlags[stationIndex];
        seatFlags.toggleSeatId(seatId);
        setDesiredFlags[stationIndex](seatFlags);

        let newPaxDesired = 0;
        desiredFlags.forEach((flag) => {
            newPaxDesired += flag.getTotalFilledSeats();
        });

        setTargetCargo(newPaxDesired, freight);
    }, [
        paxBagWeight,
        totalCargoDesired,
        ...cargoDesired,
        ...desiredFlags,
        totalPaxDesired,
    ]);

    const handleDeboarding = useCallback(() => {
        if (!boardingStarted) {
            showModal(
                <PromptModal
                    title={`${t('Ground.Payload.DeboardConfirmationTitle')}`}
                    bodyText={`${t('Ground.Payload.DeboardConfirmationBody')}`}
                    confirmText={`${t('Ground.Payload.DeboardConfirmationConfirm')}`}
                    cancelText={`${t('Ground.Payload.DeboardConfirmationCancel')}`}
                    onConfirm={() => {
                        setTargetPax(0);
                        setTargetCargo(0, 0);
                        setTimeout(() => {
                            setBoardingStarted(true);
                        }, 500);
                    }}
                />,
            );
            return;
        }
        setBoardingStarted(false);
    }, [totalPaxDesired, totalPax, totalCargo, boardingStarted, totalCargoDesired]);

    // Note: will need to be looked into when doors can be opened on this page.
    const [cabinLeftDoorOpen] = useState(SimVar.GetSimVarValue('A:INTERACTIVE POINT OPEN:0', 'Percent over 100'));
    const [cabinRightDoorOpen] = useState(SimVar.GetSimVarValue('A:INTERACTIVE POINT OPEN:1', 'Percent over 100'));
    const [aftLeftDoorOpen] = useState(SimVar.GetSimVarValue('A:INTERACTIVE POINT OPEN:2', 'Percent over 100'));

    const calculateBoardingTime = useMemo(() => {
        // factors taken from payload.rs TODO: Simvar
        let boardingRateMultiplier = 0;
        if (boardingRate === 'REAL') {
            boardingRateMultiplier = 5;
        } else if (boardingRate === 'FAST') {
            boardingRateMultiplier = 1;
        }

        let boardingDoorsOpen = 0;
        if (cabinLeftDoorOpen) {
            boardingDoorsOpen++;
        }
        if (cabinRightDoorOpen) {
            boardingDoorsOpen++;
        }
        if (aftLeftDoorOpen) {
            boardingDoorsOpen++;
        }
        boardingDoorsOpen = Math.max(boardingDoorsOpen, 1);
        boardingRateMultiplier /= boardingDoorsOpen;

        // factors taken from payload.rs TODO: Simvar
        const cargoWeightPerWeightStep = 60;

        const differentialPax = Math.abs(totalPaxDesired - totalPax);
        const differentialCargo = Math.abs(totalCargoDesired - totalCargo);

        const estimatedPaxBoardingSeconds = differentialPax * boardingRateMultiplier;
        const estimatedCargoLoadingSeconds = (differentialCargo / cargoWeightPerWeightStep) * boardingRateMultiplier;

        return Math.max(estimatedPaxBoardingSeconds, estimatedCargoLoadingSeconds);
    }, [totalPaxDesired, totalPax, totalCargoDesired, totalCargo, cabinLeftDoorOpen, cabinRightDoorOpen, aftLeftDoorOpen, boardingRate]);

    const boardingStatusClass = useMemo(() => {
        if (!boardingStarted) {
            return 'text-theme-highlight';
        }
        return (totalPaxDesired * paxWeight + totalCargoDesired) >= (totalPax * paxWeight + totalCargo) ? 'text-green-500' : 'text-yellow-500';
    }, [boardingStarted, paxWeight, totalCargoDesired, totalCargo, totalPaxDesired, totalPax]);

    // Init
    useEffect(() => {
        if (paxWeight === 0) {
            setPaxWeight(Math.round(Loadsheet.specs.pax.defaultPaxWeight));
        }
        if (paxBagWeight === 0) {
            setPaxBagWeight(Math.round(Loadsheet.specs.pax.defaultBagWeight));
        }
    }, []);

    // Set Cold and Dark State
    useEffect(() => {
        if (eng1Running || eng2Running || !isOnGround) {
            setColdAndDark(false);
        } else {
            setColdAndDark(true);
        }
    }, [eng1Running, eng2Running, isOnGround]);

    useEffect(() => {
        if (boardingRate !== 'INSTANT') {
            if (!coldAndDark) {
                setBoardingRate('INSTANT');
            }
        }
    }, [coldAndDark, boardingRate]);

    useEffect(() => {
        if (gsxPayloadSyncEnabled === 1) {
            switch (gsxBoardingState) {
            // If boarding has been requested, performed or completed
            case gsxStates.REQUESTED:
            case gsxStates.PERFORMING:
            case gsxStates.COMPLETED:
                setBoardingStarted(true);
                break;
            default:
                break;
            }
        }
    }, [gsxBoardingState]);

    useEffect(() => {
        if (gsxPayloadSyncEnabled === 1) {
            switch (gsxDeBoardingState) {
            case gsxStates.REQUESTED:
                // If Deboarding has been requested, set target pax to 0 for boarding backend
                setTargetPax(0);
                setTargetCargo(0, 0);
                setBoardingStarted(true);
                break;
            case gsxStates.PERFORMING:
                // If deboarding is being performed
                setBoardingStarted(true);
                break;
            case gsxStates.COMPLETED:
                // If deboarding is completed
                setBoardingStarted(false);
                break;
            default:
                break;
            }
        }
    }, [gsxDeBoardingState]);

    useEffect(() => {
        let simbriefStatus = false;
        if (simbriefUnits === 'kgs') {
            simbriefStatus = (simbriefDataLoaded
                && (
                    simbriefPax !== totalPaxDesired
                    || Math.abs(simbriefFreight + simbriefBag * simbriefBagWeight - totalCargoDesired) > 3.0
                    || Math.abs(simbriefPaxWeight - paxWeight) > 3.0
                    || Math.abs(simbriefBagWeight - paxBagWeight) > 3.0
                )
            );
        } else {
            simbriefStatus = (simbriefDataLoaded
                && (
                    simbriefPax !== totalPaxDesired
                    || Math.abs(Units.poundToKilogram(simbriefFreight + simbriefBag * simbriefBagWeight) - totalCargoDesired) > 3.0
                    || Math.abs(Units.poundToKilogram(simbriefPaxWeight) - paxWeight) > 3.0
                    || Math.abs(Units.poundToKilogram(simbriefBagWeight) - paxBagWeight) > 3.0
                )
            );
        }

        if (gsxPayloadSyncEnabled === 1) {
            if (boardingStarted) {
                setShowSimbriefButton(false);
                return;
            }

            setShowSimbriefButton(simbriefStatus);
            return;
        }
        setShowSimbriefButton(simbriefStatus);
    }, [
        simbriefUnits,
        simbriefFreight,
        simbriefBag,
        simbriefBagWeight,
        paxWeight, paxBagWeight,
        totalPaxDesired, totalCargoDesired,
        simbriefDataLoaded,
        boardingStarted,
        gsxPayloadSyncEnabled,
    ]);

    const remainingTimeString = () => {
        const minutes = Math.round(calculateBoardingTime / 60);
        const seconds = calculateBoardingTime % 60;
        const padding = seconds < 10 ? '0' : '';
        return `${minutes}:${padding}${seconds.toFixed(0)} ${t('Ground.Payload.EstimatedDurationUnit')}`;
    };

    const [theme] = usePersistentProperty('EFB_UI_THEME', 'blue');
    const getTheme = useCallback((theme: string): [string, string, string] => {
        let base = '#fff';
        let primary = '#E06938';
        let secondary = '#84CC16';
        switch (theme) {
        case 'dark':
            base = '#fff';
            primary = '#E06938';
            secondary = '#84CC16';
            break;
        case 'light':
            base = '#000000';
            primary = '#E06938';
            secondary = '#84CC16';
            break;
        default:
            break;
        }
        return [base, primary, secondary];
    }, [theme]);

    return (
        <div>
            <div className="relative h-content-section-reduced">
                <div className="mb-10">
                    <div className="relative flex flex-col">
                        <SeatOutlineBg stroke={getTheme(theme)[0]} highlight="#69BD45" />
                        <SeatMapWidget seatMap={seatMap} desiredFlags={desiredFlags} activeFlags={activeFlags} onClickSeat={onClickSeat} theme={getTheme(theme)} isMainDeck canvasX={243} canvasY={78} />
                    </div>
                </div>
                <CargoWidget cargo={cargo} cargoDesired={cargoDesired} cargoMap={cargoMap} onClickCargo={onClickCargo} />

                <div className="relative right-0 mt-16 flex flex-row justify-between px-4">
                    <div className="flex grow flex-col pr-24">
                        <div className="flex w-full flex-row">
                            <Card className="col-1 w-full" childrenContainerClassName={`w-full ${simbriefDataLoaded ? 'rounded-r-none' : ''}`}>
                                <PayloadInputTable
                                    loadsheet={Loadsheet}
                                    emptyWeight={emptyWeight}
                                    massUnitForDisplay={massUnitForDisplay}
                                    gsxPayloadSyncEnabled={gsxPayloadSyncEnabled === 1}
                                    displayZfw={displayZfw}
                                    boardingStarted={boardingStarted}
                                    totalPax={totalPax}
                                    totalPaxDesired={totalPaxDesired}
                                    maxPax={maxPax}
                                    totalCargo={totalCargo}
                                    totalCargoDesired={totalCargoDesired}
                                    maxCargo={maxCargo}
                                    zfw={zfw}
                                    zfwDesired={zfwDesired}
                                    zfwCgMac={zfwCgMac}
                                    desiredZfwCgMac={desiredZfwCgMac}
                                    gw={gw}
                                    gwDesired={gwDesired}
                                    gwCgMac={gwCgMac}
                                    desiredGwCgMac={desiredGwCgMac}
                                    setTargetPax={setTargetPax}
                                    setTargetCargo={setTargetCargo}
                                    processZfw={processZfw}
                                    processGw={processGw}
                                    setDisplayZfw={setDisplayZfw}
                                />
                                <hr className="mb-4 border-gray-700" />
                                <div className="flex flex-row items-center justify-start">
                                    <MiscParamsInput
                                        disable={gsxPayloadSyncEnabled === 1 && boardingStarted}
                                        minPaxWeight={Math.round(Loadsheet.specs.pax.minPaxWeight)}
                                        maxPaxWeight={Math.round(Loadsheet.specs.pax.maxPaxWeight)}
                                        defaultPaxWeight={Math.round(Loadsheet.specs.pax.defaultPaxWeight)}
                                        minBagWeight={Math.round(Loadsheet.specs.pax.minBagWeight)}
                                        maxBagWeight={Math.round(Loadsheet.specs.pax.maxBagWeight)}
                                        defaultBagWeight={Math.round(Loadsheet.specs.pax.defaultBagWeight)}
                                        paxWeight={paxWeight}
                                        bagWeight={paxBagWeight}
                                        massUnitForDisplay={massUnitForDisplay}
                                        setPaxWeight={setPaxWeight}
                                        setBagWeight={setPaxBagWeight}
                                    />
                                    {gsxPayloadSyncEnabled !== 1 && (
                                        <BoardingInput boardingStatusClass={boardingStatusClass} boardingStarted={boardingStarted} totalPax={totalPax} totalCargo={totalCargo} setBoardingStarted={setBoardingStarted} handleDeboarding={handleDeboarding} />
                                    )}
                                </div>
                            </Card>
                            {showSimbriefButton
                                && (
                                    <TooltipWrapper text={t('Ground.Payload.TT.FillPayloadFromSimbrief')}>
                                        <div
                                            className={`flex h-auto items-center justify-center rounded-md rounded-l-none
                                                       border-2 border-theme-highlight bg-theme-highlight
                                                       px-2 text-theme-body transition duration-100 hover:bg-theme-body hover:text-theme-highlight`}
                                            onClick={setSimBriefValues}
                                        >
                                            <CloudArrowDown size={26} />
                                        </div>
                                    </TooltipWrapper>
                                )}
                        </div>
                        {(gsxPayloadSyncEnabled !== 1) && (
                            <div className="mt-4 flex flex-row">
                                <Card className="h-full w-full" childrenContainerClassName="flex flex-col w-full h-full">
                                    <div className="flex flex-row items-center justify-between">
                                        <div className="flex font-medium">
                                            {t('Ground.Payload.BoardingTime')}
                                            <span className="relative ml-2 flex flex-row items-center text-sm font-light">
                                                (
                                                {remainingTimeString()}
                                                )
                                            </span>
                                        </div>

                                        <SelectGroup>
                                            <SelectItem
                                                selected={boardingRate === 'INSTANT'}
                                                onSelect={() => setBoardingRate('INSTANT')}
                                            >
                                                {t('Settings.Instant')}
                                            </SelectItem>

                                            <TooltipWrapper text={`${!coldAndDark ? t('Ground.Fuel.TT.AircraftMustBeColdAndDarkToChangeRefuelTimes') : ''}`}>
                                                <div>
                                                    <SelectItem
                                                        className={`${!coldAndDark && 'opacity-20'}`}
                                                        selected={boardingRate === 'FAST'}
                                                        disabled={!coldAndDark}
                                                        onSelect={() => setBoardingRate('FAST')}
                                                    >
                                                        {t('Settings.Fast')}
                                                    </SelectItem>
                                                </div>
                                            </TooltipWrapper>

                                            <div>
                                                <SelectItem
                                                    className={`${!coldAndDark && 'opacity-20'}`}
                                                    selected={boardingRate === 'REAL'}
                                                    disabled={!coldAndDark}
                                                    onSelect={() => setBoardingRate('REAL')}
                                                >
                                                    {t('Settings.Real')}
                                                </SelectItem>
                                            </div>
                                        </SelectGroup>
                                    </div>
                                </Card>
                            </div>
                        )}
                        {gsxPayloadSyncEnabled === 1 && (
                            <div className="pl-2 pt-6">
                                {t('Ground.Payload.GSXPayloadSyncEnabled')}
                            </div>
                        )}
                    </div>
                    <div className="col-1 border border-theme-accent">
                        <ChartWidget
                            width={525}
                            height={511}
                            envelope={Loadsheet.chart.performanceEnvelope}
                            limits={Loadsheet.chart.chartLimits}
                            cg={boardingStarted ? Math.round(gwCgMac * 100) / 100 : Math.round(desiredGwCgMac * 100) / 100}
                            gw={boardingStarted ? Math.round(gw) : Math.round(gwDesired)}
                            mldwCg={boardingStarted ? Math.round(gwCgMac * 100) / 100 : Math.round(desiredGwCgMac * 100) / 100}
                            mldw={boardingStarted ? Math.round(gw) : Math.round(gwDesired)}
                            zfwCg={boardingStarted ? Math.round(zfwCgMac * 100) / 100 : Math.round(desiredZfwCgMac * 100) / 100}
                            zfw={boardingStarted ? Math.round(zfw) : Math.round(zfwDesired)}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};
