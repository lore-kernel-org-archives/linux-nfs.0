From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
	rpc_cred
Date: Fri, 21 May 2010 08:47:44 -0400
Message-ID: <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN@mail.gmail.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>
	 <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.211.180]:58714 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab0EUMrp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 May 2010 08:47:45 -0400
Received: by ywh10 with SMTP id 10so528880ywh.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 May 2010 05:47:44 -0700 (PDT)
In-Reply-To: <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 20, 2010 at 10:50 PM, Tao Guo <glorioustao@gmail.com> wrote=
:
> On Fri, May 21, 2010 at 12:04 AM, =A0<andros@netapp.com> wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Taking a reference on the nfs_open_context to signal that a layoutco=
mmit is
>> needed is problematic because the last reference to the context trig=
gers a
>> close (nfs_release). =A0But, if the layout holds a reference on the
>> nfs_open_context, then close will not be triggered.
>>
>> Since we only use the rpc credential from the layoutcommit_ctx, repl=
ace the
>> layoutcommit_ctx with the rpc_cred.
>>
>> Hold a reference on the rpc_cred until the layoutcommit rpc returns.=
 Note that
>> the rpc layer (rpcauth_bind) also references the rpc_cred.
>>
>> If the layoutdriver fails to setup the layoutcommit, clear the layou=
tcommit
>> properties and put the credential.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/inode.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 42 +++++++++++++++++-=
------------------------
>> =A0fs/nfs/write.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A0include/linux/nfs4_pnfs.h | =A0 =A06 ++++++
>> =A0include/linux/nfs_fs.h =A0 =A0| =A0 =A03 +--
>> =A0include/linux/pnfs_xdr.h =A0| =A0 =A01 -
>> =A07 files changed, 28 insertions(+), 32 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 7fd33d9..2b8e8e6 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1110,7 +1110,7 @@ static int nfs_update_inode(struct inode *inod=
e, struct nfs_fattr *fattr)
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * file needs layout commit, server attributes may be=
 stale
>> =A0 =A0 =A0 =A0 */
>> - =A0 =A0 =A0 if (nfsi->layoutcommit_ctx && nfsi->change_attr >=3D f=
attr->change_attr) {
>> + =A0 =A0 =A0 if (do_layoutcommit(nfsi) && nfsi->change_attr >=3D fa=
ttr->change_attr) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("NFS: %s: layoutcommit is nee=
ded for file %s/%ld\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, inode->i_sb=
->s_id, inode->i_ino);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>> @@ -1331,7 +1331,7 @@ static void pnfs_alloc_init_inode(struct nfs_i=
node *nfsi)
>> =A0 =A0 =A0 =A0nfsi->pnfs_layout_state =3D 0;
>> =A0 =A0 =A0 =A0memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
>> =A0 =A0 =A0 =A0nfsi->layout.roc_iomode =3D 0;
>> - =A0 =A0 =A0 nfsi->layoutcommit_ctx =3D NULL;
>> + =A0 =A0 =A0 nfsi->lo_cred =3D NULL;
>> =A0 =A0 =A0 =A0nfsi->pnfs_write_begin_pos =3D 0;
>> =A0 =A0 =A0 =A0nfsi->pnfs_write_end_pos =3D 0;
>> =A0#endif /* CONFIG_NFS_V4_1 */
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index d145de1..bf03fde 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -589,7 +589,7 @@ static void __nfs4_close(struct path *path, stru=
ct nfs4_state *state, fmode_t fm
>> =A0#ifdef CONFIG_NFS_V4_1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D NFS_I(stat=
e->inode);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nfsi->layoutcommit_ctx)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (do_layoutcommit(nfsi))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_layoutcommit_ino=
de(state->inode, wait);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (has_layout(nfsi) && nfsi->layout.=
roc_iomode) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs4_pnfs_layo=
ut_segment range;
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 20285bc..cb8ff06 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -145,21 +145,19 @@ find_pnfs(u32 id, struct pnfs_module **module)=
 {
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>>
>> -/* Set context to indicate we require a layoutcommit
>> +/* Set lo_cred to indicate we require a layoutcommit
>> =A0* If we don't even have a layout, we don't need to commit it.
>> =A0*/
>> =A0void
>> =A0pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_co=
ntext *ctx)
>> =A0{
>> - =A0 =A0 =A0 dprintk("%s: has_layout=3D%d layoutcommit_ctx=3D%p ctx=
=3D%p\n", __func__,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 has_layout(nfsi), nfsi->layoutcommit_c=
tx, ctx);
>> + =A0 =A0 =A0 dprintk("%s: has_layout=3D%d ctx=3D%p\n", __func__, ha=
s_layout(nfsi), ctx);
>> =A0 =A0 =A0 =A0spin_lock(&nfsi->lo_lock);
>> - =A0 =A0 =A0 if (has_layout(nfsi) && !nfsi->layoutcommit_ctx) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layoutcommit_ctx =3D get_nfs_ope=
n_context(ctx);
>> + =A0 =A0 =A0 if (has_layout(nfsi) && !do_layoutcommit(nfsi)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsi->lo_cred =3D get_rpccred(ctx->sta=
te->owner->so_cred);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->change_attr++;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&nfsi->lo_lock);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: Set layoutcommit_ctx=3D%p=
\n", __func__,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfsi->layoutcommit_ctx=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: Set layoutcommit\n", __fu=
nc__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0spin_unlock(&nfsi->lo_lock);
>> @@ -755,7 +753,7 @@ _pnfs_return_layout(struct inode *ino, struct nf=
s4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!pnfs=
_return_layout_barrier(nfsi, &arg));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nfsi->layoutcommit_ctx) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (do_layoutcommit(nfsi)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D pnfs_layou=
tcommit_inode(ino, wait);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (status) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprin=
tk("%s: layoutcommit failed, status=3D%d. "
>> @@ -1910,16 +1908,9 @@ pnfs_layoutcommit_done(struct pnfs_layoutcomm=
it_data *data)
>>
>> =A0 =A0 =A0 =A0dprintk("%s: (status %d)\n", __func__, data->status);
>>
>> - =A0 =A0 =A0 /* TODO: For now, set an error in the open context (ju=
st like
>> - =A0 =A0 =A0 =A0* if a commit failed) We may want to do more, much =
more, like
>> - =A0 =A0 =A0 =A0* replay all writes through the NFSv4
>> - =A0 =A0 =A0 =A0* server, or something.
>> - =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 if (data->status < 0) {
>> + =A0 =A0 =A0 if (data->status < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "%s, Layoutcommit Fai=
led! =3D %d\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, data->status);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->ctx->error =3D data->status;
>> - =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0/* TODO: Maybe we should avoid this by allowing the l=
ayout driver
>> =A0 =A0 =A0 =A0 * to directly xdr its layout on the wire.
>> @@ -1929,9 +1920,6 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommi=
t_data *data)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi->layout,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&data->args,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->status);
>> -
>> - =A0 =A0 =A0 /* release the open_context acquired in pnfs_writeback=
_done */
>> - =A0 =A0 =A0 put_nfs_open_context(data->ctx);
>> =A0}
>>
>> =A0/*
>> @@ -1995,30 +1983,34 @@ pnfs_layoutcommit_inode(struct inode *inode,=
 int sync)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>>
>> =A0 =A0 =A0 =A0spin_lock(&nfsi->lo_lock);
>> - =A0 =A0 =A0 if (!nfsi->layoutcommit_ctx)
>> + =A0 =A0 =A0 if (!do_layoutcommit(nfsi))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unlock;
>>
>> =A0 =A0 =A0 =A0data->args.inode =3D inode;
>> - =A0 =A0 =A0 data->cred =A0=3D nfsi->layoutcommit_ctx->cred;
>> - =A0 =A0 =A0 data->ctx =3D nfsi->layoutcommit_ctx;
>> + =A0 =A0 =A0 data->cred =3D nfsi->lo_cred;
>>
>> =A0 =A0 =A0 =A0/* Set up layout commit args*/
>> =A0 =A0 =A0 =A0status =3D pnfs_layoutcommit_setup(data, sync);
>> - =A0 =A0 =A0 if (status)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>>
>> =A0 =A0 =A0 =A0/* Clear layoutcommit properties in the inode so
>> =A0 =A0 =A0 =A0 * new lc info can be generated
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0nfsi->pnfs_write_begin_pos =3D 0;
>> =A0 =A0 =A0 =A0nfsi->pnfs_write_end_pos =3D 0;
>> - =A0 =A0 =A0 nfsi->layoutcommit_ctx =3D NULL;
>> + =A0 =A0 =A0 nfsi->lo_cred =3D NULL;
>> +
>> + =A0 =A0 =A0 if (status) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The layout driver failed to setup t=
he layoutcommit */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_rpccred(data->cred);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>> + =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0/* release lock on pnfs layoutcommit attrs */
>> =A0 =A0 =A0 =A0spin_unlock(&nfsi->lo_lock);
>>
>> =A0 =A0 =A0 =A0data->is_sync =3D sync;
>> =A0 =A0 =A0 =A0status =3D pnfs4_proc_layoutcommit(data);
>> + =A0 =A0 =A0 put_rpccred(data->cred);
> Is this OK to put_rpccred here if sync =3D=3D 0? why not move it into
> pnfs_layoutcommit_done just as the code did?

As I said in the patch comments, the RPC layer takes a reference on the=
 cred,

-->Andy

> --tao
>
>> =A0out:
>> =A0 =A0 =A0 =A0dprintk("%s end (err:%d)\n", __func__, status);
>> =A0 =A0 =A0 =A0return status;
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index a4c95a0..2c1918e 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1490,7 +1490,7 @@ static int nfs_commit_inode(struct inode *inod=
e, int how)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0nfs_wait_bit_killable,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0TASK_KILLABLE);
>> =A0#ifdef CONFIG_NFS_V4_1
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (may_wait && NFS_I(inode)->layoutco=
mmit_ctx) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (may_wait && do_layoutcommit(NFS_I(=
inode))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0error =3D pnfs_layout=
commit_inode(inode, 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (error < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retur=
n error;
>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>> index 4d47b48..c9ef43e 100644
>> --- a/include/linux/nfs4_pnfs.h
>> +++ b/include/linux/nfs4_pnfs.h
>> @@ -80,6 +80,12 @@ has_layout(struct nfs_inode *nfsi)
>> =A0 =A0 =A0 =A0return nfsi->layout.ld_data !=3D NULL;
>> =A0}
>>
>> +static inline bool
>> +do_layoutcommit(struct nfs_inode *nfsi)
>> +{
>> + =A0 =A0 =A0 return nfsi->lo_cred !=3D NULL;
>> +}
>> +
>> =A0#endif /* CONFIG_NFS_V4_1 */
>>
>> =A0struct pnfs_layout_segment {
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index 98a8dc0..478b00c 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -203,11 +203,10 @@ struct nfs_inode {
>> =A0#define NFS_INO_RW_LAYOUT_FAILED 1 =A0 =A0 /* get rw layout faile=
d stop trying */
>> =A0#define NFS_INO_LAYOUT_ALLOC =A0 =A0 2 =A0 =A0 /* bit lock for la=
yout allocation */
>> =A0 =A0 =A0 =A0time_t pnfs_layout_suspend;
>> + =A0 =A0 =A0 struct rpc_cred =A0 =A0 =A0 =A0 *lo_cred; /* layoutcom=
mit credential */
>> =A0 =A0 =A0 =A0wait_queue_head_t lo_waitq;
>> =A0 =A0 =A0 =A0spinlock_t lo_lock;
>> =A0 =A0 =A0 =A0struct pnfs_layout_type layout;
>> - =A0 =A0 =A0 /* use rpc_creds in this open_context to send LAYOUTCO=
MMIT to MDS */
>> - =A0 =A0 =A0 struct nfs_open_context *layoutcommit_ctx;
>> =A0 =A0 =A0 =A0/* DH: These vars keep track of the maximum write ran=
ge
>> =A0 =A0 =A0 =A0 * so the values can be used for layoutcommit.
>> =A0 =A0 =A0 =A0 */
>> diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
>> index a0bf341..154b04e 100644
>> --- a/include/linux/pnfs_xdr.h
>> +++ b/include/linux/pnfs_xdr.h
>> @@ -86,7 +86,6 @@ struct pnfs_layoutcommit_data {
>> =A0 =A0 =A0 =A0bool is_sync;
>> =A0 =A0 =A0 =A0struct rpc_cred *cred;
>> =A0 =A0 =A0 =A0struct nfs_fattr fattr;
>> - =A0 =A0 =A0 struct nfs_open_context *ctx;
>> =A0 =A0 =A0 =A0struct pnfs_layoutcommit_arg args;
>> =A0 =A0 =A0 =A0struct pnfs_layoutcommit_res res;
>> =A0 =A0 =A0 =A0int status;
>> --
>> 1.6.6
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
>
>
> --
> tao.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
