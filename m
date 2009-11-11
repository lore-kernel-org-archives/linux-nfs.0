From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/2] nfs41: fix state manager deadlock in session reset
Date: Wed, 11 Nov 2009 14:51:49 -0500
Message-ID: <89c397150911111151q7458d1e3m84bf0c39710a8537@mail.gmail.com>
References: <1257967214-7068-1-git-send-email-andros@netapp.com>
	 <1257967214-7068-2-git-send-email-andros@netapp.com>
	 <1257967214-7068-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:33034 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758776AbZKKTvo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 14:51:44 -0500
Received: by yxe17 with SMTP id 17so1276611yxe.33
        for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2009 11:51:49 -0800 (PST)
In-Reply-To: <1257967214-7068-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 11, 2009 at 2:20 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> If the session is reset during state recovery, the state manager thre=
ad can
> sleep on the slot_tbl_waitq causing a deadlock.
>
> Add a completion framework to the session. =A0Have the state manager =
thread set
> a new session state (NFS4CLNT_SESSION_DRAINING) and wait for the sess=
ion slot
> table to drain.
>
> Signal the state manager thread in nfs41_sequence_free_slot when the
> NFS4CLNT_SESSION_DRAINING bit is set and the session is drained.
>
> Reported-by: Trond Myklebust <trond@netapp.com>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfs/nfs4_fs.h =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0fs/nfs/nfs4proc.c =A0 =A0 =A0 =A0 | =A0 25 ++++++++++++++++-------=
--
> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 15 +++++++++++++++
> =A0include/linux/nfs_fs_sb.h | =A0 =A01 +
> =A04 files changed, 33 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 6ea07a3..e8604af 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -45,6 +45,7 @@ enum nfs4_client_state {
> =A0 =A0 =A0 =A0NFS4CLNT_RECLAIM_NOGRACE,
> =A0 =A0 =A0 =A0NFS4CLNT_DELEGRETURN,
> =A0 =A0 =A0 =A0NFS4CLNT_SESSION_SETUP,
> + =A0 =A0 =A0 NFS4CLNT_SESSION_DRAINING,
> =A0};
>
> =A0/*
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 44d1c14..ebde948 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -355,6 +355,16 @@ void nfs41_sequence_free_slot(const struct nfs_c=
lient *clp,
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0nfs4_free_slot(tbl, res->sr_slotid);
> =A0 =A0 =A0 =A0res->sr_slotid =3D NFS4_MAX_SLOT_TABLE;
> +
> + =A0 =A0 =A0 /* Signal state manager thread if session is drained */
> + =A0 =A0 =A0 if (test_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state)=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tbl->highest_used_slotid =3D=3D -1)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s COMPLETE: S=
ession Drained\n", __func__);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete(&clp->cl_sessi=
on->complete);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0static void nfs41_sequence_done(struct nfs_client *clp,
> @@ -448,15 +458,11 @@ static int nfs41_setup_sequence(struct nfs4_ses=
sion *session,
>
> =A0 =A0 =A0 =A0spin_lock(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0if (test_bit(NFS4CLNT_SESSION_SETUP, &session->clp->cl=
_state)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tbl->highest_used_slotid !=3D -1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rpc_sleep_on(&tbl->slot=
_tbl_waitq, task, NULL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&tbl->slot_=
tbl_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("<-- %s: Sessio=
n reset: draining\n", __func__);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The slot table is empty; start the r=
eset thread */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Session Reset\n", __func__)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The state manager will wait until =
the slot table is empty.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Schedule the reset thread
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Schedule Session Reset\n", =
__func__);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rpc_sleep_on(&tbl->slot_tbl_waitq, tas=
k, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfs4_schedule_state_manager(session->c=
lp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&tbl->slot_tbl_lock);
> @@ -4583,6 +4589,7 @@ struct nfs4_session *nfs4_alloc_session(struct =
nfs_client *clp)
> =A0 =A0 =A0 =A0 * nfs_client struct
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0clp->cl_cons_state =3D NFS_CS_SESSION_INITING;
> + =A0 =A0 =A0 init_completion(&session->complete);
>
> =A0 =A0 =A0 =A0tbl =3D &session->fc_slot_table;
> =A0 =A0 =A0 =A0spin_lock_init(&tbl->slot_tbl_lock);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 50a1b04..f08abe8 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1162,8 +1162,23 @@ static void nfs4_session_recovery_handle_error=
(struct nfs_client *clp, int err)
>
> =A0static int nfs4_reset_session(struct nfs_client *clp)
> =A0{
> + =A0 =A0 =A0 struct nfs4_session *ses =3D clp->cl_session;
> + =A0 =A0 =A0 struct nfs4_slot_table *tbl =3D &ses->fc_slot_table;
> =A0 =A0 =A0 =A0int status;
>
> + =A0 =A0 =A0 spin_lock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 if (tbl->highest_used_slotid !=3D -1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(NFS4CLNT_SESSION_DRAINING, &clp=
->cl_state);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D wait_for_completion_interrup=
tible(&ses->complete);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(NFS4CLNT_SESSION_DRAINING, &c=
lp->cl_state);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status) /* -ERESTARTSYS */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_COMPLETION(ses->complete);


Looking at my own code - I need to move the INIT_COMPLETION after the
wait_for_completion_interruptible and before the status check so that
it gets called even on -ERESTARTSYS.

I'll wait for other comments before sending a fix.

-->Andy


> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0status =3D nfs4_proc_destroy_session(clp->cl_session);
> =A0 =A0 =A0 =A0if (status && status !=3D -NFS4ERR_BADSESSION &&
> =A0 =A0 =A0 =A0 =A0 =A0status !=3D -NFS4ERR_DEADSESSION) {
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 320569e..34fc6be 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -209,6 +209,7 @@ struct nfs4_session {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sess=
ion_state;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 hash_alg;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ssv_len;
> + =A0 =A0 =A0 struct completion =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete;
>
> =A0 =A0 =A0 =A0/* The fore and back channel */
> =A0 =A0 =A0 =A0struct nfs4_channel_attrs =A0 =A0 =A0 fc_attrs;
> --
> 1.6.0.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
