/* services/indicatorService.js
   Server-side aggregation of survey indicators directly from
   PostgreSQL. Supports the same filters (ward / collector) as
   the surveys endpoint. The admin dashboard's "Survey Indicators"
   tab computes its own breakdown client-side from the already-loaded
   survey list (kept for 1:1 UI parity with the original app); this
   endpoint exposes the same underlying numbers via the REST API. */
const { pool } = require('../config/db');

function buildWhere(filters, alias = 's') {
  const conditions = [];
  const params = [];
  if (filters.ward) {
    params.push(filters.ward);
    conditions.push(`${alias}.ward = $${params.length}`);
  }
  if (filters.collector) {
    params.push(filters.collector);
    conditions.push(`${alias}.collector = $${params.length}`);
  }
  return {
    where: conditions.length ? 'WHERE ' + conditions.join(' AND ') : '',
    params,
  };
}

async function getIndicators(filters = {}) {
  const { where, params } = buildWhere(filters, 's');

  const surveyStats = await pool.query(
    `SELECT
       COUNT(*)                                    AS total_families,
       COUNT(*) FILTER (WHERE bpl = 'BPL')         AS bpl_families,
       COUNT(*) FILTER (WHERE bpl = 'APL')         AS apl_families,
       COUNT(*) FILTER (WHERE insurance = 'Yes')   AS insured_families,
       COUNT(*) FILTER (WHERE insurance = 'No')    AS uninsured_families,
       COUNT(DISTINCT ward)                        AS wards_covered
     FROM surveys s ${where}`,
    params
  );

  const casteStats = await pool.query(
    `SELECT COALESCE(caste, 'Unknown') AS caste, COUNT(*) AS count
     FROM surveys s ${where}
     GROUP BY caste`,
    params
  );

  // Members + couples joins need the survey filter re-applied with new placeholders
  const { where: whereM, params: paramsM } = buildWhere(filters, 's');
  const memberStats = await pool.query(
    `SELECT
       COUNT(*)                                                       AS total_members,
       COUNT(*) FILTER (WHERE m.gender = 'Male')                      AS male,
       COUNT(*) FILTER (WHERE m.gender = 'Female')                    AS female,
       COUNT(*) FILTER (WHERE m.gender NOT IN ('Male','Female')
                          OR m.gender IS NULL OR m.gender = '')        AS other_gender,
       COUNT(*) FILTER (WHERE m.age IS NOT NULL AND m.age < 18)        AS children_under_18,
       COUNT(*) FILTER (WHERE m.age >= 18 AND m.age < 60)              AS adults_18_59,
       COUNT(*) FILTER (WHERE m.age >= 60)                             AS senior_60_plus,
       COUNT(*) FILTER (WHERE m.has_chronic_disease = 'Yes')           AS chronic_disease_count,
       COUNT(*) FILTER (WHERE m.disability IS NOT NULL
                          AND m.disability <> '' AND m.disability <> 'None') AS disability_count,
       COUNT(*) FILTER (WHERE m.vaccination = 'Fully Vaccinated')      AS fully_vaccinated,
       COUNT(*) FILTER (WHERE m.death_date IS NOT NULL)                AS deaths_recorded,
       COUNT(*) FILTER (WHERE m.new_mem_date IS NOT NULL)              AS new_additions
     FROM family_members m
     JOIN surveys s ON s.id = m.survey_id
     ${whereM}`,
    paramsM
  );

  const { where: whereC, params: paramsC } = buildWhere(filters, 's');
  const coupleStats = await pool.query(
    `SELECT
       COUNT(*)                                                  AS total_eligible_couples,
       COUNT(*) FILTER (WHERE c.contraceptive_method IS NOT NULL
                          AND c.contraceptive_method <> ''
                          AND c.contraceptive_method <> 'None')   AS using_contraception,
       COUNT(*) FILTER (WHERE c.anc_done = 'Yes')                 AS anc_done,
       COUNT(*) FILTER (WHERE c.child_born_this_year = 'Yes')     AS children_born_this_year
     FROM eligible_couples c
     JOIN surveys s ON s.id = c.survey_id
     ${whereC}`,
    paramsC
  );

  return {
    families: {
      total:    parseInt(surveyStats.rows[0].total_families, 10),
      bpl:      parseInt(surveyStats.rows[0].bpl_families, 10),
      apl:      parseInt(surveyStats.rows[0].apl_families, 10),
      insured:  parseInt(surveyStats.rows[0].insured_families, 10),
      uninsured: parseInt(surveyStats.rows[0].uninsured_families, 10),
      wardsCovered: parseInt(surveyStats.rows[0].wards_covered, 10),
    },
    caste: casteStats.rows.map(r => ({ caste: r.caste, count: parseInt(r.count, 10) })),
    members: {
      total:           parseInt(memberStats.rows[0].total_members, 10),
      male:            parseInt(memberStats.rows[0].male, 10),
      female:          parseInt(memberStats.rows[0].female, 10),
      other:           parseInt(memberStats.rows[0].other_gender, 10),
      childrenUnder18: parseInt(memberStats.rows[0].children_under_18, 10),
      adults18to59:    parseInt(memberStats.rows[0].adults_18_59, 10),
      seniors60Plus:   parseInt(memberStats.rows[0].senior_60_plus, 10),
      chronicDisease:  parseInt(memberStats.rows[0].chronic_disease_count, 10),
      disability:      parseInt(memberStats.rows[0].disability_count, 10),
      fullyVaccinated: parseInt(memberStats.rows[0].fully_vaccinated, 10),
      deathsRecorded:  parseInt(memberStats.rows[0].deaths_recorded, 10),
      newAdditions:    parseInt(memberStats.rows[0].new_additions, 10),
    },
    eligibleCouples: {
      total:             parseInt(coupleStats.rows[0].total_eligible_couples, 10),
      usingContraception: parseInt(coupleStats.rows[0].using_contraception, 10),
      ancDone:           parseInt(coupleStats.rows[0].anc_done, 10),
      childrenBornThisYear: parseInt(coupleStats.rows[0].children_born_this_year, 10),
    },
  };
}

module.exports = { getIndicators };
