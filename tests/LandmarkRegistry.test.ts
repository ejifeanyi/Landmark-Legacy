import { describe, it, expect, beforeEach } from "vitest";

const ERR_UNAUTHORIZED = 100;
const ERR_INVALID_HASH = 101;
const ERR_INVALID_NAME = 102;
const ERR_INVALID_DESCRIPTION = 103;
const ERR_INVALID_LOCATION = 104;
const ERR_LANDMARK_ALREADY_EXISTS = 105;
const ERR_LANDMARK_NOT_FOUND = 107;
const ERR_LOCATION_OUT_OF_BOUNDS = 110;
const ERR_INVALID_BOUNDARIES = 111;
const ERR_MAX_LANDMARKS_EXCEEDED = 114;
const ERR_INVALID_HISTORICAL_SIGNIFICANCE = 115;
const ERR_INVALID_CONDITION = 116;
const ERR_INVALID_OWNERSHIP_TYPE = 117;
const ERR_INVALID_VISITOR_CAPACITY = 118;
const ERR_INVALID_ACCESSIBILITY = 120;
const ERR_INVALID_CULTURAL_VALUE = 121;
const ERR_INVALID_ECONOMIC_IMPACT = 122;
const ERR_INVALID_ENVIRONMENTAL_STATUS = 123;
const ERR_INVALID_LEGAL_STATUS = 124;
const ERR_INVALID_PHOTOS_HASH = 125;
const ERR_INVALID_DOCUMENTS_HASH = 126;
const ERR_INVALID_METADATA = 127;
const ERR_INVALID_CATEGORY = 128;
const ERR_INVALID_AGE = 129;
const ERR_INVALID_SIZE = 130;
const ERR_INVALID_UPDATE_HASH = 113;

interface Location {
  lat: number;
  lon: number;
}
interface Boundaries {
  minLat: number;
  maxLat: number;
  minLon: number;
  maxLon: number;
}
interface Landmark {
  hash: string;
  name: string;
  description: string;
  location: Location;
  boundaries: Boundaries;
  timestamp: number;
  creator: string;
  historicalSignificance: number;
  condition: string;
  ownershipType: string;
  visitorCapacity: number;
  restorationStatus: boolean;
  accessibility: string;
  culturalValue: number;
  economicImpact: number;
  environmentalStatus: string;
  legalStatus: string;
  photosHash: string;
  documentsHash: string;
  metadata: string;
  category: string;
  age: number;
  size: number;
}
interface LandmarkUpdate {
  updateHash: string;
  updateName: string;
  updateDescription: string;
  updateTimestamp: number;
  updater: string;
}

class LandmarkRegistryMock {
  state!: {
    nextLandmarkId: number;
    maxLandmarks: number;
    landmarks: Map<number, Landmark>;
    landmarkUpdates: Map<number, LandmarkUpdate>;
  };
  blockHeight = 0;
  caller = "ST1TEST";
  authorities = new Set<string>();

  constructor() {
    this.reset();
  }
  reset() {
    this.state = {
      nextLandmarkId: 0,
      maxLandmarks: 1000,
      landmarks: new Map(),
      landmarkUpdates: new Map(),
    };
    this.blockHeight = 0;
    this.caller = "ST1TEST";
    this.authorities = new Set(["ST1TEST"]);
  }

  isVerifiedAuthority(principal: string) {
    return { ok: true, value: this.authorities.has(principal) };
  }

  registerLandmark(
    landmarkHash: string,
    name: string,
    description: string,
    location: Location,
    boundaries: Boundaries,
    historicalSignificance: number,
    condition: string,
    ownershipType: string,
    visitorCapacity: number,
    restorationStatus: boolean,
    accessibility: string,
    culturalValue: number,
    economicImpact: number,
    environmentalStatus: string,
    legalStatus: string,
    photosHash: string,
    documentsHash: string,
    metadata: string,
    category: string,
    age: number,
    size: number
  ) {
    const nextId = this.state.nextLandmarkId;
    if (nextId >= this.state.maxLandmarks) return { ok: false, value: ERR_MAX_LANDMARKS_EXCEEDED };
    if (landmarkHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(landmarkHash)) return { ok: false, value: ERR_INVALID_HASH };
    if (!name || name.length > 100) return { ok: false, value: ERR_INVALID_NAME };
    if (!description || description.length > 500) return { ok: false, value: ERR_INVALID_DESCRIPTION };
    if (location.lat < -90 || location.lat > 90 || location.lon < -180 || location.lon > 180)
      return { ok: false, value: ERR_LOCATION_OUT_OF_BOUNDS };
    if (boundaries.minLat > boundaries.maxLat || boundaries.minLon > boundaries.maxLon)
      return { ok: false, value: ERR_INVALID_BOUNDARIES };
    if (historicalSignificance < 1 || historicalSignificance > 10) return { ok: false, value: ERR_INVALID_HISTORICAL_SIGNIFICANCE };
    if (!["excellent", "good", "fair", "poor"].includes(condition)) return { ok: false, value: ERR_INVALID_CONDITION };
    if (!["public", "private", "non-profit"].includes(ownershipType)) return { ok: false, value: ERR_INVALID_OWNERSHIP_TYPE };
    if (visitorCapacity > 1000000) return { ok: false, value: ERR_INVALID_VISITOR_CAPACITY };
    if (!["full", "partial", "none"].includes(accessibility)) return { ok: false, value: ERR_INVALID_ACCESSIBILITY };
    if (culturalValue < 1 || culturalValue > 10) return { ok: false, value: ERR_INVALID_CULTURAL_VALUE };
    if (economicImpact > 1000000000) return { ok: false, value: ERR_INVALID_ECONOMIC_IMPACT };
    if (!["protected", "endangered", "stable"].includes(environmentalStatus)) return { ok: false, value: ERR_INVALID_ENVIRONMENTAL_STATUS };
    if (!["registered", "pending", "disputed"].includes(legalStatus)) return { ok: false, value: ERR_INVALID_LEGAL_STATUS };
    if (photosHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(photosHash)) return { ok: false, value: ERR_INVALID_PHOTOS_HASH };
    if (documentsHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(documentsHash)) return { ok: false, value: ERR_INVALID_DOCUMENTS_HASH };
    if (metadata.length > 1000) return { ok: false, value: ERR_INVALID_METADATA };
    if (!["historical", "natural", "cultural", "architectural"].includes(category)) return { ok: false, value: ERR_INVALID_CATEGORY };
    if (age > 10000) return { ok: false, value: ERR_INVALID_AGE };
    if (size > 1000000) return { ok: false, value: ERR_INVALID_SIZE };

    if (!this.isVerifiedAuthority(this.caller).value) return { ok: false, value: ERR_UNAUTHORIZED };
    if (Array.from(this.state.landmarks.values()).some(l => l.hash === landmarkHash))
      return { ok: false, value: ERR_LANDMARK_ALREADY_EXISTS };

    const newLandmark: Landmark = {
      hash: landmarkHash,
      name,
      description,
      location,
      boundaries,
      timestamp: this.blockHeight,
      creator: this.caller,
      historicalSignificance,
      condition,
      ownershipType,
      visitorCapacity,
      restorationStatus,
      accessibility,
      culturalValue,
      economicImpact,
      environmentalStatus,
      legalStatus,
      photosHash,
      documentsHash,
      metadata,
      category,
      age,
      size,
    };
    this.state.landmarks.set(nextId, newLandmark);
    this.state.nextLandmarkId++;
    return { ok: true, value: nextId };
  }

  getLandmark(id: number) {
    const landmark = this.state.landmarks.get(id);
    return landmark ? { ok: true, value: landmark } : { ok: false, value: null };
  }

  updateLandmark(id: number, updateHash: string, updateName: string, updateDescription: string) {
    const landmark = this.state.landmarks.get(id);
    if (!landmark) return { ok: false, value: ERR_LANDMARK_NOT_FOUND };
    if (landmark.creator !== this.caller) return { ok: false, value: ERR_UNAUTHORIZED };
    if (updateHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(updateHash)) return { ok: false, value: ERR_INVALID_UPDATE_HASH };
    if (!updateName || updateName.length > 100) return { ok: false, value: ERR_INVALID_NAME };
    if (!updateDescription || updateDescription.length > 500) return { ok: false, value: ERR_INVALID_DESCRIPTION };

    const updated: Landmark = { ...landmark, hash: updateHash, name: updateName, description: updateDescription, timestamp: this.blockHeight };
    this.state.landmarks.set(id, updated);
    this.state.landmarkUpdates.set(id, {
      updateHash,
      updateName,
      updateDescription,
      updateTimestamp: this.blockHeight,
      updater: this.caller,
    });
    return { ok: true, value: true };
  }
}

describe("LandmarkRegistry", () => {
  let contract: LandmarkRegistryMock;
  beforeEach(() => (contract = new LandmarkRegistryMock()));

  it("registers a valid landmark", () => {
    const result = contract.registerLandmark(
      "a".repeat(64),
      "Eiffel Tower",
      "Iconic landmark",
      { lat: 48, lon: 2 },
      { minLat: 47, maxLat: 49, minLon: 1, maxLon: 3 },
      8,
      "good",
      "public",
      100000,
      false,
      "full",
      9,
      50000000,
      "stable",
      "registered",
      "b".repeat(64),
      "c".repeat(64),
      "Additional info",
      "architectural",
      135,
      324
    );
    expect(result.ok).toBe(true);
    expect(contract.getLandmark(0).value?.name).toBe("Eiffel Tower");
  });

  it("rejects invalid hash", () => {
    expect(
      contract.registerLandmark(
        "bad",
        "name",
        "desc",
        { lat: 0, lon: 0 },
        { minLat: -1, maxLat: 1, minLon: -1, maxLon: 1 },
        5,
        "good",
        "public",
        100,
        false,
        "full",
        5,
        1000,
        "stable",
        "registered",
        "b".repeat(64),
        "c".repeat(64),
        "meta",
        "historical",
        100,
        100
      )
    ).toEqual({ ok: false, value: ERR_INVALID_HASH });
  });

  it("rejects invalid location", () => {
    expect(
      contract.registerLandmark(
        "a".repeat(64),
        "name",
        "desc",
        { lat: 100, lon: 0 },
        { minLat: -1, maxLat: 1, minLon: -1, maxLon: 1 },
        5,
        "good",
        "public",
        100,
        false,
        "full",
        5,
        1000,
        "stable",
        "registered",
        "b".repeat(64),
        "c".repeat(64),
        "meta",
        "historical",
        100,
        100
      )
    ).toEqual({ ok: false, value: ERR_LOCATION_OUT_OF_BOUNDS });
  });

  it("rejects duplicate landmark", () => {
    contract.registerLandmark(
      "a".repeat(64),
      "name",
      "desc",
      { lat: 0, lon: 0 },
      { minLat: -1, maxLat: 1, minLon: -1, maxLon: 1 },
      5,
      "good",
      "public",
      100,
      false,
      "full",
      5,
      1000,
      "stable",
      "registered",
      "b".repeat(64),
      "c".repeat(64),
      "meta",
      "historical",
      100,
      100
    );
    expect(
      contract.registerLandmark(
        "a".repeat(64),
        "name2",
        "desc2",
        { lat: 0, lon: 0 },
        { minLat: -1, maxLat: 1, minLon: -1, maxLon: 1 },
        5,
        "good",
        "public",
        100,
        false,
        "full",
        5,
        1000,
        "stable",
        "registered",
        "b".repeat(64),
        "c".repeat(64),
        "meta",
        "historical",
        100,
        100
      )
    ).toEqual({ ok: false, value: ERR_LANDMARK_ALREADY_EXISTS });
  });

  it("updates a valid landmark", () => {
    contract.registerLandmark(
      "a".repeat(64),
      "old",
      "old desc",
      { lat: 0, lon: 0 },
      { minLat: -1, maxLat: 1, minLon: -1, maxLon: 1 },
      5,
      "good",
      "public",
      100,
      false,
      "full",
      5,
      1000,
      "stable",
      "registered",
      "b".repeat(64),
      "c".repeat(64),
      "meta",
      "historical",
      100,
      100
    );
    const res = contract.updateLandmark(0, "d".repeat(64), "new", "new desc");
    expect(res.ok).toBe(true);
    expect(contract.getLandmark(0).value?.name).toBe("new");
  });

  it("rejects update for non-existent landmark", () => {
    expect(contract.updateLandmark(99, "d".repeat(64), "x", "y")).toEqual({ ok: false, value: ERR_LANDMARK_NOT_FOUND });
  });
});