Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34367 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdFHTrv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 15:47:51 -0400
Received: by mail-qk0-f172.google.com with SMTP id d14so9467285qkb.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jun 2017 12:47:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHTmx7KM76DRa5F5PwgJpNsZELf8BBHeoBq-yacHfzpmg@mail.gmail.com>
References: <CAN-5tyHTmx7KM76DRa5F5PwgJpNsZELf8BBHeoBq-yacHfzpmg@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 8 Jun 2017 15:47:49 -0400
Message-ID: <CAN-5tyGNNmEiTcf2vs6yKt-q9Q_wh7Suym1PemJO0wqP=t_+vw@mail.gmail.com>
Subject: Re: race in state manager leads to failed recovery
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, any thoughts on this?

Another idea I had and tested to be effective was to introduce a new
state bit "NFS_STATE_RECLAIM_INPROGRESS". If it's set then the new
calls to nfs4_state_mark_reclaim_nograce() are just ignored.

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc..0f20f12 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -158,6 +158,7 @@ enum {
  NFS_O_RDWR_STATE, /* OPEN stateid has read/write state */
  NFS_STATE_RECLAIM_REBOOT, /* OPEN stateid server rebooted */
  NFS_STATE_RECLAIM_NOGRACE, /* OPEN stateid needs to recover state */
+ NFS_STATE_RECLAIM_INPROGRESS, /* OPEN stateid recovery is in progress */
  NFS_STATE_POSIX_LOCKS, /* Posix locks are supported */
  NFS_STATE_RECOVERY_FAILED, /* OPEN stateid state recovery failed */
  NFS_STATE_MAY_NOTIFY_LOCK, /* server may CB_NOTIFY_LOCK */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b34de03..4eef2eb 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1335,6 +1335,8 @@ int nfs4_state_mark_reclaim_nograce(struct
nfs_client *clp, struct nfs4_state *s
 {
  if (!nfs4_valid_open_stateid(state))
  return 0;
+ if (test_bit(NFS_STATE_RECLAIM_INPROGRESS, &state->flags))
+ return 1;
  set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
  clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
  set_bit(NFS_OWNER_RECLAIM_NOGRACE, &state->owner->so_flags);
@@ -1522,6 +1524,7 @@ static int nfs4_reclaim_open_state(struct
nfs4_state_owner *sp, const struct nfs
  continue;
  atomic_inc(&state->count);
  spin_unlock(&sp->so_lock);
+ set_bit(NFS_STATE_RECLAIM_INPROGRESS, &state->flags);
  status =3D ops->recover_open(sp, state);
  if (status >=3D 0) {
  status =3D nfs4_reclaim_locks(state, ops);
@@ -1538,6 +1541,8 @@ static int nfs4_reclaim_open_state(struct
nfs4_state_owner *sp, const struct nfs
  }
  clear_bit(NFS_STATE_RECLAIM_NOGRACE,
  &state->flags);
+ clear_bit(NFS_STATE_RECLAIM_INPROGRESS,
+ &state->flags);
  nfs4_put_open_state(state);
  spin_lock(&sp->so_lock);
  goto restart;

On Tue, Jun 6, 2017 at 12:39 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> An application can fail with EIO when the server reboots and the
> client while doing the recovery is getting into the following
> situation where it incorrectly chooses "nograce" recovery instead of
> "reboot" recovery. The necessary trigger is a pnfs mount and 2 DS
> reads on the same file fail with BAD_STATEID each read uses its own
> lock stateid (and MDS server reboots losing state). Since  server
> rebooted it will fail recovery ops with BAD_SESSION and then also
> STALE_ID triggering session and clientid recovery.
>
> 1. Thread1 gets BAD_STATEID initiates stateid recovery calls
> nfs4_state_mark_reclaim_no_grace() which sets the cl_state->flags and
> state->flags respective _NOGRACE flags.
>
> 2. State manager gets to run and it clears the _NOGRACE from the
> cl_state. Calls nfs4_do_reclaim() which sends TEST_STATEID which gets
> a BAD_SESSION.
>
> 3. Thread2 now gets control and it also processing its BAD_STATEID and
> calls nfs4_state_mark_reclaim_no_grace() and it again sets the
> state/cl_state->flags to have _NOGRACE.
>
> 4. State manager runs and continues with state recovery by sending
> DESTROY_SESSION, and then CREATE_SESSION which fails with
> STALE_CLIENTID. Now we are recovering the lease.
>
> 5. State manager in nfs4_recovery_handle_error for STALE_CLIENTID,
> calls nfs4_state_start_reclaim_reboot() calls
> nfs4_state_mark_reclaim_reboot() which has a check
>
> /* Don't recover state that expired before the reboot */
> if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
>   clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
>   return 0;
> }
>
> Because the _NOGRACE was set again in Step3, we end up clearing
> _RECLAIM_REBOOT and not setting _RECLAIM_REBOOT in the cl_state->flags
> and choose to do "nograce" operation instead of recovery.
>
> Removing this check removes the problem.
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 06274e3..2c668a0 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1321,11 +1321,6 @@ static int
> nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
>   if (!nfs4_valid_open_stateid(state))
>   return 0;
>   set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
> - /* Don't recover state that expired before the reboot */
> - if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags)) {
> - clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
> - return 0;
> - }
>   set_bit(NFS_OWNER_RECLAIM_REBOOT, &state->owner->so_flags);
>   set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
>   return 1;
>
> I'm confused by the comment why would we not what to recover state?
>
> When both threads execute before the state manager starts this problem
> doesn't exist.
>
> If helpful here are two annotated (**) snippet from var log message
> from the non-working and then one without the check:
>
> Jun  6 12:06:42 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff880072f=
50c00
>    ** first thread sets the nograce recovery
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
> cleared NOGRACE from client state ffff88006fc23d28
>   ** this is from the state manager=E2=80=99s loop from after
> test_and_clear(NFS4CLNT_RECLAIM_NO_GRACE, cl_state)
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_do_reclaim start
> Jun  6 12:06:42 ipa18 kernel: NFS call  test_stateid ffff880077ac0af0
> Jun  6 12:06:42 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff880072f=
50c00
>    ** 2nd thread sets the nograce recovery
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_do_reclaim status end=3D-11
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_state_mark_reclaim_reboot
> clears RECLAIM_REBOOT from state=3Dffff880072f50c00
>    ** this is from nfs4_state_mark_reclaim_reboot() and ends up not
> setting the _RECLAIM_REBOOT flag in cl_state and clears it from the
> state->flags
> Jun  6 12:06:42 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_reclaim_lease client
> state=3Dffff88006fc23d28 flag has NOGRACE
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
> cleared NOGRACE from client state ffff88006fc23d28
>    ** this is in the state manager loop after the "reclaim_nograce" is
> chosen and clearing the _NOGRACE flag
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_do_reclaim start
> Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880077ac0af0
> Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880077ac02f0
> Jun  6 12:06:43 ipa18 kernel: NFS call  test_stateid ffff880072f50c68
> Jun  6 12:06:43 ipa18 kernel: NFS: nfs4_reclaim_open_state: Lock reclaim =
failed!
> Jun  6 12:06:43 ipa18 kernel: NFS: nfs4_reclaim_open_state: Lock reclaim =
failed!
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_reclaim_open_state clearing
> NOGRACE from state=3Dffff880072f50c00
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
> Jun  6 12:06:43 ipa18 kernel: AGLO: nfs4_end_drain_session
>
> This is a snippet from when we ignore that _NOGRACE is set and proceed
> to set the _RECLAIM_REBOOT
> Jun  6 12:21:58 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff8800736=
3bbc0
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
> cleared NOGRACE from client state ffff88002febe528
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_do_reclaim start
> Jun  6 12:21:58 ipa18 kernel: NFS call  test_stateid ffff880077ac4cf0
> Jun  6 12:21:58 ipa18 kernel: nfs4_state_mark_reclaim_nograce ffff8800736=
3bbc0
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_do_reclaim status end=3D-11
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_state_mark_reclaim_reboot NOT
> clearing _RECLAIM_REBOOT from state=3Dffff88007363bbc0
>     *** Removing the check and instead proceeding to set the
> _RECLAIM_REBOOT in the cl_state->flags so that
> Jun  6 12:21:58 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_begin_drain_session
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_reclaim_lease client
> state=3Dffff88002febe528 flag has NOGRACE
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_state_manager reclaim reboot
> op cl_state=3Dffff88002febe528
>    *** Unlike the previous case the state manager now goes into the
> reclaim reboot state.
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim start
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_reclaim_open_state clearing
> NOGRACE from state=3Dffff88007363bbc0
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_state_manager reclaim_nograce
> cleared NOGRACE from client state ffff88002febe528
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim start
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_do_reclaim end=3D0
> Jun  6 12:21:59 ipa18 kernel: AGLO: nfs4_end_drain_session
