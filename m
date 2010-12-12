From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH_V2 1/1] NFS add session back channel draining
Date: Sun, 12 Dec 2010 15:59:46 -0500
Message-ID: <AANLkTi=9ssPfm+DnV76piakHOzq8+BpPTSfyYGEyAPNJ@mail.gmail.com>
References: <1291691982-2170-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:41645 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab0LLU7s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Dec 2010 15:59:48 -0500
Received: by bwz16 with SMTP id 16so5967507bwz.4
        for <linux-nfs@vger.kernel.org>; Sun, 12 Dec 2010 12:59:47 -0800 (PST)
In-Reply-To: <1291691982-2170-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 6, 2010 at 10:19 PM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Currently session draining only drains the fore channel.
> The back channel processing must also be drained.
>
> Use the back channel highest_slot_used to indicate that a callback is=
 being
> processed by the callback thread. =A0Move the session complete to be =
per channel.
>
> When the session is draininig, wait for any current back channel proc=
essing
> to complete and stop all new back channel processing by returning NFS=
4ERR_DELAY
> to the back channel client.
>
> Drain the back channel, then the fore channel.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfs/callback.h =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0fs/nfs/callback_proc.c =A0 =A0| =A0 =A06 ++++++
> =A0fs/nfs/callback_xdr.c =A0 =A0 | =A0 17 +++++++++++++++++
> =A0fs/nfs/nfs4proc.c =A0 =A0 =A0 =A0 | =A0 26 +++++++++++++++++++----=
---
> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 29 ++++++++++++++++++++++-=
------
> =A0include/linux/nfs_fs_sb.h | =A0 =A02 +-
> =A06 files changed, 66 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 85a7cfd..434233e 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -131,6 +131,7 @@ extern unsigned nfs4_callback_recallslot(struct c=
b_recallslotargs *args,
>
> =A0extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args, s=
truct cb_getattrres *res);
> =A0extern __be32 nfs4_callback_recall(struct cb_recallargs *args, voi=
d *dummy);
> +extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
>
> =A0#ifdef CONFIG_NFS_V4
> =A0extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt=
);
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 2950fca..7a976ef 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -287,6 +287,12 @@ __be32 nfs4_callback_sequence(struct cb_sequence=
args *args,
> =A0 =A0 =A0 =A0if (clp =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> + =A0 =A0 =A0 /* state manager is resetting the session */
> + =A0 =A0 =A0 if (test_bit(NFS4_SESSION_DRAINING, &clp->cl_session->s=
ession_state)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D NFS4ERR_DELAY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_putclient;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0status =3D validate_seqid(&clp->cl_session->bc_slot_ta=
ble, args);
> =A0 =A0 =A0 =A0if (status)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_putclient;
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 05af212..0a5e32d 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -593,6 +593,20 @@ preprocess_nfs41_op(int nop, unsigned int op_nr,=
 struct callback_op **op)
> =A0 =A0 =A0 =A0return htonl(NFS_OK);
> =A0}
>
> +static void nfs4_callback_free_slot(struct nfs4_session *session)


Am I missing something, or was the call to this function omitted?

=46red

> +{
> + =A0 =A0 =A0 struct nfs4_slot_table *tbl =3D &session->bc_slot_table=
;
> +
> + =A0 =A0 =A0 spin_lock(&tbl->slot_tbl_lock);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Let the state manager know callback processing don=
e.
> + =A0 =A0 =A0 =A0* A single slot, so highest used slotid is either 0 =
or -1
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 tbl->highest_used_slotid--;
> + =A0 =A0 =A0 nfs4_check_drain_bc_complete(session);
> + =A0 =A0 =A0 spin_unlock(&tbl->slot_tbl_lock);
> +}
> +
> =A0#else /* CONFIG_NFS_V4_1 */
>
> =A0static __be32
> @@ -601,6 +615,9 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, =
struct callback_op **op)
> =A0 =A0 =A0 =A0return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
> =A0}
>
> +static void nfs4_callback_free_slot(struct nfs4_session *session)
> +{
> +}
> =A0#endif /* CONFIG_NFS_V4_1 */
>
> =A0static __be32
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6a653ff..b48f607 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -355,9 +355,9 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, struc=
t nfs4_slot *free_slot)
> =A0}
>
> =A0/*
> - * Signal state manager thread if session is drained
> + * Signal state manager thread if session fore channel is drained
> =A0*/
> -static void nfs41_check_drain_session_complete(struct nfs4_session *=
ses)
> +static void nfs4_check_drain_fc_complete(struct nfs4_session *ses)
> =A0{
> =A0 =A0 =A0 =A0struct rpc_task *task;
>
> @@ -371,8 +371,20 @@ static void nfs41_check_drain_session_complete(s=
truct nfs4_session *ses)
> =A0 =A0 =A0 =A0if (ses->fc_slot_table.highest_used_slotid !=3D -1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 dprintk("%s COMPLETE: Session Drained\n", __func__);
> - =A0 =A0 =A0 complete(&ses->complete);
> + =A0 =A0 =A0 dprintk("%s COMPLETE: Session Fore Channel Drained\n", =
__func__);
> + =A0 =A0 =A0 complete(&ses->fc_slot_table.complete);
> +}
> +
> +/*
> + * Signal state manager thread if session back channel is drained
> + */
> +void nfs4_check_drain_bc_complete(struct nfs4_session *ses)
> +{
> + =A0 =A0 =A0 if (!test_bit(NFS4_SESSION_DRAINING, &ses->session_stat=
e) ||
> + =A0 =A0 =A0 =A0 =A0 ses->bc_slot_table.highest_used_slotid !=3D -1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 dprintk("%s COMPLETE: Session Back Channel Drained\n", =
__func__);
> + =A0 =A0 =A0 complete(&ses->bc_slot_table.complete);
> =A0}
>
> =A0static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res=
)
> @@ -389,7 +401,7 @@ static void nfs41_sequence_free_slot(struct nfs4_=
sequence_res *res)
>
> =A0 =A0 =A0 =A0spin_lock(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0nfs4_free_slot(tbl, res->sr_slot);
> - =A0 =A0 =A0 nfs41_check_drain_session_complete(res->sr_session);
> + =A0 =A0 =A0 nfs4_check_drain_fc_complete(res->sr_session);
> =A0 =A0 =A0 =A0spin_unlock(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0res->sr_slot =3D NULL;
> =A0}
> @@ -4767,17 +4779,17 @@ struct nfs4_session *nfs4_alloc_session(struc=
t nfs_client *clp)
> =A0 =A0 =A0 =A0if (!session)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> - =A0 =A0 =A0 init_completion(&session->complete);
> -
> =A0 =A0 =A0 =A0tbl =3D &session->fc_slot_table;
> =A0 =A0 =A0 =A0tbl->highest_used_slotid =3D -1;
> =A0 =A0 =A0 =A0spin_lock_init(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "Fo=
reChannel Slot table");
> + =A0 =A0 =A0 init_completion(&tbl->complete);
>
> =A0 =A0 =A0 =A0tbl =3D &session->bc_slot_table;
> =A0 =A0 =A0 =A0tbl->highest_used_slotid =3D -1;
> =A0 =A0 =A0 =A0spin_lock_init(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel=
 Slot table");
> + =A0 =A0 =A0 init_completion(&tbl->complete);
>
> =A0 =A0 =A0 =A0session->session_state =3D 1<<NFS4_SESSION_INITING;
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index f575a31..0082483 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -142,6 +142,11 @@ static int nfs41_setup_state_renewal(struct nfs_=
client *clp)
> =A0 =A0 =A0 =A0return status;
> =A0}
>
> +/*
> + * Back channel returns NFS4ERR_DELAY for new requests when
> + * NFS4_SESSION_DRAINING is set so there is no work to be done when =
draining
> + * is ended.
> + */
> =A0static void nfs4_end_drain_session(struct nfs_client *clp)
> =A0{
> =A0 =A0 =A0 =A0struct nfs4_session *ses =3D clp->cl_session;
> @@ -165,21 +170,31 @@ static void nfs4_end_drain_session(struct nfs_c=
lient *clp)
> =A0 =A0 =A0 =A0}
> =A0}
>
> -static int nfs4_begin_drain_session(struct nfs_client *clp)
> +static int nfs4_wait_on_slot_tbl(struct nfs4_slot_table *tbl)
> =A0{
> - =A0 =A0 =A0 struct nfs4_session *ses =3D clp->cl_session;
> - =A0 =A0 =A0 struct nfs4_slot_table *tbl =3D &ses->fc_slot_table;
> -
> =A0 =A0 =A0 =A0spin_lock(&tbl->slot_tbl_lock);
> - =A0 =A0 =A0 set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
> =A0 =A0 =A0 =A0if (tbl->highest_used_slotid !=3D -1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_COMPLETION(ses->complete);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_COMPLETION(tbl->complete);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&tbl->slot_tbl_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return wait_for_completion_interruptibl=
e(&ses->complete);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return wait_for_completion_interruptibl=
e(&tbl->complete);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0spin_unlock(&tbl->slot_tbl_lock);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> +
> +static int nfs4_begin_drain_session(struct nfs_client *clp)
> +{
> + =A0 =A0 =A0 struct nfs4_session *ses =3D clp->cl_session;
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 set_bit(NFS4_SESSION_DRAINING, &ses->session_state);
> + =A0 =A0 =A0 /* back channel */
> + =A0 =A0 =A0 ret =3D nfs4_wait_on_slot_tbl(&ses->bc_slot_table);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 /* fore channel */
> + =A0 =A0 =A0 return nfs4_wait_on_slot_tbl(&ses->fc_slot_table);
> +}
>
> =A0int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *c=
red)
> =A0{
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 452d964..8ded472 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -196,6 +196,7 @@ struct nfs4_slot_table {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 * op for dynamic resizing */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 target_max_slots; =A0 =A0 =
=A0 /* Set by CB_RECALL_SLOT as
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 * the new max_slots */
> + =A0 =A0 =A0 struct completion complete;
> =A0};
>
> =A0static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs=
4_slot *sp)
> @@ -212,7 +213,6 @@ struct nfs4_session {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sess=
ion_state;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 hash_alg;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ssv_len;
> - =A0 =A0 =A0 struct completion =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete;
>
> =A0 =A0 =A0 =A0/* The fore and back channel */
> =A0 =A0 =A0 =A0struct nfs4_channel_attrs =A0 =A0 =A0 fc_attrs;
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
