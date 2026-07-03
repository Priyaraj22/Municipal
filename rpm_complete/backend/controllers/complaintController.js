/* controllers/complaintController.js */
const { pool } = require('../config/db');
const { sendWhatsApp } = require('../services/whatsappService');

async function registerComplaint(req, res, next) {
    try {
        const { survey_id, citizen_mobile, issue_type, description, street } = req.body;
        const { rows } = await pool.query(
            "INSERT INTO complaints (survey_id, citizen_mobile, issue_type, description, street) VALUES ($1, $2, $3, $4, $5) RETURNING *",
            [survey_id, citizen_mobile, issue_type, description, street]
        );
        res.status(201).json(rows[0]);
    } catch (err) { next(err); }
}

async function getMyComplaints(req, res, next) {
    try {
        const { phone } = req.query;
        let query = "SELECT * FROM complaints ORDER BY id DESC";
        let params = [];
        if (phone && phone !== "") {
            query = "SELECT * FROM complaints WHERE citizen_mobile = $1 ORDER BY id DESC";
            params = [phone];
        }
        const { rows } = await pool.query(query, params);
        res.json(rows);
    } catch (err) { next(err); }
}

async function updateComplaintStatus(req, res, next) {
    try {
        const { id, status } = req.body;
        const { rows: updated } = await pool.query(
            "UPDATE complaints SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *",
            [status, id]
        );
        if (updated.length > 0) {
            await sendWhatsApp(updated[0].citizen_mobile, `Rajapalayam Municipality: Your complaint is now: ${status}.`);
        }
        res.json({ message: 'Status updated' });
    } catch (err) { next(err); }
}

async function submitFeedback(req, res, next) {
    try {
        const { id, status, feedback, rating } = req.body;
        await pool.query(
            "UPDATE complaints SET status = $1, citizen_feedback = $2, citizen_rating = $3, updated_at = NOW() WHERE id = $4",
            [status, feedback, rating, id]
        );
        res.json({ success: true });
    } catch (err) { next(err); }
}

async function requestCorrection(req, res, next) {
    try {
        const { survey_id, field_name, old_value, new_value } = req.body;
        const { rows } = await pool.query(
            "INSERT INTO correction_requests (survey_id, field_name, old_value, new_value) VALUES ($1, $2, $3, $4) RETURNING *",
            [survey_id, field_name, old_value, new_value]
        );
        res.status(201).json(rows[0]);
    } catch (err) { next(err); }
}

async function getSurveyorCorrections(req, res, next) {
    try {
        const { name } = req.query;
        const cleanName = (name || '').trim();
        const { rows } = await pool.query(
            `SELECT cr.*, s.head as head_name, s.door, s.street
             FROM correction_requests cr
             JOIN surveys s ON cr.survey_id = s.id
             WHERE s.collector ILIKE $1 AND cr.status = 'Pending'
             ORDER BY cr.id DESC`,
            ['%' + cleanName + '%']
        );
        res.json(rows);
    } catch (err) { next(err); }
}

async function approveCorrection(req, res, next) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const { id } = req.params;
        const { rows: corrRows } = await client.query("SELECT * FROM correction_requests WHERE id = $1", [id]);
        if (corrRows.length === 0) return res.status(404).json({ error: 'Not found' });
        const corr = corrRows[0];

        const fieldMap = {
            'Head Name': 'head', 'Door No': 'door', 'Street': 'street',
            'ABHA ID': 'abha', 'PMJA No': 'pmja', 'PHR No': 'phr', 'Ration Card': 'ration'
        };
        const dbField = fieldMap[corr.field_name];

        if (dbField) {
            await client.query(`UPDATE surveys SET ${dbField} = $1 WHERE id = $2`, [corr.new_value, corr.survey_id]);
        } else if (corr.field_name.startsWith('Member:')) {
             const memberName = corr.field_name.split(': ')[1]?.split(' ->')[0];
             if (memberName) {
                await client.query(`UPDATE family_members SET name = $1 WHERE survey_id = $2 AND name = $3`, [corr.new_value, corr.survey_id, memberName]);
             }
        }
        await client.query("UPDATE correction_requests SET status = 'Applied' WHERE id = $1", [id]);
        await client.query('COMMIT');

        const { rows: members } = await client.query("SELECT mobile FROM family_members WHERE survey_id = $1 LIMIT 1", [corr.survey_id]);
        if (members.length > 0 && members[0].mobile) {
            await sendWhatsApp(members[0].mobile, `Rajapalayam Municipality: Your correction for ${corr.field_name} has been verified and updated.`);
        }
        res.json({ success: true });
    } catch (e) {
        await client.query('ROLLBACK');
        next(e);
    } finally { client.release(); }
}

module.exports = { registerComplaint, getMyComplaints, updateComplaintStatus, submitFeedback, requestCorrection, getSurveyorCorrections, approveCorrection };
