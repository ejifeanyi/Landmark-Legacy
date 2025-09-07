(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_HASH (err u101))
(define-constant ERR_INVALID_NAME (err u102))
(define-constant ERR_INVALID_DESCRIPTION (err u103))
(define-constant ERR_INVALID_LOCATION (err u104))
(define-constant ERR_LANDMARK_ALREADY_EXISTS (err u105))
(define-constant ERR_INVALID_LANDMARK_ID (err u106))
(define-constant ERR_LANDMARK_NOT_FOUND (err u107))
(define-constant ERR_INVALID_TIMESTAMP (err u108))
(define-constant ERR_AUTHORITY_NOT_VERIFIED (err u109))
(define-constant ERR_LOCATION_OUT_OF_BOUNDS (err u110))
(define-constant ERR_INVALID_BOUNDARIES (err u111))
(define-constant ERR_UPDATE_NOT_ALLOWED (err u112))
(define-constant ERR_INVALID_UPDATE_HASH (err u113))
(define-constant ERR_MAX_LANDMARKS_EXCEEDED (err u114))
(define-constant ERR_INVALID_HISTORICAL_SIGNIFICANCE (err u115))
(define-constant ERR_INVALID_CONDITION (err u116))
(define-constant ERR_INVALID_OWNERSHIP_TYPE (err u117))
(define-constant ERR_INVALID_VISITOR_CAPACITY (err u118))
(define-constant ERR_INVALID_RESTORATION_STATUS (err u119))
(define-constant ERR_INVALID_ACCESSIBILITY (err u120))
(define-constant ERR_INVALID_CULTURAL_VALUE (err u121))
(define-constant ERR_INVALID_ECONOMIC_IMPACT (err u122))
(define-constant ERR_INVALID_ENVIRONMENTAL_STATUS (err u123))
(define-constant ERR_INVALID_LEGAL_STATUS (err u124))
(define-constant ERR_INVALID_PHOTOS_HASH (err u125))
(define-constant ERR_INVALID_DOCUMENTS_HASH (err u126))
(define-constant ERR_INVALID_METADATA (err u127))
(define-constant ERR_INVALID_CATEGORY (err u128))
(define-constant ERR_INVALID_AGE (err u129))
(define-constant ERR_INVALID_SIZE (err u130))

(define-data-var next-landmark-id uint u0)
(define-data-var max-landmarks uint u1000)
(define-data-var registration-fee uint u1000)
(define-data-var authority-contract (optional principal) none)

(define-map landmarks
  uint
  {
    hash: (buff 32),
    name: (string-ascii 100),
    description: (string-utf8 500),
    location: { lat: int, lon: int },
    boundaries: { min-lat: int, max-lat: int, min-lon: int, max-lon: int },
    timestamp: uint,
    creator: principal,
    historical-significance: uint,
    condition: (string-utf8 100),
    ownership-type: (string-utf8 50),
    visitor-capacity: uint,
    restoration-status: bool,
    accessibility: (string-utf8 100),
    cultural-value: uint,
    economic-impact: uint,
    environmental-status: (string-utf8 100),
    legal-status: (string-utf8 100),
    photos-hash: (buff 32),
    documents-hash: (buff 32),
    metadata: (string-utf8 1000),
    category: (string-utf8 50),
    age: uint,
    size: uint
  }
)

(define-map landmarks-by-hash
  (buff 32)
  uint)

(define-map landmark-updates
  uint
  {
    update-hash: (buff 32),
    update-name: (string-ascii 100),
    update-description: (string-utf8 500),
    update-timestamp: uint,
    updater: principal
  }
)

(define-read-only (get-landmark (id uint))
  (map-get? landmarks id)
)

(define-read-only (get-landmark-updates (id uint))
  (map-get? landmark-updates id)
)

(define-read-only (is-landmark-registered (h (buff 32)))
  (is-some (map-get? landmarks-by-hash h))
)

(define-private (validate-hash (h (buff 32)))
  (if (is-eq (len h) u32)
      (ok true)
      ERR_INVALID_HASH)
)

(define-private (validate-name (n (string-ascii 100)))
  (if (> (len n) u0)
      (ok true)
      ERR_INVALID_NAME)
)

(define-private (validate-description (desc (string-utf8 500)))
  (if (> (len desc) u0)
      (ok true)
      ERR_INVALID_DESCRIPTION)
)

(define-private (validate-location (loc { lat: int, lon: int }))
  (let ((lat (get lat loc))
        (lon (get lon loc)))
    (if (and (>= lat -90000000) (<= lat 90000000)
             (>= lon -180000000) (<= lon 180000000))
        (ok true)
        ERR_LOCATION_OUT_OF_BOUNDS))
)

(define-private (validate-boundaries (bounds { min-lat: int, max-lat: int, min-lon: int, max-lon: int }))
  (let ((min-lat (get min-lat bounds))
        (max-lat (get max-lat bounds))
        (min-lon (get min-lon bounds))
        (max-lon (get max-lon bounds)))
    (if (and (<= min-lat max-lat)
             (<= min-lon max-lon))
        (ok true)
        ERR_INVALID_BOUNDARIES))
)

(define-private (validate-timestamp (ts uint))
  (if (>= ts block-height)
      (ok true)
      ERR_INVALID_TIMESTAMP)
)

(define-private (validate-historical-significance (hs uint))
  (if (and (>= hs u1) (<= hs u10))
      (ok true)
      ERR_INVALID_HISTORICAL_SIGNIFICANCE)
)

(define-private (validate-condition (c (string-utf8 100)))
  (if (or (is-eq c "excellent") (is-eq c "good") (is-eq c "fair") (is-eq c "poor"))
      (ok true)
      ERR_INVALID_CONDITION)
)

(define-private (validate-ownership-type (ot (string-utf8 50)))
  (if (or (is-eq ot "public") (is-eq ot "private") (is-eq ot "non-profit"))
      (ok true)
      ERR_INVALID_OWNERSHIP_TYPE)
)

(define-private (validate-visitor-capacity (vc uint))
  (if (<= vc u1000000)
      (ok true)
      ERR_INVALID_VISITOR_CAPACITY)
)

(define-private (validate-accessibility (a (string-utf8 100)))
  (if (or (is-eq a "full") (is-eq a "partial") (is-eq a "none"))
      (ok true)
      ERR_INVALID_ACCESSIBILITY)
)

(define-private (validate-cultural-value (cv uint))
  (if (and (>= cv u1) (<= cv u10))
      (ok true)
      ERR_INVALID_CULTURAL_VALUE)
)

(define-private (validate-economic-impact (ei uint))
  (if (<= ei u1000000000)
      (ok true)
      ERR_INVALID_ECONOMIC_IMPACT)
)

(define-private (validate-environmental-status (es (string-utf8 100)))
  (if (or (is-eq es "protected") (is-eq es "endangered") (is-eq es "stable"))
      (ok true)
      ERR_INVALID_ENVIRONMENTAL_STATUS)
)

(define-private (validate-legal-status (ls (string-utf8 100)))
  (if (or (is-eq ls "registered") (is-eq ls "pending") (is-eq ls "disputed"))
      (ok true)
      ERR_INVALID_LEGAL_STATUS)
)

(define-private (validate-photos-hash (ph (buff 32)))
  (if (is-eq (len ph) u32)
      (ok true)
      ERR_INVALID_PHOTOS_HASH)
)

(define-private (validate-documents-hash (dh (buff 32)))
  (if (is-eq (len dh) u32)
      (ok true)
      ERR_INVALID_DOCUMENTS_HASH)
)

(define-private (validate-metadata (m (string-utf8 1000)))
  (if (<= (len m) u1000)
      (ok true)
      ERR_INVALID_METADATA)
)

(define-private (validate-category (cat (string-utf8 50)))
  (if (or (is-eq cat "historical") (is-eq cat "natural") (is-eq cat "cultural") (is-eq cat "architectural"))
      (ok true)
      ERR_INVALID_CATEGORY)
)

(define-private (validate-age (a uint))
  (if (<= a u10000)
      (ok true)
      ERR_INVALID_AGE)
)

(define-private (validate-size (s uint))
  (if (<= s u1000000)
      (ok true)
      ERR_INVALID_SIZE)
)

(define-public (set-authority-contract (contract-principal principal))
  (begin
    (asserts! (is-none (var-get authority-contract)) ERR_AUTHORITY_NOT_VERIFIED)
    (var-set authority-contract (some contract-principal))
    (ok true))
)

(define-public (set-max-landmarks (new-max uint))
  (begin
    (asserts! (is-some (var-get authority-contract)) ERR_AUTHORITY_NOT_VERIFIED)
    (var-set max-landmarks new-max)
    (ok true))
)

(define-public (set-registration-fee (new-fee uint))
  (begin
    (asserts! (is-some (var-get authority-contract)) ERR_AUTHORITY_NOT_VERIFIED)
    (var-set registration-fee new-fee)
    (ok true))
)

(define-public (register-landmark
  (landmark-hash (buff 32))
  (name (string-ascii 100))
  (description (string-utf8 500))
  (location { lat: int, lon: int })
  (boundaries { min-lat: int, max-lat: int, min-lon: int, max-lon: int })
  (historical-significance uint)
  (condition (string-utf8 100))
  (ownership-type (string-utf8 50))
  (visitor-capacity uint)
  (restoration-status bool)
  (accessibility (string-utf8 100))
  (cultural-value uint)
  (economic-impact uint)
  (environmental-status (string-utf8 100))
  (legal-status (string-utf8 100))
  (photos-hash (buff 32))
  (documents-hash (buff 32))
  (metadata (string-utf8 1000))
  (category (string-utf8 50))
  (age uint)
  (size uint))
  (let (
        (next-id (var-get next-landmark-id))
        (current-max (var-get max-landmarks))
        (authority-check (contract-call? .authority-management is-verified-authority tx-sender))
      )
    (asserts! (< next-id current-max) ERR_MAX_LANDMARKS_EXCEEDED)

    (try! (validate-hash landmark-hash))
    (try! (validate-name name))
    (try! (validate-description description))
    (try! (validate-location location))
    (try! (validate-boundaries boundaries))
    (try! (validate-historical-significance historical-significance))
    (try! (validate-condition condition))
    (try! (validate-ownership-type ownership-type))
    (try! (validate-visitor-capacity visitor-capacity))
    (try! (validate-accessibility accessibility))
    (try! (validate-cultural-value cultural-value))
    (try! (validate-economic-impact economic-impact))
    (try! (validate-environmental-status environmental-status))
    (try! (validate-legal-status legal-status))
    (try! (validate-photos-hash photos-hash))
    (try! (validate-documents-hash documents-hash))
    (try! (validate-metadata metadata))
    (try! (validate-category category))
    (try! (validate-age age))
    (try! (validate-size size))

    (asserts! (is-ok authority-check) ERR_UNAUTHORIZED)

    (asserts! (is-none (map-get? landmarks-by-hash landmark-hash)) ERR_LANDMARK_ALREADY_EXISTS)

    (map-set landmarks next-id
      {
        hash: landmark-hash,
        name: name,
        description: description,
        location: location,
        boundaries: boundaries,
        timestamp: block-height,
        creator: tx-sender,
        historical-significance: historical-significance,
        condition: condition,
        ownership-type: ownership-type,
        visitor-capacity: visitor-capacity,
        restoration-status: restoration-status,
        accessibility: accessibility,
        cultural-value: cultural-value,
        economic-impact: economic-impact,
        environmental-status: environmental-status,
        legal-status: legal-status,
        photos-hash: photos-hash,
        documents-hash: documents-hash,
        metadata: metadata,
        category: category,
        age: age,
        size: size
      })

    (map-set landmarks-by-hash landmark-hash next-id)

    (var-set next-landmark-id (+ next-id u1))
    (print { event: "landmark-registered", id: next-id })
    (ok next-id))
)

(define-public (update-landmark
  (landmark-id uint)
  (update-hash (buff 32))
  (update-name (string-ascii 100))
  (update-description (string-utf8 500)))
  (let (
        (landmark (map-get? landmarks landmark-id))
        (authority-check (contract-call? .authority-management is-verified-authority tx-sender))
      )
    (match landmark
      l
        (begin
          (asserts! (is-eq (get creator l) tx-sender) ERR_UNAUTHORIZED)
          (try! (validate-hash update-hash))
          (try! (validate-name update-name))
          (try! (validate-description update-description))
          (asserts! (is-ok authority-check) ERR_UNAUTHORIZED)

          (let ((existing (map-get? landmarks-by-hash update-hash)))
            (asserts!
              (or (is-none existing)
                  (is-eq (default-to uffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff existing) landmark-id))
              ERR_LANDMARK_ALREADY_EXISTS))

          (let ((old-hash (get hash l)))
            (map-delete landmarks-by-hash old-hash)
            (map-set landmarks-by-hash update-hash landmark-id))

          (map-set landmarks landmark-id
            {
              hash: update-hash,
              name: update-name,
              description: update-description,
              location: (get location l),
              boundaries: (get boundaries l),
              timestamp: block-height,
              creator: tx-sender,
              historical-significance: (get historical-significance l),
              condition: (get condition l),
              ownership-type: (get ownership-type l),
              visitor-capacity: (get visitor-capacity l),
              restoration-status: (get restoration-status l),
              accessibility: (get accessibility l),
              cultural-value: (get cultural-value l),
              economic-impact: (get economic-impact l),
              environmental-status: (get environmental-status l),
              legal-status: (get legal-status l),
              photos-hash: (get photos-hash l),
              documents-hash: (get documents-hash l),
              metadata: (get metadata l),
              category: (get category l),
              age: (get age l),
              size: (get size l)
            })

          (map-set landmark-updates landmark-id
            {
              update-hash: update-hash,
              update-name: update-name,
              update-description: update-description,
              update-timestamp: block-height,
              updater: tx-sender
            })

          (print { event: "landmark-updated", id: landmark-id })
          (ok true))
      ERR_LANDMARK_NOT_FOUND))
)

(define-public (get-landmark-count)
  (ok (var-get next-landmark-id))
)

(define-public (check-landmark-existence (hash (buff 32)))
  (ok (is-landmark-registered hash))
)