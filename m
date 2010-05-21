From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
	rpc_cred
Date: Fri, 21 May 2010 10:50:33 +0800
Message-ID: <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34218 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661Ab0EUCuf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 22:50:35 -0400
Received: by vws9 with SMTP id 9so518384vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 19:50:34 -0700 (PDT)
In-Reply-To: <1274371457-10003-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 21, 2010 at 12:04 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Taking a reference on the nfs_open_context to signal that a layoutcom=
mit is
> needed is problematic because the last reference to the context trigg=
ers a
> close (nfs_release). =C2=A0But, if the layout holds a reference on th=
e
> nfs_open_context, then close will not be triggered.
>
> Since we only use the rpc credential from the layoutcommit_ctx, repla=
ce the
> layoutcommit_ctx with the rpc_cred.
>
> Hold a reference on the rpc_cred until the layoutcommit rpc returns. =
Note that
> the rpc layer (rpcauth_bind) also references the rpc_cred.
>
> If the layoutdriver fails to setup the layoutcommit, clear the layout=
commit
> properties and put the credential.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =C2=A0fs/nfs/inode.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A04 ++--
> =C2=A0fs/nfs/nfs4state.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 =
+-
> =C2=A0fs/nfs/pnfs.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 42 +++++++++++++++++-------------------------
> =C2=A0fs/nfs/write.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A02 +-
> =C2=A0include/linux/nfs4_pnfs.h | =C2=A0 =C2=A06 ++++++
> =C2=A0include/linux/nfs_fs.h =C2=A0 =C2=A0| =C2=A0 =C2=A03 +--
> =C2=A0include/linux/pnfs_xdr.h =C2=A0| =C2=A0 =C2=A01 -
> =C2=A07 files changed, 28 insertions(+), 32 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 7fd33d9..2b8e8e6 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1110,7 +1110,7 @@ static int nfs_update_inode(struct inode *inode=
, struct nfs_fattr *fattr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * file needs layout commit, server attrib=
utes may be stale
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (nfsi->layoutcommit_ctx && nfsi->change_att=
r >=3D fattr->change_attr) {
> + =C2=A0 =C2=A0 =C2=A0 if (do_layoutcommit(nfsi) && nfsi->change_attr=
 >=3D fattr->change_attr) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("NFS: =
%s: layoutcommit is needed for file %s/%ld\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0__func__, inode->i_sb->s_id, inode->i_ino);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> @@ -1331,7 +1331,7 @@ static void pnfs_alloc_init_inode(struct nfs_in=
ode *nfsi)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_layout_state =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(&nfsi->layout.stateid, 0, NFS4_STAT=
EID_SIZE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->layout.roc_iomode =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 nfsi->layoutcommit_ctx =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 nfsi->lo_cred =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_begin_pos =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_end_pos =3D 0;
> =C2=A0#endif /* CONFIG_NFS_V4_1 */
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index d145de1..bf03fde 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -589,7 +589,7 @@ static void __nfs4_close(struct path *path, struc=
t nfs4_state *state, fmode_t fm
> =C2=A0#ifdef CONFIG_NFS_V4_1
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nfs_ino=
de *nfsi =3D NFS_I(state->inode);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nfsi->layoutco=
mmit_ctx)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_layoutcommi=
t(nfsi))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0pnfs_layoutcommit_inode(state->inode, wait);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (has_layout=
(nfsi) && nfsi->layout.roc_iomode) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0struct nfs4_pnfs_layout_segment range;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 20285bc..cb8ff06 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -145,21 +145,19 @@ find_pnfs(u32 id, struct pnfs_module **module) =
{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
> -/* Set context to indicate we require a layoutcommit
> +/* Set lo_cred to indicate we require a layoutcommit
> =C2=A0* If we don't even have a layout, we don't need to commit it.
> =C2=A0*/
> =C2=A0void
> =C2=A0pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_=
context *ctx)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 dprintk("%s: has_layout=3D%d layoutcommit_ctx=3D=
%p ctx=3D%p\n", __func__,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 has_layout(nfsi), =
nfsi->layoutcommit_ctx, ctx);
> + =C2=A0 =C2=A0 =C2=A0 dprintk("%s: has_layout=3D%d ctx=3D%p\n", __fu=
nc__, has_layout(nfsi), ctx);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&nfsi->lo_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (has_layout(nfsi) && !nfsi->layoutcommit_ct=
x) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsi->layoutcommit=
_ctx =3D get_nfs_open_context(ctx);
> + =C2=A0 =C2=A0 =C2=A0 if (has_layout(nfsi) && !do_layoutcommit(nfsi)=
) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfsi->lo_cred =3D =
get_rpccred(ctx->state->owner->so_cred);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->change_a=
ttr++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&n=
fsi->lo_lock);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dprintk("%s: Set l=
ayoutcommit_ctx=3D%p\n", __func__,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 nfsi->layoutcommit_ctx);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dprintk("%s: Set l=
ayoutcommit\n", __func__);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&nfsi->lo_lock);
> @@ -755,7 +753,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs=
4_pnfs_layout_segment *range,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0!pnfs_return_layout_barrier(n=
fsi, &arg));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nfsi->layoutco=
mmit_ctx) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_layoutcommi=
t(nfsi)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0status =3D pnfs_layoutcommit_inode(ino, wait);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (status) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s: layoutcommit fai=
led, status=3D%d. "
> @@ -1910,16 +1908,9 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommi=
t_data *data)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s: (status %d)\n", __func__, dat=
a->status);
>
> - =C2=A0 =C2=A0 =C2=A0 /* TODO: For now, set an error in the open con=
text (just like
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* if a commit failed) We may want to do =
more, much more, like
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* replay all writes through the NFSv4
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* server, or something.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 if (data->status < 0) {
> + =C2=A0 =C2=A0 =C2=A0 if (data->status < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_ER=
R "%s, Layoutcommit Failed! =3D %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 __func__, data->status);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data->ctx->error =3D=
 data->status;
> - =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TODO: Maybe we should avoid this by all=
owing the layout driver
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * to directly xdr its layout on the wire.
> @@ -1929,9 +1920,6 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit=
_data *data)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&nfsi->layout,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&data->args,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0data->status);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* release the open_context acquired in pnfs_w=
riteback_done */
> - =C2=A0 =C2=A0 =C2=A0 put_nfs_open_context(data->ctx);
> =C2=A0}
>
> =C2=A0/*
> @@ -1995,30 +1983,34 @@ pnfs_layoutcommit_inode(struct inode *inode, =
int sync)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOMEM=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&nfsi->lo_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (!nfsi->layoutcommit_ctx)
> + =C2=A0 =C2=A0 =C2=A0 if (!do_layoutcommit(nfsi))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_unloc=
k;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->args.inode =3D inode;
> - =C2=A0 =C2=A0 =C2=A0 data->cred =C2=A0=3D nfsi->layoutcommit_ctx->c=
red;
> - =C2=A0 =C2=A0 =C2=A0 data->ctx =3D nfsi->layoutcommit_ctx;
> + =C2=A0 =C2=A0 =C2=A0 data->cred =3D nfsi->lo_cred;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Set up layout commit args*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0status =3D pnfs_layoutcommit_setup(data, s=
ync);
> - =C2=A0 =C2=A0 =C2=A0 if (status)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Clear layoutcommit properties in the in=
ode so
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * new lc info can be generated
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_begin_pos =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_end_pos =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 nfsi->layoutcommit_ctx =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 nfsi->lo_cred =3D NULL;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (status) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* The layout driv=
er failed to setup the layoutcommit */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_rpccred(data->=
cred);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* release lock on pnfs layoutcommit attrs=
 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&nfsi->lo_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->is_sync =3D sync;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0status =3D pnfs4_proc_layoutcommit(data);
> + =C2=A0 =C2=A0 =C2=A0 put_rpccred(data->cred);
Is this OK to put_rpccred here if sync =3D=3D 0? why not move it into
pnfs_layoutcommit_done just as the code did?
--tao

> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s end (err:%d)\n", __func__, sta=
tus);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return status;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index a4c95a0..2c1918e 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1490,7 +1490,7 @@ static int nfs_commit_inode(struct inode *inode=
, int how)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0n=
fs_wait_bit_killable,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0T=
ASK_KILLABLE);
> =C2=A0#ifdef CONFIG_NFS_V4_1
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (may_wait && NF=
S_I(inode)->layoutcommit_ctx) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (may_wait && do=
_layoutcommit(NFS_I(inode))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0error =3D pnfs_layoutcommit_inode(inode, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (error < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;
> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
> index 4d47b48..c9ef43e 100644
> --- a/include/linux/nfs4_pnfs.h
> +++ b/include/linux/nfs4_pnfs.h
> @@ -80,6 +80,12 @@ has_layout(struct nfs_inode *nfsi)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return nfsi->layout.ld_data !=3D NULL;
> =C2=A0}
>
> +static inline bool
> +do_layoutcommit(struct nfs_inode *nfsi)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return nfsi->lo_cred !=3D NULL;
> +}
> +
> =C2=A0#endif /* CONFIG_NFS_V4_1 */
>
> =C2=A0struct pnfs_layout_segment {
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 98a8dc0..478b00c 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -203,11 +203,10 @@ struct nfs_inode {
> =C2=A0#define NFS_INO_RW_LAYOUT_FAILED 1 =C2=A0 =C2=A0 /* get rw layo=
ut failed stop trying */
> =C2=A0#define NFS_INO_LAYOUT_ALLOC =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 /* b=
it lock for layout allocation */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0time_t pnfs_layout_suspend;
> + =C2=A0 =C2=A0 =C2=A0 struct rpc_cred =C2=A0 =C2=A0 =C2=A0 =C2=A0 *l=
o_cred; /* layoutcommit credential */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wait_queue_head_t lo_waitq;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t lo_lock;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pnfs_layout_type layout;
> - =C2=A0 =C2=A0 =C2=A0 /* use rpc_creds in this open_context to send =
LAYOUTCOMMIT to MDS */
> - =C2=A0 =C2=A0 =C2=A0 struct nfs_open_context *layoutcommit_ctx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* DH: These vars keep track of the maximu=
m write range
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so the values can be used for layoutcom=
mit.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
> index a0bf341..154b04e 100644
> --- a/include/linux/pnfs_xdr.h
> +++ b/include/linux/pnfs_xdr.h
> @@ -86,7 +86,6 @@ struct pnfs_layoutcommit_data {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool is_sync;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rpc_cred *cred;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nfs_fattr fattr;
> - =C2=A0 =C2=A0 =C2=A0 struct nfs_open_context *ctx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pnfs_layoutcommit_arg args;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pnfs_layoutcommit_res res;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int status;
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
tao.
