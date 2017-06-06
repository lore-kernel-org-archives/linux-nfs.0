Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35306 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdFFQjR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jun 2017 12:39:17 -0400
Received: by mail-qt0-f173.google.com with SMTP id w1so136365192qtg.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jun 2017 09:39:17 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 6 Jun 2017 12:39:15 -0400
Message-ID: <CAN-5tyHTmx7KM76DRa5F5PwgJpNsZELf8BBHeoBq-yacHfzpmg@mail.gmail.com>
Subject: race in state manager leads to failed recovery
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An application can fail with EIO when the server reboots and the
client while doing the recovery is getting into the following
situation where it incorrectly chooses "nograce" recovery instead of
"reboot" recovery. The necessary trigger is a pnfs mount and 2 DS
reads on the same file fail with BAD_STATEID each read uses its own
lock stateid (and MDS server reboots losing state). Since  server
rebooted it will fail recovery ops with BAD_SESSION and then also
STALE_ID triggering session and clientid recovery.

1. Thread1 gets BAD_STATEID initiates stateid recovery calls
nfs4_state_mark_reclaim_no_grace() which sets the cl_state->flags and
state->flags respective _NOGRACE flags.

2. State manager gets to run and it clears the _NOGRACE from the
cl_state. Calls nfs4_do_reclaim() which sends TEST_STATEID which gets
a BAD_SESSION.

3. Thread2 now gets control and it also processing its BAD_STATEID and
calls nfs4_state_mark_reclaim_no_grace() and it again sets the
state/cl_state->flags to have _NOGRACE.

4. State manager runs and continues with state recovery by sending
DESTROY_SESSION, and then CREATE_SESSION which fails with
STALE_CLIENTID. Now we are recovering the lease.

5. State manager in nfs4_recovery_handle_error for STALE_CLIENTID,
calls nfs4_state_start_reclaim_reboot() calls
nfs4_state_mark_reclaim_reboot() which has a check

/* Don't recover state that expired before the reboot */
if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
  clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
  return 0;
}

Because the _NOGRACE was set again in Step3, we end up clearing
_RECLAIM_REBOOT and not setting _RECLAIM_REBOOT in the cl_state->flags
and choose to do "nograce" operation instead of recovery.

Removing this check removes the problem.

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 06274e3..2c668a0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1321,11 +1321,6 @@ static int
nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
  if (!nfs4_valid_open_stateid(state))
  return 0;
  set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
- /* Don't recover state that expired before the reboot */
- if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
- clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
- return 0;
- }
  set_bit(NFS_OWNER_RECLAIM_REBOOT, &state->owner->so_flags);
  set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
  return 1;

I'm confused by the comment why would we not what to recover state?

When both threads execute before the state manager starts this problem
doesn't exist.

If helpful here are two annotated (**) snippet from var log message
from the non-working and then one without the check:

Jun  6 12:06:42 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff880072f50=
c00
   ** first thread sets the nograce recovery
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
cleared NOGRACE from client state ffff88006fc23d28
  ** this is from the state manager=E2=80=99s loop from after
test_and_clear(NFS4CLNT_RECLAIM_NO_GRACE, cl_state)
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_do_reclaim start
Jun  6 12:06:42 ipa18 kernel: NFS call  test_stateid ffff880077ac0af0
Jun  6 12:06:42 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff880072f50=
c00
   ** 2nd thread sets the nograce recovery
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_do_reclaim status end=3D-11
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_state_mark_reclaim_reboot
clears RECLAIM_REBOOT from state=3Dffff880072f50c00
   ** this is from nfs4_state_mark_reclaim_reboot() and ends up not
setting the _RECLAIM_REBOOT flag in cl_state and clears it from the
state->flags
Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_reclaim_lease client
state=3Dffff88006fc23d28 flag has NOGRACE
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
cleared NOGRACE from client state ffff88006fc23d28
   ** this is in the state manager loop after the "reclaim_nograce" is
chosen and clearing the _NOGRACE flag
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_do_reclaim start
Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880077ac0af0
Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880077ac02f0
Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880072f50c68
Jun  6 12:06:43 ipa18 kernel: NFS: nfs4_reclaim_open_state: Lock reclaim fa=
iled!
Jun  6 12:06:43 ipa18 kernel: NFS: nfs4_reclaim_open_state: Lock reclaim fa=
iled!
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_reclaim_open_state clearing
NOGRACE from state=3Dffff880072f50c00
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_end_drain_session

This is a snippet from when we ignore that _NOGRACE is set and proceed
to set the _RECLAIM_REBOOT
Jun  6 12:21:58 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff88007363b=
bc0
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
cleared NOGRACE from client state ffff88002febe528
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_do_reclaim start
Jun  6 12:21:58 ipa18 kernel: NFS call  test_stateid ffff880077ac4cf0
Jun  6 12:21:58 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff88007363b=
bc0
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_do_reclaim status end=3D-11
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_state_mark_reclaim_reboot NOT
clearing _RECLAIM_REBOOT from state=3Dffff88007363bbc0
    *** Removing the check and instead proceeding to set the
_RECLAIM_REBOOT in the cl_state->flags so that
Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_begin_drain_session
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_reclaim_lease client
state=3Dffff88002febe528 flag has NOGRACE
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_state_manager reclaim reboot
op cl_state=3Dffff88002febe528
   *** Unlike the previous case the state manager now goes into the
reclaim reboot state.
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim start
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_reclaim_open_state clearing
NOGRACE from state=3Dffff88007363bbc0
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
cleared NOGRACE from client state ffff88002febe528
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim start
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_end_drain_session
