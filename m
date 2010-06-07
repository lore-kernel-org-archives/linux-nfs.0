From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Mon, 7 Jun 2010 10:34:49 -0400
Message-ID: <AANLkTin5HaN8Hv1IOkItYCVauRPbNZrel8UwGC1CF7AA@mail.gmail.com>
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
	<1273078858-1923-2-git-send-email-batsakis@netapp.com>
	<1273078858-1923-3-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, bhalevy@panasas.com
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39800 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0FGOev convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 10:34:51 -0400
Received: by fxm8 with SMTP id 8so2130537fxm.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jun 2010 07:34:49 -0700 (PDT)
In-Reply-To: <1273078858-1923-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 5, 2010 at 1:00 PM, Alexandros Batsakis <batsakis-HgOvQuBEEgRhl2p70BpVqQ@public.gmane.org=
m> wrote:
> (also minor cleanup of pnfs_free_layout())
>
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
> =A0fs/nfs/pnfs.c | =A0 73 ++++++++++++++++++++++++++++++++++++-------=
-------------
> =A01 files changed, 47 insertions(+), 26 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index f32dbbb..a4031b4 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -60,6 +60,8 @@ static int pnfs_initialized;
> =A0static void pnfs_free_layout(struct pnfs_layout_type *lo,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_p=
nfs_layout_segment *range);
> =A0static enum pnfs_try_status pnfs_commit(struct nfs_write_data *dat=
a, int sync);
> +static inline void lock_current_layout(struct nfs_inode *nfsi);
> +static inline void unlock_current_layout(struct nfs_inode *nfsi);
>
> =A0/* Locking:
> =A0*
> @@ -152,15 +154,15 @@ void
> =A0pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_con=
text *ctx)
> =A0{
> =A0 =A0 =A0 =A0dprintk("%s: has_layout=3D%d ctx=3D%p\n", __func__, ha=
s_layout(nfsi), ctx);
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.lo_cred =3D get_rpccred(c=
tx->state->owner->so_cred);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->change_attr++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: Set layoutcommit\n", __fu=
nc__);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0}
>
> =A0/* Update last_write_offset for layoutcommit.
> @@ -173,7 +175,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, lo=
ff_t offset, size_t extent)
> =A0{
> =A0 =A0 =A0 =A0loff_t end_pos;
>
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0if (offset < nfsi->layout.pnfs_write_begin_pos)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.pnfs_write_begin_pos =3D =
offset;
> =A0 =A0 =A0 =A0end_pos =3D offset + extent - 1; /* I'm being inclusiv=
e */
> @@ -185,7 +187,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, lo=
ff_t offset, size_t extent)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) offset ,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) nfsi->layout.pnfs_writ=
e_begin_pos,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) nfsi->layout.pnfs_writ=
e_end_pos);
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0}
>
> =A0/* Unitialize a mountpoint in a layout driver */
> @@ -313,6 +315,17 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutd=
river_type *ld_type)
> =A0#define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
> =A0#endif /* CONFIG_SMP */
>
> +static inline void lock_current_layout(struct nfs_inode *nfsi)
> +{
> + =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> +}
> +
> +static inline void unlock_current_layout(struct nfs_inode *nfsi)
> +{
> + =A0 =A0 =A0 BUG_ON_UNLOCKED_LO((&nfsi->layout));
> + =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> +}
> +
> =A0/*
> =A0* get and lock nfsi->layout
> =A0*/
> @@ -321,10 +334,10 @@ get_lock_current_layout(struct nfs_inode *nfsi)
> =A0{
> =A0 =A0 =A0 =A0struct pnfs_layout_type *lo;
>
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0lo =3D &nfsi->layout;
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> =A0 =A0 =A0 =A0if (!lo->ld_data) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> @@ -344,7 +357,12 @@ put_unlock_current_layout(struct pnfs_layout_typ=
e *lo)
> =A0 =A0 =A0 =A0BUG_ON_UNLOCKED_LO(lo);
> =A0 =A0 =A0 =A0BUG_ON(lo->refcount <=3D 0);
>
> - =A0 =A0 =A0 if (--lo->refcount =3D=3D 0 && list_empty(&lo->segs)) {
> + =A0 =A0 =A0 lo->refcount--;
> +
> + =A0 =A0 =A0 if (lo->refcount > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 if (list_empty(&lo->segs)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct layoutdriver_io_operations *io_=
ops =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PNFS_LD_IO_OPS(lo);
>
> @@ -358,7 +376,8 @@ put_unlock_current_layout(struct pnfs_layout_type=
 *lo)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del_init(&nfsi->lo_inodes);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&clp->cl_lock);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> +out:
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0}
>
> =A0void
> @@ -367,7 +386,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo, =
atomic_t *count,
> =A0{
> =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D PNFS_NFS_INODE(lo);
>
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0if (range)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_free_layout(lo, range);
> =A0 =A0 =A0 =A0atomic_dec(count);
> @@ -386,6 +405,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0lo =3D get_lock_current_layout(nfsi);
> + =A0 =A0 =A0 if (!lo)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0pnfs_free_layout(lo, &range);
> =A0 =A0 =A0 =A0put_unlock_current_layout(lo);
> =A0}
> @@ -663,7 +684,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi=
,
> =A0 =A0 =A0 =A0struct pnfs_layout_segment *lseg;
> =A0 =A0 =A0 =A0bool ret =3D false;
>
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0list_for_each_entry (lseg, &nfsi->layout.segs, fi_list=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!should_free_lseg(lseg, range))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -677,7 +698,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi=
,
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (atomic_read(&nfsi->layout.lgetcount))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D true;
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>
> =A0 =A0 =A0 =A0dprintk("%s:Return %d\n", __func__, ret);
> =A0 =A0 =A0 =A0return ret;
> @@ -759,7 +780,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs=
4_pnfs_layout_segment *range,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* unlock w/o put rebalanced by eventu=
al call to
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * pnfs_layout_release
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pnfs_return_layout_barrier(nfsi, &=
arg)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: waiting\n=
", __func__);
> @@ -900,7 +921,7 @@ static int pnfs_wait_schedule(void *word)
> =A0*
> =A0* Note: If successful, nfsi->lo_lock is taken and the caller
> =A0* must put and unlock current_layout by using put_unlock_current_l=
ayout()
> - * when the returned layout is released.
> + * directly or pnfs_layout_release() when the returned layout is rel=
eased.
> =A0*/
> =A0static struct pnfs_layout_type *
> =A0get_lock_alloc_layout(struct inode *ino)
> @@ -935,7 +956,7 @@ get_lock_alloc_layout(struct inode *ino)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_client *clp=
 =3D NFS_SERVER(ino)->nfs_client;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* must grab the layou=
t lock before the client lock */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_loc=
k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfs=
i);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&clp->cl_loc=
k);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (list_empty(&nfsi->=
lo_inodes))
> @@ -1051,10 +1072,10 @@ void drain_layoutreturns(struct pnfs_layout_t=
ype *lo)
> =A0 =A0 =A0 =A0while (atomic_read(&lo->lretcount)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D PNFS_NFS_IN=
ODE(lo);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: waiting\n", __func__);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wait_event(nfsi->lo_waitq, (atomic_rea=
d(&lo->lretcount) =3D=3D 0));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -1093,13 +1114,13 @@ pnfs_update_layout(struct inode *ino,
> =A0 =A0 =A0 =A0/* Check to see if the layout for the given range alre=
ady exists */
> =A0 =A0 =A0 =A0lseg =3D pnfs_has_layout(lo, &arg, take_ref, !take_ref=
);
> =A0 =A0 =A0 =A0if (lseg && !lseg->valid) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (take_ref)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_lseg(lseg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (;;) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prepare_to_wait(&nfsi-=
>lo_waitq, &__wait,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0TASK_KILLABLE);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_loc=
k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfs=
i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lseg =3D pnfs_has_layo=
ut(lo, &arg, take_ref, !take_ref);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!lseg || lseg->val=
id)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -1112,7 +1133,7 @@ pnfs_update_layout(struct inode *ino,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0result=
 =3D -ERESTARTSYS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_l=
ock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(n=
fsi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0finish_wait(&nfsi->lo_waitq, &__wait);
> @@ -1149,7 +1170,7 @@ pnfs_update_layout(struct inode *ino,
> =A0 =A0 =A0 =A0/* Matching dec is done in .rpc_release (on non-error =
paths) */
> =A0 =A0 =A0 =A0atomic_inc(&lo->lgetcount);
> =A0 =A0 =A0 =A0/* Lose lock, but not reference, match this with pnfs_=
layout_release */
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>
> =A0 =A0 =A0 =A0result =3D get_layout(ino, ctx, &arg, lsegpp, lo);
> =A0out:
> @@ -1299,7 +1320,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget =
*lgp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*lgp->lsegpp =3D lseg;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0pnfs_insert_layout(lo, lseg);
>
> =A0 =A0 =A0 =A0if (res->return_on_close) {
> @@ -1310,7 +1331,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget =
*lgp)
>
> =A0 =A0 =A0 =A0/* Done processing layoutget. Set the layout stateid *=
/
> =A0 =A0 =A0 =A0pnfs_set_layout_stateid(lo, &res->stateid);
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
> =A0out:
> =A0 =A0 =A0 =A0return status;
> =A0}
> @@ -2140,9 +2161,9 @@ pnfs_layoutcommit_inode(struct inode *inode, in=
t sync)
> =A0 =A0 =A0 =A0if (!data)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>
> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
> + =A0 =A0 =A0 lock_current_layout(nfsi);
> =A0 =A0 =A0 =A0if (!layoutcommit_needed(nfsi)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfsi);

This should be unlock_current_layout

=46red

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free;
> =A0 =A0 =A0 =A0}
>
> @@ -2157,7 +2178,7 @@ pnfs_layoutcommit_inode(struct inode *inode, in=
t sync)
> =A0 =A0 =A0 =A0nfsi->layout.lo_cred =3D NULL;
> =A0 =A0 =A0 =A0pnfs_get_layout_stateid(&data->args.stateid, &nfsi->la=
yout);
>
> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>
> =A0 =A0 =A0 =A0/* Set up layout commit args */
> =A0 =A0 =A0 =A0status =3D pnfs_layoutcommit_setup(inode, data, write_=
begin_pos,
> --
> 1.6.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
