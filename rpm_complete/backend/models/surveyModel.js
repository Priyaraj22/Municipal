/* models/surveyModel.js */
const { pool } = require('../config/db');

function rowToSurvey(row, members = [], couples = []) {
  return {
    id:              row.id,
    surveyId:        row.survey_id,
    ward:            row.ward,
    door:            row.door,
    street:          row.street,
    famno:           row.famno || '',
    head:            row.head,
    ration:          row.ration || '',
    abha:            row.abha || '',
    pmja:            row.pmja || '',
    phr:             row.phr || '',
    smartcard:       row.smartcard || '',
    phone:           row.phone || '',
    bpl:             row.bpl || '',
    caste:           row.caste || '',
    insurance:       row.insurance || '',
    housing:         row.housing || '',
    water:           row.water || '',
    toilet:          row.toilet || '',
    status:          row.status || 'Submitted',
    collector:       row.collector,
    collectorWard:   row.collector_ward,
    date:            row.survey_date,
    members:         members.map(memberRowToObj),
    couples:         couples.map(coupleRowToObj),
  };
}

function memberRowToObj(m) {
  const safeDate = d => (d ? d.toISOString().split('T')[0] : '');
  return {
    memno:              m.memno || '',
    name:               m.name,
    rel:                m.rel || '',
    dob:                safeDate(m.dob),
    age:                m.age || '',
    gender:             m.gender || '',
    aadhar:             m.aadhar || '',
    mobile:             m.mobile || '',
    blood:              m.blood || '',
    marital:            m.marital || '',
    edu:                m.edu || '',
    occ:                m.occ || '',
    income:             m.income || '',
    religion:           m.religion || '',
    deathDate:          safeDate(m.death_date),
    deathReason:        m.death_reason || '',
    newMemDate:         safeDate(m.new_mem_date),
    newMemReason:       m.new_mem_reason || '',
    disability:         m.disability || '',
    hasChronicDisease:  m.has_chronic_disease || '',
    chronicNCD:         m.chronic_ncd || '',
    chronicCD:          m.chronic_cd || '',
    treatmentPlace:     m.treatment_place || '',
    schemes:            m.schemes || '',
    vaccination:        m.vaccination || '',
    remarks:            m.remarks || '',
  };
}

function coupleRowToObj(c) {
  const safeDate = d => (d ? d.toISOString().split('T')[0] : '');
  return {
    frno:                    c.frno || '',
    ecno:                    c.ecno || '',
    rchid:                   c.rchid || '',
    husbandName:             c.husband_name || '',
    wifeName:                c.wife_name || '',
    regDate:                 safeDate(c.reg_date),
    bankAc:                  c.bank_ac || '',
    bankBranch:              c.bank_branch || '',
    husbandAgeAtMarriage:    c.husband_age_at_marriage || '',
    wifeAgeAtMarriage:       c.wife_age_at_marriage || '',
    motherCurrentAge:        c.mother_current_age || '',
    totalPregnancies:        c.total_pregnancies || '',
    livingSons:              c.living_sons || '',
    livingDaughters:         c.living_daughters || '',
    abortions:               c.abortions || '',
    youngestChildDOB:        safeDate(c.youngest_child_dob),
    lastDeliveryDate:        safeDate(c.last_delivery_date),
    childBornThisYear:       c.child_born_this_year || '',
    lastDeliveryPlace:       c.last_delivery_place || '',
    deliveryType:            c.delivery_type || '',
    postDeliveryHealth:      c.post_delivery_health || '',
    contraceptiveMethod:     c.contraceptive_method || '',
    stoppingOrSpacing:       c.stopping_or_spacing || '',
    noContraReason:          c.no_contra_reason || '',
    sterilisationDate:       safeDate(c.sterilisation_date),
    sterilisationPlace:      c.sterilisation_place || '',
    pregnancyTest:           c.pregnancy_test || '',
    anNumber:                c.an_number || '',
    ancDone:                 c.anc_done || '',
    ancDate:                 safeDate(c.anc_date),
    nextVisit:               safeDate(c.next_visit),
    plannedDeliveryPlace:    c.planned_delivery_place || '',
    currentHealthStatus:     c.current_health_status || '',
    remarks:                 c.remarks || '',
  };
}

function safeDate(val) {
  if (!val || val === '') return null;
  const d = new Date(val);
  return isNaN(d.getTime()) ? null : val;
}

async function getAllSurveys(filters = {}) {
  const conditions = [];
  const params = [];
  if (filters.id) {
    params.push(filters.id);
    conditions.push(`s.id = $${params.length}`);
  }
  if (filters.ward) {
    params.push(filters.ward);
    conditions.push(`s.ward = $${params.length}`);
  }
  if (filters.status) {
    params.push(filters.status);
    conditions.push(`s.status = $${params.length}`);
  }
  if (filters.collector) {
    params.push('%' + filters.collector.trim() + '%');
    conditions.push(`s.collector ILIKE $${params.length}`);
  }
  const where = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';

  const { rows: surveyRows } = await pool.query(`SELECT * FROM surveys s ${where} ORDER BY s.id DESC`, params);
  if (!surveyRows.length) return [];

  const ids = surveyRows.map(r => r.id);
  const { rows: memberRows } = await pool.query(`SELECT * FROM family_members WHERE survey_id = ANY($1) ORDER BY survey_id, id`, [ids]);
  const { rows: coupleRows } = await pool.query(`SELECT * FROM eligible_couples WHERE survey_id = ANY($1) ORDER BY survey_id, id`, [ids]);

  const membersMap = {};
  const couplesMap = {};
  memberRows.forEach(m => { (membersMap[m.survey_id] = membersMap[m.survey_id] || []).push(m); });
  coupleRows.forEach(c => { (couplesMap[c.survey_id] = couplesMap[c.survey_id] || []).push(c); });

  return surveyRows.map(r => rowToSurvey(r, membersMap[r.id] || [], couplesMap[r.id] || []));
}

async function getSurveyById(id) {
  const { rows } = await pool.query('SELECT * FROM surveys WHERE id = $1', [id]);
  if (!rows.length) return null;
  const s = rows[0];
  const { rows: members } = await pool.query('SELECT * FROM family_members WHERE survey_id = $1 ORDER BY id', [s.id]);
  const { rows: couples } = await pool.query('SELECT * FROM eligible_couples WHERE survey_id = $1 ORDER BY id', [s.id]);
  return rowToSurvey(s, members, couples);
}

async function updateSurvey(id, data) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(
<<<<<<< HEAD
            `UPDATE surveys SET head=$1, door=$2, street=$3, ration=$4, abha=$5, pmja=$6, phr=$7, smartcard=$8, phone=$9, bpl=$10, caste=$11, housing=$12, water=$13, toilet=$14, updated_at=NOW() WHERE id=$15`,
            [data.head, data.door, data.street, data.ration, data.abha, data.pmja, data.phr, data.smartcard, data.phone, data.bpl, data.caste, data.housing, data.water, data.toilet, id]
=======
            `UPDATE surveys SET head=$1, door=$2, street=$3, ration=$4, abha=$5, pmja=$6, phr=$7, smartcard=$8, bpl=$9, caste=$10, housing=$11, water=$12, toilet=$13, status=$14, updated_at=NOW() WHERE id=$15`,
            [data.head, data.door, data.street, data.ration, data.abha, data.pmja, data.phr, data.smartcard, data.bpl, data.caste, data.housing, data.water, data.toilet, data.status, id]
>>>>>>> origin
        );
        await client.query('DELETE FROM family_members WHERE survey_id = $1', [id]);
        for (const m of (data.members || [])) {
            await client.query(
                `INSERT INTO family_members (survey_id, memno, name, rel, dob, age, gender, aadhar, mobile, blood, marital, edu, occ, income, religion, disability, has_chronic_disease, chronic_ncd, chronic_cd, treatment_place, schemes, vaccination, remarks) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23)`,
                [id, m.memno, m.name, m.rel, safeDate(m.dob), m.age, m.gender, m.aadhar, m.mobile, m.blood, m.marital, m.edu, m.occ, m.income, m.religion, m.disability, m.hasChronicDisease, m.chronicNCD, m.chronicCD, m.treatmentPlace, m.schemes, m.vaccination, m.remarks]
            );
        }
        await client.query('COMMIT');
        return getSurveyById(id);
    } catch (e) {
        await client.query('ROLLBACK');
        throw e;
    } finally { client.release(); }
}

async function createSurvey(data) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const today = new Date().toLocaleDateString('en-IN');
    const { rows } = await client.query(
<<<<<<< HEAD
      `INSERT INTO surveys (ward, door, street, famno, head, ration, abha, pmja, phr, smartcard, phone, bpl, caste, insurance, housing, water, toilet, collector, collector_ward, survey_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20) RETURNING *`,
      [data.ward, data.door, data.street, data.famno || '', data.head, data.ration || '', data.abha || '', data.pmja || '', data.phr || '', data.smartcard || '', data.phone, data.bpl || '', data.caste || '', data.insurance || '', data.housing || '', data.water || '', data.toilet || '', data.collector, data.collectorWard, data.date || today]
=======
      `INSERT INTO surveys (ward, door, street, famno, head, ration, abha, pmja, phr, smartcard, bpl, caste, insurance, housing, water, toilet, status, collector, collector_ward, survey_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20) RETURNING *`,
      [data.ward, data.door, data.street, data.famno || '', data.head, data.ration || '', data.abha || '', data.pmja || '', data.phr || '', data.smartcard || '', data.bpl || '', data.caste || '', data.insurance || '', data.housing || '', data.water || '', data.toilet || '', data.status || 'Submitted', data.collector, data.collectorWard, data.date || today]
>>>>>>> origin
    );
    const survey = rows[0];
    for (const m of (data.members || [])) {
        await client.query(
            `INSERT INTO family_members (survey_id, memno, name, rel, dob, age, gender, aadhar, mobile, blood, marital, edu, occ, income, religion, disability, has_chronic_disease, chronic_ncd, chronic_cd, treatment_place, schemes, vaccination, remarks) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23)`,
            [survey.id, m.memno, m.name, m.rel, safeDate(m.dob), m.age, m.gender, m.aadhar, m.mobile, m.blood, m.marital, m.edu, m.occ, m.income, m.religion, m.disability, m.hasChronicDisease, m.chronicNCD, m.chronicCD, m.treatmentPlace, m.schemes, m.vaccination, m.remarks]
        );
    }
    await client.query('COMMIT');
    return getSurveyById(survey.id);
  } catch (err) { await client.query('ROLLBACK'); throw err; } finally { client.release(); }
}

async function deleteSurveyById(id) {
  const { rowCount } = await pool.query('DELETE FROM surveys WHERE id = $1', [id]);
  return rowCount > 0;
}

async function deleteAllSurveys() {
  const { rowCount } = await pool.query('DELETE FROM surveys');
  await pool.query('ALTER SEQUENCE survey_code_seq RESTART WITH 1');
  return rowCount;
}

module.exports = { getAllSurveys, getSurveyById, createSurvey, updateSurvey, deleteSurveyById, deleteAllSurveys };
