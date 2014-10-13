Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37752 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbaJMSv5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 14:51:57 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so11604883igb.8
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 11:51:56 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 Oct 2014 14:51:56 -0400
Message-ID: <CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com>
Subject: how to properly handle failures during delegation recall process
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to hear community's thought about how to properly handle
failures during delegation recall process and/or thoughts about a
proposed fixed listed at the end.

There are two problems seen during the following situation:
A client get a cb_call for a delegation it currently holds. Consider
the case where the client has a delegated lock for this open. Callback
thread will send an open with delegation_cur, followed by a lock
operation, and finally delegreturn.

Problem#1: the client will send a lock operation regardless of whether
or not the open succeeded. This is a new_owner lock and in nfs4xdr.c,
the lock operation will choose to use the open_stateid. However, when
the open failed, the stateid is 0. Thus, we send an erroneous stateid
of 0.

Problem#2: if the open fails with admin_revoked, bad_stateid errors,
it leads to an infinite loop of sending an open with deleg_cur and
getting a bad_stateid error back.

It seems to me that we shouldn't even be trying to recover if we get a
bad_stateid-type of errors on open with deleg_cur because they are
unrecoverable.

Furthermore, I propose that if we get an error in
nfs4_open_delegation_recall() then we mark any delegation locks as
lost and in nfs4_lock_delegation_recall() don't attempt to recover
lost lock.

I have tested to following code as a fix:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5aa55c1..523fae0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1682,6 +1682,22 @@ int nfs4_open_delegation_recall(struct
nfs_open_context *ctx, struct nfs4_state
        nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
        err = nfs4_open_recover(opendata, state);
        nfs4_opendata_put(opendata);
+       switch(err) {
+               case -NFS4ERR_DELEG_REVOKED:
+               case -NFS4ERR_ADMIN_REVOKED:
+               case -NFS4ERR_BAD_STATEID:
+               case -NFS4ERR_OPENMODE: {
+                       struct nfs4_lock_state *lock;
+                       /* go through open locks and mark them lost */
+                       spin_lock(&state->state_lock);
+                       list_for_each_entry(lock, &state->lock_states,
ls_locks) {
+                               if (!test_bit(NFS_LOCK_INITIALIZED,
&lock->ls_flags))
+                                       set_bit(NFS_LOCK_LOST, &lock->ls_flags);
+                       }
+                       spin_unlock(&state->state_lock);
+                       return 0;
+               }
+       }
        return nfs4_handle_delegation_recall_error(server, state, stateid, err);
 }

@@ -5957,6 +5973,10 @@ int nfs4_lock_delegation_recall(struct
file_lock *fl, struct nfs4_state *state,
        err = nfs4_set_lock_state(state, fl);
        if (err != 0)
                return err;
+       if (test_bit(NFS_LOCK_LOST, &fl->fl_u.nfs4_fl.owner->ls_flags)) {
+               pr_warn_ratelimited("NFS: %s: Lock reclaim failed!\n",
__func__);
+               return -EIO;
+       }
        err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
        return nfs4_handle_delegation_recall_error(server, state, stateid, err);
 }
--
1.7.1
