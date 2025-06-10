const cds = require('@sap/cds');
const { differenceInCalendarDays, parseISO } = require('date-fns');

// module.exports = cds.service.impl(async function () {
module.exports = class LeaveService extends cds.ApplicationService {
  async init() {
    const { Leaves, LeaveBalances, EmployeesList, ManageEmployees } = this.entities;

    await super.init();

    /**
   * Generate IDs for new Books drafts
   */
    this.before('NEW', ManageEmployees.drafts, async (req) => {
      console.log(
        req.data.ID, req.data.empID
      )
      if (req.data.empID) return;
      const { ID: id1 } = await SELECT.one.from(ManageEmployees).columns('max(empID) as ID')
      const { ID: id2 } = await SELECT.one.from(ManageEmployees.drafts).columns('max(empID) as ID')
      req.data.empID = Math.max(id1 || 0, id2 || 0) + 1
      console.log(req.data.empID)
    })

    this.on('applyLeave', 'EmployeesList', async (req) => {
      console.log(req)
      const id = req.params[0];
      console.log('_________ Apply Leave ________')
      console.log(id, req.data)
      const { leaveType, startDate, endDate, reason } = req.data;
      const tx = cds.transaction(req);

      let empDetail = await SELECT.one.from(EmployeesList).where({ ID: id });
      console.log('empDetail:', empDetail);

      let start = parseISO(startDate);
      let end = parseISO(endDate);

      // +1 to include both dates
      let leaveDays = differenceInCalendarDays(end, start) + 1;
      console.log('leaveDays', leaveDays)

      if (leaveDays <= 0) throw new Error(`End Date (${endDate}) cannot be before Start Date (${startDate}). Please select valid dates.`);

      const overlappingLeaves = await SELECT.from(Leaves)
        .where({
          employee_ID: id
        })
        .and(`startDate <=`, endDate)
        .and(`endDate >=`, startDate);

      if (overlappingLeaves.length > 0) {
        throw new Error(`You already have leave applied between ${overlappingLeaves[0].startDate} and ${overlappingLeaves[0].endDate}. Overlapping leaves are not allowed.`);
      }

      switch (leaveType) {
        case 'Sick':
          if (empDetail.sickLeaveAvailable <= 0 || empDetail.sickLeaveAvailable < leaveDays) {
            throw new Error('Not enough Sick Leave');
          } else {
            let sickLeaveApplied, sickLeaveAvailable;
            sickLeaveApplied = empDetail.sickLeaveApplied + leaveDays;
            sickLeaveAvailable = empDetail.sickLeaveAvailable - leaveDays;
            await
              UPDATE(EmployeesList)
                .set({
                  sickLeaveApplied: sickLeaveApplied,
                  sickLeaveAvailable: sickLeaveAvailable
                })
                .where({ ID: id })
          }
          break;
        case 'Casual':
          if (empDetail.casualLeaveAvailable <= 0 || empDetail.casualLeaveAvailable < leaveDays) { throw new Error('Not enough Casual Leave') }
          else {
            let casualLeaveApplied, casualLeaveAvailable;
            casualLeaveApplied = empDetail.casualLeaveApplied + leaveDays;
            casualLeaveAvailable = empDetail.casualLeaveAvailable - leaveDays;
            await
              UPDATE(EmployeesList)
                .set({
                  casualLeaveApplied: casualLeaveApplied,
                  casualLeaveAvailable: casualLeaveAvailable
                })
                .where({ ID: id })
          }
          break;
        case 'Earned':
          if (empDetail.earnedLeaveAvailable <= 0 || empDetail.earnedLeaveAvailable < leaveDays) { throw new Error('Not enough Earned Leave') } else {
            let earnedLeaveApplied, earnedLeaveAvailable;
            earnedLeaveApplied = empDetail.earnedLeaveApplied + leaveDays;
            earnedLeaveAvailable = empDetail.earnedLeaveAvailable - leaveDays;
            await
              UPDATE(EmployeesList)
                .set({
                  earnedLeaveApplied: earnedLeaveApplied,
                  earnedLeaveAvailable: earnedLeaveAvailable
                })
                .where({ ID: id })
          }
          break;
      }

      await
        INSERT.into(Leaves).entries({
          type: leaveType,
          startDate: startDate,
          endDate: endDate,
          days: leaveDays,
          reason: reason,
          appliedDate: new Date(),
          status: "Pending",
          employee_ID: id,
          employee_empID: req.params[0].empID
        });

      req.notify(200, `Leave Request submitted successfully 🤩`)
    });

    this.on('approveLeave', async (req) => {
      // console.log(req)
      const leaveId = req.params[1].ID;
      const empId = req.params[0].ID;
      const comment = req.data.comment;
      const tx = cds.transaction(req);

      const employee = await SELECT.one.from(ManageEmployees).where({ ID: empId });
      console.log('employee', employee);

      const leave = await SELECT.one.from(Leaves).where({ ID: leaveId });
      console.log('leave', leave)

      let leaveAvailable, leaveAvailed, leaveApplied;
      switch (leave.type) {
        case 'Sick':
          leaveApplied = employee.sickLeaveApplied - leave.days;
          leaveAvailed = employee.sickLeaveAvailed + leave.days;
          leaveAvailable = employee.sickLeaveAvailable - leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                sickLeaveApplied: leaveApplied,
                sickLeaveAvailable: leaveAvailable,
                sickLeaveAvailed: leaveAvailed
              })
              .where({ ID: empId })
          break;
        case 'Casual':
          leaveApplied = employee.casualLeaveApplied - leave.days;
          leaveAvailed = employee.casualLeaveAvailed + leave.days;
          leaveAvailable = employee.casualLeaveAvailable - leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                casualLeaveApplied: leaveApplied,
                casualLeaveAvailable: leaveAvailable,
                casualLeaveAvailed: leaveAvailed
              })
              .where({ ID: empId })
          break;
        case 'Earned':
          leaveApplied = employee.earnedLeaveApplied - leave.days;
          leaveAvailed = employee.earnedLeaveAvailed + leave.days;
          leaveAvailable = employee.earnedLeaveAvailable - leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                earnedLeaveApplied: leaveApplied,
                earnedLeaveAvailable: leaveAvailable,
                earnedLeaveAvailed: leaveAvailed
              })
              .where({ ID: empId })
          break;
      }

      await
        UPDATE(Leaves)
          .set({
            status: 'Approved',
            approveRejectEnabled: false,
            criticality: 3,
            approverComment: comment
          })
          .where({ ID: leaveId })
        ;

      req.notify(200, `Leave Request has been Approved ✅`)
    });

    this.on('rejectLeave', async (req) => {
      const leaveId = req.params[1].ID;
      const empId = req.params[0].ID;
      const comment = req.data.comment;

      const employee = await SELECT.one.from(ManageEmployees).where({ ID: empId });
      console.log('employee', employee);

      const leave = await SELECT.one.from(Leaves).where({ ID: leaveId });

      let leaveAvailable, leaveAvailed, leaveApplied;
      switch (leave.type) {
        case 'Sick':
          leaveApplied = employee.sickLeaveApplied - leave.days;
          // leaveAvailed = employee.sickLeaveAvailed;
          leaveAvailable = employee.sickLeaveAvailable + leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                sickLeaveApplied: leaveApplied,
                sickLeaveAvailable: leaveAvailable,
                // sickLeaveAvailed: leaveAvailed
              })
              .where({ ID: empId })
          break;
        case 'Casual':
          leaveApplied = employee.sickLeaveApplied - leave.days;
          leaveAvailable = employee.sickLeaveAvailable + leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                casualLeaveApplied: leaveApplied,
                casualLeaveAvailable: leaveAvailable,
                // casualLeaveAvailed: leaveAvailed
              })
              .where({ ID: empId })
          break;
        case 'Earned':
          leaveApplied = employee.sickLeaveApplied - leave.days;
          leaveAvailable = employee.sickLeaveAvailable + leave.days;
          await
            UPDATE(EmployeesList)
              .set({
                earnedLeaveApplied: leaveApplied,
                earnedLeaveAvailable: leaveAvailable,
              })
              .where({ ID: empId })
          break;
      }

      await
        UPDATE(Leaves)
          .set({
            status: 'Rejected',
            approveRejectEnabled: false,
            criticality: 1,
            approverComment: comment
          })
          .where({ ID: leaveId }
          );

      req.notify(200, `Leave Request has been Rejected ❌`)

      return super.init()
    });
  }
};