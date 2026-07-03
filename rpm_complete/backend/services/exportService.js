/* services/exportService.js — Server-side Excel generation using exceljs */
const ExcelJS = require('exceljs');
const { getAllSurveys } = require('../models/surveyModel');

const TEAL = '0B6E5F';
const TEAL_LIGHT = 'E6F7F4';
const HEADER_FONT = { bold: true, color: { argb: 'FF' + TEAL }, size: 11 };
const HEADER_FILL = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF' + TEAL_LIGHT } };

function autoWidth(ws, minW = 10, maxW = 50) {
  ws.columns.forEach(col => {
    let max = minW;
    col.eachCell({ includeEmpty: true }, cell => {
      const len = cell.value ? String(cell.value).length : 0;
      if (len > max) max = len;
    });
    col.width = Math.min(max + 2, maxW);
  });
}

function styleHeader(ws) {
  const hdr = ws.getRow(1);
  hdr.eachCell(cell => {
    cell.font = HEADER_FONT;
    cell.fill = HEADER_FILL;
    cell.border = {
      bottom: { style: 'thin', color: { argb: 'FFB3E6DE' } },
    };
    cell.alignment = { horizontal: 'center', wrapText: true };
  });
  hdr.height = 28;
}

async function generateExcel(filters = {}) {
  // Log for debugging
  console.log('Generating Excel with filters:', filters);

  const surveys = await getAllSurveys(filters);
  console.log(`Found ${surveys.length} surveys for export.`);

  const wb = new ExcelJS.Workbook();
  wb.creator = 'Rajapalayam Municipality Survey System';
  wb.created = new Date();

  // Robust string converter
  const w = v => {
    if (v === null || v === undefined) return '';
    return String(v).trim();
  };

  /* ══ SHEET 1: Families ══ */
  const ws1 = wb.addWorksheet('Family Survey');
  ws1.addRow([
    'Survey ID', 'Ward', 'Ward LGD Code', 'Door No.', 'Street Name',
    'Family Head Name', 'Family Register No.', 'Ration Card No.',
    'ABHA ID', 'PMJA No.', 'PHR No.', 'Smart Card ID',
    'BPL / APL', 'Community (Caste)', 'Govt / Private Health Insurance',
    'Type of House', 'Water Source', 'Toilet Facility',
    'Total Members', 'Total Eligible Couples',
    'Survey Date', 'Collector Name', 'Collector Ward',
  ]);
  styleHeader(ws1);

  surveys.forEach(s => {
    const lgd = (s.ward.match(/LGD:\s*(\d+)/) || [])[1] || '';
    ws1.addRow([
      w(s.surveyId), w(s.ward.replace(/\s*\(LGD:[^)]*\)/, '')), w(lgd),
      w(s.door), w(s.street), w(s.head), w(s.famno), w(s.ration),
      w(s.abha), w(s.pmja), w(s.phr), w(s.smartcard),
      w(s.bpl), w(s.caste), w(s.insurance),
      w(s.housing), w(s.water), w(s.toilet),
      (s.members || []).length, (s.couples || []).length,
      w(s.date), w(s.collector), w(s.collectorWard),
    ]);
  });
  autoWidth(ws1);

  /* ══ SHEET 2: Members ══ */
  const ws2 = wb.addWorksheet('Family Members');
  ws2.addRow([
    'Survey ID', 'Ward', 'Door No.', 'Street', 'Family Head',
    'Member No.', 'Full Name', 'Relationship to Head', 'Date of Birth', 'Age', 'Gender',
    'Aadhar Card No.', 'Mobile Number', 'Blood Group', 'Marital Status',
    'Educational Qualification', 'Job / Occupation', 'Annual Family Income', 'Religion',
    'Death / Separation Date', 'Death / Separation Reason',
    'New Addition Date', 'New Addition Reason',
    'Persons with Disabilities', 'Has Chronic Disease?',
    'Non-Communicable Diseases', 'Communicable Diseases', 'Treatment Place',
    'Insurance & Welfare Schemes', 'Vaccination Status', 'Remarks',
  ]);
  styleHeader(ws2);

  surveys.forEach(s => {
    (s.members || []).forEach(m => {
      ws2.addRow([
        w(s.surveyId), w(s.ward.replace(/\s*\(LGD:[^)]*\)/, '')), w(s.door), w(s.street), w(s.head),
        w(m.memno), w(m.name), w(m.rel), w(m.dob), w(m.age), w(m.gender),
        w(m.aadhar), w(m.mobile), w(m.blood), w(m.marital),
        w(m.edu), w(m.occ), w(m.income), w(m.religion),
        w(m.deathDate), w(m.deathReason),
        w(m.newMemDate), w(m.newMemReason),
        w(m.disability), w(m.hasChronicDisease),
        w(m.chronicNCD), w(m.chronicCD), w(m.treatmentPlace),
        w(m.schemes), w(m.vaccination), w(m.remarks),
      ]);
    });
  });
  autoWidth(ws2);

  /* ══ SHEET 3: Eligible Couples ══ */
  const ws3 = wb.addWorksheet('Eligible Couples');
  ws3.addRow([
    'Survey ID', 'Ward', 'FR No.', 'EC No.', 'RCH ID',
    'Husband Name', 'Wife Name', 'Registration Date',
    'Bank A/C', 'Bank Branch',
    'Husband Age at Marriage', 'Wife Age at Marriage', "Mother's Current Age",
    'Total Pregnancies', 'Living Sons', 'Living Daughters', 'Abortions',
    'Youngest Child DOB', 'Last Delivery Date', 'Child Born This Year',
    'Last Delivery Place', 'Delivery Type', 'Post-Delivery Health',
    'Contraceptive Method', 'Stopping / Spacing', 'No Contraception Reason',
    'Sterilisation Date', 'Sterilisation Place',
    'Pregnancy Test', 'AN Number', 'ANC Done', 'ANC Date', 'Next Visit',
    'Planned Delivery Place', 'Current Health Status', 'Remarks',
  ]);
  styleHeader(ws3);

  surveys.forEach(s => {
    (s.couples || []).forEach(c => {
      ws3.addRow([
        w(s.surveyId), w(s.ward.replace(/\s*\(LGD:[^)]*\)/, '')),
        w(c.frno), w(c.ecno), w(c.rchid),
        w(c.husbandName), w(c.wifeName), w(c.regDate),
        w(c.bankAc), w(c.bankBranch),
        w(c.husbandAgeAtMarriage), w(c.wifeAgeAtMarriage), w(c.motherCurrentAge),
        w(c.totalPregnancies), w(c.livingSons), w(c.livingDaughters), w(c.abortions),
        w(c.youngestChildDOB), w(c.lastDeliveryDate), w(c.childBornThisYear),
        w(c.lastDeliveryPlace), w(c.deliveryType), w(c.postDeliveryHealth),
        w(c.contraceptiveMethod), w(c.stoppingOrSpacing), w(c.noContraReason),
        w(c.sterilisationDate), w(c.sterilisationPlace),
        w(c.pregnancyTest), w(c.anNumber), w(c.ancDone), w(c.ancDate), w(c.nextVisit),
        w(c.plannedDeliveryPlace), w(c.currentHealthStatus), w(c.remarks),
      ]);
    });
  });
  autoWidth(ws3);

  /* ── Style even rows lightly ── */
  [ws1, ws2, ws3].forEach(ws => {
    ws.eachRow((row, rowNumber) => {
      if (rowNumber > 1 && rowNumber % 2 === 0) {
        row.eachCell(cell => {
          cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF8FAFC' } };
        });
      }
    });
  });

  const buffer = await wb.xlsx.writeBuffer();
  return buffer;
}

module.exports = { generateExcel };
