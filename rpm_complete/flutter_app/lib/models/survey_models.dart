// models/survey_models.dart
// Data models matching the PostgreSQL schema exactly.

class Ward {
  final int id;
  final int wardNo;
  final String wardName;
  final int lgdCode;

  Ward({required this.id, required this.wardNo, required this.wardName, required this.lgdCode});

  factory Ward.fromJson(Map<String, dynamic> j) => Ward(
        id:       j['id'] ?? 0,
        wardNo:   j['ward_no'] ?? j['wardNo'] ?? 0,
        wardName: j['ward_name'] ?? j['wardName'] ?? '',
        lgdCode:  j['lgd_code'] ?? j['lgdCode'] ?? 0,
      );

  @override
  String toString() => wardName;
}

// ── Family Member ──────────────────────────────────────────────────────────────
class FamilyMember {
  String memno;
  String name;
  String rel;
  String dob;
  String age;
  String gender;
  String aadhar;
  String mobile;
  String blood;
  String marital;
  String edu;
  String occ;
  String income;
  String religion;
  String deathDate;
  String deathReason;
  String newMemDate;
  String newMemReason;
  String disability;
  String hasChronicDisease;
  String chronicNCD;
  String chronicCD;
  String treatmentPlace;
  String schemes;
  String vaccination;
  String remarks;

  FamilyMember({
    this.memno = '',
    this.name = '',
    this.rel = '',
    this.dob = '',
    this.age = '',
    this.gender = '',
    this.aadhar = '',
    this.mobile = '',
    this.blood = '',
    this.marital = '',
    this.edu = '',
    this.occ = '',
    this.income = '',
    this.religion = '',
    this.deathDate = '',
    this.deathReason = '',
    this.newMemDate = '',
    this.newMemReason = '',
    this.disability = '',
    this.hasChronicDisease = '',
    this.chronicNCD = '',
    this.chronicCD = '',
    this.treatmentPlace = '',
    this.schemes = '',
    this.vaccination = '',
    this.remarks = '',
  });

  factory FamilyMember.fromJson(Map<String, dynamic> j) => FamilyMember(
        memno:              j['memno'] ?? '',
        name:               j['name'] ?? '',
        rel:                j['rel'] ?? '',
        dob:                j['dob'] ?? '',
        age:                j['age']?.toString() ?? '',
        gender:             j['gender'] ?? '',
        aadhar:             j['aadhar'] ?? '',
        mobile:             j['mobile'] ?? '',
        blood:              j['blood'] ?? '',
        marital:            j['marital'] ?? '',
        edu:                j['edu'] ?? '',
        occ:                j['occ'] ?? '',
        income:             j['income']?.toString() ?? '',
        religion:           j['religion'] ?? '',
        deathDate:          j['deathDate'] ?? '',
        deathReason:        j['deathReason'] ?? '',
        newMemDate:         j['newMemDate'] ?? '',
        newMemReason:       j['newMemReason'] ?? '',
        disability:         j['disability'] ?? '',
        hasChronicDisease:  j['hasChronicDisease'] ?? '',
        chronicNCD:         j['chronicNCD'] ?? '',
        chronicCD:          j['chronicCD'] ?? '',
        treatmentPlace:     j['treatmentPlace'] ?? '',
        schemes:            j['schemes'] ?? '',
        vaccination:        j['vaccination'] ?? '',
        remarks:            j['remarks'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'memno': memno, 'name': name, 'rel': rel, 'dob': dob,
        'age': age, 'gender': gender, 'aadhar': aadhar, 'mobile': mobile,
        'blood': blood, 'marital': marital, 'edu': edu, 'occ': occ,
        'income': income, 'religion': religion,
        'deathDate': deathDate, 'deathReason': deathReason,
        'newMemDate': newMemDate, 'newMemReason': newMemReason,
        'disability': disability, 'hasChronicDisease': hasChronicDisease,
        'chronicNCD': chronicNCD, 'chronicCD': chronicCD,
        'treatmentPlace': treatmentPlace, 'schemes': schemes,
        'vaccination': vaccination, 'remarks': remarks,
      };
}

// ── Eligible Couple — ALL 35 DB fields ────────────────────────────────────────
class EligibleCouple {
  String frno;
  String ecno;
  String rchid;
  String husbandName;
  String wifeName;
  String regDate;
  String bankAc;
  String bankBranch;
  String husbandAgeAtMarriage;
  String wifeAgeAtMarriage;
  String motherCurrentAge;
  String totalPregnancies;
  String livingSons;
  String livingDaughters;
  String abortions;
  String youngestChildDOB;
  String lastDeliveryDate;
  String childBornThisYear;
  String lastDeliveryPlace;
  String deliveryType;
  String postDeliveryHealth;
  String contraceptiveMethod;
  String stoppingOrSpacing;
  String noContraReason;
  String sterilisationDate;
  String sterilisationPlace;
  String pregnancyTest;
  String anNumber;
  String ancDone;
  String ancDate;
  String nextVisit;
  String plannedDeliveryPlace;
  String currentHealthStatus;
  String remarks;

  EligibleCouple({
    this.frno = '',
    this.ecno = '',
    this.rchid = '',
    this.husbandName = '',
    this.wifeName = '',
    this.regDate = '',
    this.bankAc = '',
    this.bankBranch = '',
    this.husbandAgeAtMarriage = '',
    this.wifeAgeAtMarriage = '',
    this.motherCurrentAge = '',
    this.totalPregnancies = '',
    this.livingSons = '',
    this.livingDaughters = '',
    this.abortions = '',
    this.youngestChildDOB = '',
    this.lastDeliveryDate = '',
    this.childBornThisYear = '',
    this.lastDeliveryPlace = '',
    this.deliveryType = '',
    this.postDeliveryHealth = '',
    this.contraceptiveMethod = '',
    this.stoppingOrSpacing = '',
    this.noContraReason = '',
    this.sterilisationDate = '',
    this.sterilisationPlace = '',
    this.pregnancyTest = '',
    this.anNumber = '',
    this.ancDone = '',
    this.ancDate = '',
    this.nextVisit = '',
    this.plannedDeliveryPlace = '',
    this.currentHealthStatus = '',
    this.remarks = '',
  });

  factory EligibleCouple.fromJson(Map<String, dynamic> j) => EligibleCouple(
        frno:                 j['frno'] ?? '',
        ecno:                 j['ecno'] ?? '',
        rchid:                j['rchid'] ?? '',
        husbandName:          j['husbandName'] ?? '',
        wifeName:             j['wifeName'] ?? '',
        regDate:              j['regDate'] ?? '',
        bankAc:               j['bankAc'] ?? '',
        bankBranch:           j['bankBranch'] ?? '',
        husbandAgeAtMarriage: j['husbandAgeAtMarriage']?.toString() ?? '',
        wifeAgeAtMarriage:    j['wifeAgeAtMarriage']?.toString() ?? '',
        motherCurrentAge:     j['motherCurrentAge']?.toString() ?? '',
        totalPregnancies:     j['totalPregnancies']?.toString() ?? '',
        livingSons:           j['livingSons']?.toString() ?? '',
        livingDaughters:      j['livingDaughters']?.toString() ?? '',
        abortions:            j['abortions']?.toString() ?? '',
        youngestChildDOB:     j['youngestChildDOB'] ?? '',
        lastDeliveryDate:     j['lastDeliveryDate'] ?? '',
        childBornThisYear:    j['childBornThisYear'] ?? '',
        lastDeliveryPlace:    j['lastDeliveryPlace'] ?? '',
        deliveryType:         j['deliveryType'] ?? '',
        postDeliveryHealth:   j['postDeliveryHealth'] ?? '',
        contraceptiveMethod:  j['contraceptiveMethod'] ?? '',
        stoppingOrSpacing:    j['stoppingOrSpacing'] ?? '',
        noContraReason:       j['noContraReason'] ?? '',
        sterilisationDate:    j['sterilisationDate'] ?? '',
        sterilisationPlace:   j['sterilisationPlace'] ?? '',
        pregnancyTest:        j['pregnancyTest'] ?? '',
        anNumber:             j['anNumber'] ?? '',
        ancDone:              j['ancDone'] ?? '',
        ancDate:              j['ancDate'] ?? '',
        nextVisit:            j['nextVisit'] ?? '',
        plannedDeliveryPlace: j['plannedDeliveryPlace'] ?? '',
        currentHealthStatus:  j['currentHealthStatus'] ?? '',
        remarks:              j['remarks'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'frno': frno, 'ecno': ecno, 'rchid': rchid,
        'husbandName': husbandName, 'wifeName': wifeName, 'regDate': regDate,
        'bankAc': bankAc, 'bankBranch': bankBranch,
        'husbandAgeAtMarriage': husbandAgeAtMarriage,
        'wifeAgeAtMarriage': wifeAgeAtMarriage,
        'motherCurrentAge': motherCurrentAge,
        'totalPregnancies': totalPregnancies,
        'livingSons': livingSons, 'livingDaughters': livingDaughters,
        'abortions': abortions,
        'youngestChildDOB': youngestChildDOB,
        'lastDeliveryDate': lastDeliveryDate,
        'childBornThisYear': childBornThisYear,
        'lastDeliveryPlace': lastDeliveryPlace,
        'deliveryType': deliveryType,
        'postDeliveryHealth': postDeliveryHealth,
        'contraceptiveMethod': contraceptiveMethod,
        'stoppingOrSpacing': stoppingOrSpacing,
        'noContraReason': noContraReason,
        'sterilisationDate': sterilisationDate,
        'sterilisationPlace': sterilisationPlace,
        'pregnancyTest': pregnancyTest,
        'anNumber': anNumber,
        'ancDone': ancDone, 'ancDate': ancDate, 'nextVisit': nextVisit,
        'plannedDeliveryPlace': plannedDeliveryPlace,
        'currentHealthStatus': currentHealthStatus,
        'remarks': remarks,
      };
}

// ── Survey ─────────────────────────────────────────────────────────────────────
class Survey {
  String? id;
  final String? surveyId;
  String ward;
  String door;
  String street;
  String famno;
  String head;
  String ration;
  String abha;
  String pmja;
  String phr;
  String smartcard;
  String phone;
  String bpl;
  String caste;
  String insurance;
  String housing;
  String water;
  String toilet;
  String status;
  String? collector;
  String? collectorWard;
  String? date;
  List<FamilyMember> members;
  List<EligibleCouple> couples;

  Survey({
    this.id,
    this.surveyId,
    this.ward = '',
    this.door = '',
    this.street = '',
    this.famno = '',
    this.head = '',
    this.ration = '',
    this.abha = '',
    this.pmja = '',
    this.phr = '',
    this.smartcard = '',
    this.phone = '',
    this.bpl = '',
    this.caste = '',
    this.insurance = '',
    this.housing = '',
    this.water = '',
    this.toilet = '',
    this.status = 'Submitted',
    this.collector,
    this.collectorWard,
    this.date,
    List<FamilyMember>? members,
    List<EligibleCouple>? couples,
  })  : members = members ?? [],
        couples = couples ?? [];

  factory Survey.fromJson(Map<String, dynamic> j) => Survey(
        id:            j['id']?.toString(),
        surveyId:      j['surveyId'] ?? j['survey_id'],
        ward:          j['ward'] ?? '',
        door:          j['door'] ?? '',
        street:        j['street'] ?? '',
        famno:         j['famno'] ?? '',
        head:          j['head'] ?? '',
        ration:        j['ration'] ?? '',
        abha:          j['abha'] ?? '',
        pmja:          j['pmja'] ?? '',
        phr:           j['phr'] ?? '',
        smartcard:     j['smartcard'] ?? '',
        phone:         j['phone'] ?? '',
        bpl:           j['bpl'] ?? '',
        caste:         j['caste'] ?? '',
        insurance:     j['insurance'] ?? '',
        housing:       j['housing'] ?? '',
        water:         j['water'] ?? '',
        toilet:        j['toilet'] ?? '',
        status:        j['status'] ?? 'Submitted',
        collector:     j['collector'],
        collectorWard: j['collectorWard'] ?? j['collector_ward'],
        date:          j['date'] ?? j['survey_date'],
        members: (j['members'] as List? ?? [])
            .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
            .toList(),
        couples: (j['couples'] as List? ?? [])
            .map((c) => EligibleCouple.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'ward': ward, 'door': door, 'street': street, 'famno': famno,
        'head': head, 'ration': ration, 'abha': abha, 'pmja': pmja,
        'phr': phr, 'smartcard': smartcard,
        'phone': phone,
        'bpl': bpl, 'caste': caste, 'insurance': insurance,
        'housing': housing, 'water': water, 'toilet': toilet,
        'status': status,
        'collector': collector, 'collectorWard': collectorWard,
        'members': members.map((m) => m.toJson()).toList(),
        'couples': couples.map((c) => c.toJson()).toList(),
      };
}

// ── Dashboard ──────────────────────────────────────────────────────────────────
class DashboardData {
  final int families;
  final int members;
  final int activeWards;
  final int today;
  final Map<String, int> bplCounts;
  final Map<String, int> genderCounts;
  final Map<String, int> casteCounts;
  final Map<String, int> insuranceCounts;

  DashboardData({
    this.families = 0,
    this.members = 0,
    this.activeWards = 0,
    this.today = 0,
    this.bplCounts = const {},
    this.genderCounts = const {},
    this.casteCounts = const {},
    this.insuranceCounts = const {},
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        families:        _int(j['families']),
        members:         _int(j['members']),
        activeWards:     _int(j['activeWards'] ?? j['active_wards'] ?? j['wards']),
        today:           _int(j['today']),
        bplCounts:       _intMap(j['bplCounts'] ?? j['bpl_counts']),
        genderCounts:    _intMap(j['genderCounts'] ?? j['gender_counts']),
        casteCounts:     _intMap(j['casteCounts'] ?? j['caste_counts']),
        insuranceCounts: _intMap(j['insuranceCounts'] ?? j['insurance_counts']),
      );

  static int _int(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  static Map<String, int> _intMap(dynamic v) {
    if (v == null) return {};
    final m = Map<String, dynamic>.from(v as Map);
    return m.map((k, val) => MapEntry(k, _int(val)));
  }
}

// ── Auth State ─────────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final String? collectorName;
  final String? token;

  const AuthState({
    this.isLoggedIn = false,
    this.collectorName,
    this.token,
  });
}

// ── Complaint ──────────────────────────────────────────────────────────────────
class Complaint {
  final int? id;
  final int surveyId;
  final String citizenMobile;
  final String issueType;
  final String description;
  final String street;
  final String status;
  final String? createdAt;
  final String? feedback;
  final int? rating;
  final List<String> evidencePhotos;

  Complaint({
    this.id,
    required this.surveyId,
    required this.citizenMobile,
    required this.issueType,
    required this.description,
    required this.street,
    this.status = 'Received',
    this.createdAt,
    this.feedback,
    this.rating,
    this.evidencePhotos = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> j) => Complaint(
        id:            j['id'],
        surveyId:      j['survey_id'],
        citizenMobile: j['citizen_mobile'] ?? '',
        issueType:     j['issue_type'] ?? '',
        description:   j['description'] ?? '',
        street:        j['street'] ?? '',
        status:        j['status'] ?? 'Received',
        createdAt:     j['created_at'],
        feedback:      j['citizen_feedback'],
        rating:        j['citizen_rating'],
        evidencePhotos: (j['evidence_photos'] as List? ?? []).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'survey_id':      surveyId,
        'citizen_mobile': citizenMobile,
        'issue_type':     issueType,
        'description':    description,
        'street':         street,
        'evidence_photos': evidencePhotos,
      };
}

// ── Correction Request ───────────────────────────────────────────────────────
class CorrectionRequest {
  final int? id;
  final String surveyId;
  final String fieldName;
  final String oldValue;
  final String newValue;
  final String status;
  final String? createdAt;
  final String? surveyorName;
  final String? headName;
  final String? door;
  final String? street;

  CorrectionRequest({
    this.id,
    required this.surveyId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    this.status = 'Pending',
    this.createdAt,
    this.surveyorName,
    this.headName,
    this.door,
    this.street,
  });

  factory CorrectionRequest.fromJson(Map<String, dynamic> j) => CorrectionRequest(
        id:           j['id'],
        surveyId:     j['survey_id']?.toString() ?? '',
        fieldName:    j['field_name'] ?? '',
        oldValue:     j['old_value'] ?? '',
        newValue:     j['new_value'] ?? '',
        status:       j['status'] ?? 'Pending',
        createdAt:    j['created_at'],
        surveyorName: j['surveyor'],
        headName:     j['head_name'],
        door:         j['door'],
        street:       j['street'],
      );

  Map<String, dynamic> toJson() => {
        'survey_id':  surveyId,
        'field_name': fieldName,
        'old_value':  oldValue,
        'new_value':  newValue,
      };
}
