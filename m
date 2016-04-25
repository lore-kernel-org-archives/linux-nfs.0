Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33001 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbcDYUDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 16:03:46 -0400
Received: by mail-io0-f170.google.com with SMTP id f89so160285177ioi.0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2016 13:03:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141105065719.23e912b1@tlielax.poochiereds.net>
References: <CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com>
	<CAHQdGtRuWdHBPfBzCTmDwsYXtpqNSwpGUdtoUqs3jWAd2unxEQ@mail.gmail.com>
	<CAN-5tyGUxgjpcb2=jnQQOD60ernNzf1YSnTG8B-NXUP5OidEFw@mail.gmail.com>
	<CAHQdGtQ=RBoO1u_7501-G2rbDEGim5Hh2G6zuWyyLVVy8QAQWw@mail.gmail.com>
	<CAHQdGtRo2uw5U1-w9O2U=4C8BwxCECAjjeC9SCdkyEP8FQ94Gw@mail.gmail.com>
	<CAN-5tyGsopFNFjo=LBwYE9n6b7Emv73Rkw0H2wyq2vCjMUOftA@mail.gmail.com>
	<CAHQdGtSQJLe60ja+-ChkHXOu8_UjmOpd4X7QHyhNOj1mPQGWPg@mail.gmail.com>
	<20141105065719.23e912b1@tlielax.poochiereds.net>
Date: Mon, 25 Apr 2016 16:03:45 -0400
Message-ID: <CAN-5tyHttF-aPi6SWcFbDtbfD_RGwe87TYCiLsezqU2BsFFJjw@mail.gmail.com>
Subject: Re: how to properly handle failures during delegation recall process
From: Olga Kornievskaia <aglo@umich.edu>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Thomas Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resurrecting an old thread... To handle ADMIN_REVOKED for DELEGRETURN
when we are processing a CB_RECALL:

On Wed, Nov 5, 2014 at 6:57 AM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> On Mon, 13 Oct 2014 18:24:21 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Mon, Oct 13, 2014 at 6:13 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> > On Mon, Oct 13, 2014 at 5:29 PM, Trond Myklebust
>> > <trond.myklebust@primarydata.com> wrote:
>> >> On Mon, Oct 13, 2014 at 5:12 PM, Trond Myklebust
>> >> <trond.myklebust@primarydata.com> wrote:
>> >>> On Mon, Oct 13, 2014 at 4:23 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >>>> On Mon, Oct 13, 2014 at 3:53 PM, Trond Myklebust
>> >>>> <trond.myklebust@primarydata.com> wrote:
>> >>>>> On Mon, Oct 13, 2014 at 2:51 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> >>>>>> +               }
>> >>>>>> +       }
>> >>>>>>         return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>> >>>>>>  }
>> >>>>>>
>> >>>>>> @@ -5957,6 +5973,10 @@ int nfs4_lock_delegation_recall(struct
>> >>>>>> file_lock *fl, struct nfs4_state *state,
>> >>>>>>         err = nfs4_set_lock_state(state, fl);
>> >>>>>>         if (err != 0)
>> >>>>>>                 return err;
>> >>>>>> +       if (test_bit(NFS_LOCK_LOST, &fl->fl_u.nfs4_fl.owner->ls_flags)) {
>> >>>>>> +               pr_warn_ratelimited("NFS: %s: Lock reclaim failed!\n",
>> >>>>>> __func__);
>> >>>>>> +               return -EIO;
>> >>>>>> +       }
>> >>>>>>         err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
>> >>>>>
>> >>>>> Note that there is a potential race here if the server is playing with
>> >>>>> NFS4ERR_DELEG_REVOKED or NFS4ERR_ADMIN_REVOKED. Since we do not
>> >>>>> present the delegation as part of the LOCK request, we have no way of
>> >>>>> knowing if the delegation is still in effect. I guess we can check the
>> >>>>> return value of DELEGRETURN, but if it returns NFS4ERR_DELEG_REVOKED
>> >>>>> or NFS4ERR_ADMIN_REVOKED, then we still do not know whether or not the
>> >>>>> LOCK is safe.
>> >>>>
>> >>>> I'm not following you. We send LOCK before we send DELEGRETURN? Also,
>> >>>> we normally send in LOCK the open_stateid returned by the open with
>> >>>> cur so do we know that delegation is still in effect.
>> >>>
>> >>> How so? The open stateid doesn't tell you that the delegation is still
>> >>> in effect. If the DELEGRETURN returns NFS4ERR_DELEG_REVOKED, how can
>> >>> you tell if the delegation was revoked before or after the LOCK
>> >>> request was handled?
>> >>
>> >> Actually, let me answer that myself. You can sort of figure things out
>> >> in NFSv4.1 if you look at the SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>> >> flag. If it is set, you should probably distrust the lock stateid that
>> >> you just attempted to recover, since you now know that at least one
>> >> delegation was just revoked.
>> >>
>> >> In that case, we probably also have to do a TEST_STATEID+FREE_STATEID
>> >> on the delegation stateid.
>> >
>> > I think we are mis-communicating here by talking about different
>> > nuances. I agree with you that when an operation is sent there is no
>> > way of knowing if in the mean while the server has decided to revoke
>> > the delegation. However, this is not what I'm confused about regarding
>> > your comment. I'm noticing that in the flow of operations, we send (1)
>> > open with cur, then (2) lock, then (3) delegreturn. So I was confused
>> > about how can we check return of delegreturn, step 3, if we are in
>> > step 2.
>> >
>> > I think the LOCK is safe if the reply to the LOCK is successful.
>>
>> It needs to be concurrent with the delegation as well, otherwise
>> general lock atomicity is broken.
>>
>> > Let me just step back from this to note that your solution to "lost
>> > locks during delegation" is to recognize the open with cure failure
>> > and skip locking and delegreturn. I can work on a patch for that.
>> >
>> > Do you agree that the state recovery should not be initiated in case
>> > we get those errors?
>>
>> State recovery _should_ be initiated so that we do reclaim opens (I
>> don't care about share lock atomicity on Linux). However
>> nfs_delegation_claim_locks() _should_not_ be called.
>>
>> I'll give some more thought as to how we can ensure the missing lock atomicity.
>>
>
>
> (cc'ing Tom here since we may want to consider providing guidance in
>  the spec for this situation)
>
> Ok, I think both of you are right here :). Here's my interpretation:
>
> Olga is correct that the LOCK operation itself is safe since LOCK
> doesn't actually modify the contents of the file. What it's not safe to
> do is to trust that LOCK unless and until the DELEGRETURN is also
> successful.
>
> First, let's clarify the potential race that Trond pointed out:
>
> Suppose we have a delegation and delegated locks. That delegation is
> recalled and we do something like this:
>
> OPEN with DELEGATE_CUR: NFS4_OK
> LOCK:                   NFS4_OK
> LOCK:                   NFS4_OK
> ...(maybe more successful locks here)...
> DELEGRETURN:            NFS4ERR_ADMIN_REVOKED
>
> ...at that point, we're screwed.
>
> The delegation was obviously revoked after we did the OPEN but before
> the DELEGRETURN. None of those LOCK requests can be trusted since
> another client may have opened the file at any point in there, acquired
> any one of those locks and then released it.
>
> For v4.1+ the client can do what Trond suggests. Check for
> SEQ4_STATUS_RECALLABLE_STATE_REVOKED in each LOCK response. If it's set
> then we can do the TEST_STATEID/FREE_STATEID dance. If the TEST_STATEID
> fails, then we must consider the most recently acquired lock lost.
> LOCKU it and give up trying to reclaim the rest of them.
>
> For v4.0, I'm not sure what the client can do other than wait until the
> DELEGRETURN. If that fails with NFS4ERR_ADMIN_REVOKED, then we'll just
> have to try to unwind the whole mess. Send LOCKUs for all of them and
> consider them all to be lost.

Would it then be an acceptable solution to:
-- make deleg_return synchronous so that we wait for the reply to
handle the error
-- if we get an error in reply, don't ignore the error and propogate
it back to the delegation code.
-- then mark all the locks lost for the inode.

I don't have anything to send LOCKUs as wouldn't the application/vfs
take care of that when we fail the IO.

Also another problem is that ADMIN_REVOKED gets mapped into EIO by
nfs4_map_errors() before it gets returned into the delegation code so
the patch will mark locks lost for anything else that was translated
into the EIO.

Here's a patch that I've tried that seems to work:

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5166adc..e559407 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -430,6 +430,25 @@ static int nfs_end_delegation_return(struct inode
*inode, struct nfs_delegation
         goto out;

     err = nfs_do_return_delegation(inode, delegation, issync);
+    if (err == -EIO) {
+        struct file_lock *fl;
+        struct file_lock_context *flctx = inode->i_flctx;
+        struct list_head *list;
+
+        if (flctx == NULL)
+            goto out;
+
+        /* mark all locks lost */
+        list = &flctx->flc_posix;
+        down_write(&nfsi->rwsem);
+        spin_lock(&flctx->flc_lock);
+        list_for_each_entry(fl, list, fl_list) {
+            set_bit(NFS_LOCK_LOST,
+                &fl->fl_u.nfs4_fl.owner->ls_flags);
+        }
+        spin_unlock(&flctx->flc_lock);
+        up_write(&nfsi->rwsem);
+    }
 out:
     return err;
 }
@@ -490,7 +509,7 @@ restart:
             delegation = nfs_start_delegation_return_locked(NFS_I(inode));
             rcu_read_unlock();

-            err = nfs_end_delegation_return(inode, delegation, 0);
+            err = nfs_end_delegation_return(inode, delegation, 1);
             iput(inode);
             nfs_sb_deactive(server->super);
             if (!err)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 327b8c3..297a466 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5309,13 +5309,13 @@ static void nfs4_delegreturn_done(struct
rpc_task *task, void *calldata)
     switch (task->tk_status) {
     case 0:
         renew_lease(data->res.server, data->timestamp);
-    case -NFS4ERR_ADMIN_REVOKED:
-    case -NFS4ERR_DELEG_REVOKED:
     case -NFS4ERR_BAD_STATEID:
     case -NFS4ERR_OLD_STATEID:
     case -NFS4ERR_STALE_STATEID:
     case -NFS4ERR_EXPIRED:
         task->tk_status = 0;
+    case -NFS4ERR_ADMIN_REVOKED:
+    case -NFS4ERR_DELEG_REVOKED:
         if (data->roc)
             pnfs_roc_set_barrier(data->inode, data->roc_barrier);
         break;


>
> Actually, it may be reasonable to just do the same thing for v4.1. The
> client tracks NFS_LOCK_LOST on a per-lockstateid basis, so once you have
> any unreclaimable lock, any I/O done with that stateid is going to fail
> anyway. You might as well just release any locks you do hold at that
> point.
>
> The other question is whether the server ought to have any role to play
> here. In principle it could track whether an open/lock stateid is
> descended from a still outstanding delegation, and revoke those
> stateids if the delegation is revoked. That would probably not be
> trivial to do with the current Linux server implementation, however.
>
> --
> Jeff Layton <jlayton@primarydata.com>
