From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 2/2] nfs41: fix state manager deadlock in session
 reset
Date: Thu, 12 Nov 2009 15:29:57 +0200
Message-ID: <4AFC0DD5.7030707@panasas.com>
References: <1257967214-7068-1-git-send-email-andros@netapp.com>	<1257967214-7068-2-git-send-email-andros@netapp.com>	<1257967214-7068-3-git-send-email-andros@netapp.com> <89c397150911111151q7458d1e3m84bf0c39710a8537@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, Andy Adamson <andros@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22700 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751503AbZKLN3y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2009 08:29:54 -0500
In-Reply-To: <89c397150911111151q7458d1e3m84bf0c39710a8537-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 11, 2009, 21:51 +0200, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Wed, Nov 11, 2009 at 2:20 PM,  <andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> If the session is reset during state recovery, the state manager thread can
>> sleep on the slot_tbl_waitq causing a deadlock.
>>
>> Add a completion framework to the session.  Have the state manager thread set
>> a new session state (NFS4CLNT_SESSION_DRAINING) and wait for the session slot
>> table to drain.
>>
>> Signal the state manager thread in nfs41_sequence_free_slot when the
>> NFS4CLNT_SESSION_DRAINING bit is set and the session is drained.
>>
>> Reported-by: Trond Myklebust <trond@netapp.com>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/nfs4_fs.h          |    1 +
>>  fs/nfs/nfs4proc.c         |   25 ++++++++++++++++---------
>>  fs/nfs/nfs4state.c        |   15 +++++++++++++++
>>  include/linux/nfs_fs_sb.h |    1 +
>>  4 files changed, 33 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index 6ea07a3..e8604af 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -45,6 +45,7 @@ enum nfs4_client_state {
>>        NFS4CLNT_RECLAIM_NOGRACE,
>>        NFS4CLNT_DELEGRETURN,
>>        NFS4CLNT_SESSION_SETUP,
>> +       NFS4CLNT_SESSION_DRAINING,
>>  };
>>
>>  /*
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 44d1c14..ebde948 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -355,6 +355,16 @@ void nfs41_sequence_free_slot(const struct nfs_client *clp,
>>        }
>>        nfs4_free_slot(tbl, res->sr_slotid);
>>        res->sr_slotid = NFS4_MAX_SLOT_TABLE;
>> +
>> +       /* Signal state manager thread if session is drained */
>> +       if (test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
>> +               spin_lock(&tbl->slot_tbl_lock);
>> +               if (tbl->highest_used_slotid == -1) {
>> +                       dprintk("%s COMPLETE: Session Drained\n", __func__);
>> +                       complete(&clp->cl_session->complete);
>> +               }
>> +               spin_unlock(&tbl->slot_tbl_lock);
>> +       }
>>  }
>>
>>  static void nfs41_sequence_done(struct nfs_client *clp,
>> @@ -448,15 +458,11 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
>>
>>        spin_lock(&tbl->slot_tbl_lock);
>>        if (test_bit(NFS4CLNT_SESSION_SETUP, &session->clp->cl_state)) {
>> -               if (tbl->highest_used_slotid != -1) {
>> -                       rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
>> -                       spin_unlock(&tbl->slot_tbl_lock);
>> -                       dprintk("<-- %s: Session reset: draining\n", __func__);
>> -                       return -EAGAIN;
>> -               }
>> -
>> -               /* The slot table is empty; start the reset thread */
>> -               dprintk("%s Session Reset\n", __func__);
>> +               /*
>> +                * The state manager will wait until the slot table is empty.
>> +                * Schedule the reset thread
>> +                */
>> +               dprintk("%s Schedule Session Reset\n", __func__);
>>                rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
>>                nfs4_schedule_state_manager(session->clp);
>>                spin_unlock(&tbl->slot_tbl_lock);
>> @@ -4583,6 +4589,7 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
>>         * nfs_client struct
>>         */
>>        clp->cl_cons_state = NFS_CS_SESSION_INITING;
>> +       init_completion(&session->complete);
>>
>>        tbl = &session->fc_slot_table;
>>        spin_lock_init(&tbl->slot_tbl_lock);
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 50a1b04..f08abe8 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1162,8 +1162,23 @@ static void nfs4_session_recovery_handle_error(struct nfs_client *clp, int err)
>>
>>  static int nfs4_reset_session(struct nfs_client *clp)
>>  {
>> +       struct nfs4_session *ses = clp->cl_session;
>> +       struct nfs4_slot_table *tbl = &ses->fc_slot_table;
>>        int status;
>>
>> +       spin_lock(&tbl->slot_tbl_lock);
>> +       if (tbl->highest_used_slotid != -1) {
>> +               set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
>> +               spin_unlock(&tbl->slot_tbl_lock);
>> +               status = wait_for_completion_interruptible(&ses->complete);
>> +               clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
>> +               if (status) /* -ERESTARTSYS */
>> +                       goto out;
>> +               INIT_COMPLETION(ses->complete);
> 
> 
> Looking at my own code - I need to move the INIT_COMPLETION after the
> wait_for_completion_interruptible and before the status check so that
> it gets called even on -ERESTARTSYS.

Might there be a race with nfs41_sequence_free_slot?
Can't you just call INIT_COMPLETION under the slot_tbl_lock
before calling wait_for_completion_interruptible?

I.e, in nfs41_sequence_free_slot:
 	}
 	nfs4_free_slot(tbl, res->sr_slotid);
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+
+	/* Signal state manager thread if session is drained */
+	if (test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
+		spin_lock(&tbl->slot_tbl_lock);
+		if (tbl->highest_used_slotid == -1 &&
+		    test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)) {
+			dprintk("%s COMPLETE: Session Drained\n", __func__);
+			complete(&clp->cl_session->complete);
+		}
+		spin_unlock(&tbl->slot_tbl_lock);
+	}
 }

and here:

 static int nfs4_reset_session(struct nfs_client *clp)
 {
+	struct nfs4_session *ses = clp->cl_session;
+	struct nfs4_slot_table *tbl = &ses->fc_slot_table;
 	int status;
 
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->highest_used_slotid != -1) {
+		set_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
+		INIT_COMPLETION(ses->complete);
+		spin_unlock(&tbl->slot_tbl_lock);
+		status = wait_for_completion_interruptible(&ses->complete);
+		clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
+		if (status) /* -ERESTARTSYS */
+			goto out;

Benny

> 
> I'll wait for other comments before sending a fix.
> 
> -->Andy
> 
> 
>> +       } else {
>> +               spin_unlock(&tbl->slot_tbl_lock);
>> +       }
>> +
>>        status = nfs4_proc_destroy_session(clp->cl_session);
>>        if (status && status != -NFS4ERR_BADSESSION &&
>>            status != -NFS4ERR_DEADSESSION) {
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index 320569e..34fc6be 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -209,6 +209,7 @@ struct nfs4_session {
>>        unsigned long                   session_state;
>>        u32                             hash_alg;
>>        u32                             ssv_len;
>> +       struct completion               complete;
>>
>>        /* The fore and back channel */
>>        struct nfs4_channel_attrs       fc_attrs;
>> --
>> 1.6.0.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
