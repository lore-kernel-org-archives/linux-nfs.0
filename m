From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Fri, 28 May 2010 11:27:49 -0700
Message-ID: <AANLkTik2S2VvqYwzgThNNBmlNd3DWro-5-BtvIQZMPGF@mail.gmail.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com>
	<1274119004-30213-2-git-send-email-batsakis@netapp.com>
	<1274119004-30213-3-git-send-email-batsakis@netapp.com>
	<AANLkTinsHI0fHYdpUlq-MsMX0BmsLGvdAbrKx7M5ydjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>, bhalevy@panasas.com,
	linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:46743 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629Ab0E1S1t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 May 2010 14:27:49 -0400
Received: by pxi18 with SMTP id 18so659382pxi.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 May 2010 11:27:49 -0700 (PDT)
In-Reply-To: <AANLkTinsHI0fHYdpUlq-MsMX0BmsLGvdAbrKx7M5ydjw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 28, 2010 at 10:27 AM, Fred Isaman <iisaman@citi.umich.edu> =
wrote:
> On Mon, May 17, 2010 at 1:56 PM, Alexandros Batsakis
> <batsakis@netapp.com> wrote:
>> (also minor cleanup of pnfs_free_layout())
>>
>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>>
>> Conflicts:
>>
>> =A0 =A0 =A0 =A0fs/nfs/pnfs.c
>> ---
>> =A0fs/nfs/pnfs.c | =A0 80 +++++++++++++++++++++++++++++++++++++-----=
--------------
>> =A01 files changed, 53 insertions(+), 27 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index b72c013..74cb998 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1,4 +1,4 @@
>> -/*
>> + /*
>> =A0* =A0linux/fs/nfs/pnfs.c
>> =A0*
>> =A0* =A0pNFS functions to call and manage layout drivers.
>> @@ -60,6 +60,8 @@ static int pnfs_initialized;
>> =A0static void pnfs_free_layout(struct pnfs_layout_type *lo,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs4_=
pnfs_layout_segment *range);
>> =A0static enum pnfs_try_status pnfs_commit(struct nfs_write_data *da=
ta, int sync);
>> +static inline void lock_current_layout(struct nfs_inode *nfsi);
>> +static inline void unlock_current_layout(struct nfs_inode *nfsi);
>>
>> =A0/* Locking:
>> =A0*
>> @@ -153,16 +155,17 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi,=
 struct nfs_open_context *ctx)
>> =A0{
>> =A0 =A0 =A0 =A0dprintk("%s: has_layout=3D%d layoutcommit_ctx=3D%p ct=
x=3D%p\n", __func__,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0has_layout(nfsi), nfsi->layout.layout=
commit_ctx, ctx);
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> +
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0if (has_layout(nfsi) && !nfsi->layout.layoutcommit_ct=
x) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.layoutcommit_ctx =3D get=
_nfs_open_context(ctx);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->change_attr++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: Set layoutcommit_ctx=3D%=
p\n", __func__,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.layoutco=
mmit_ctx);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>> =A0 =A0 =A0 =A0}
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0}
>>
>> =A0/* Update last_write_offset for layoutcommit.
>> @@ -175,7 +178,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, l=
off_t offset, size_t extent)
>> =A0{
>> =A0 =A0 =A0 =A0loff_t end_pos;
>>
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0if (offset < nfsi->layout.pnfs_write_begin_pos)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.pnfs_write_begin_pos =3D=
 offset;
>> =A0 =A0 =A0 =A0end_pos =3D offset + extent - 1; /* I'm being inclusi=
ve */
>> @@ -187,7 +190,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, l=
off_t offset, size_t extent)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) offset ,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) nfsi->layout.pnfs_wri=
te_begin_pos,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) nfsi->layout.pnfs_wri=
te_end_pos);
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0}
>>
>> =A0/* Unitialize a mountpoint in a layout driver */
>> @@ -296,12 +299,27 @@ pnfs_unregister_layoutdriver(struct pnfs_layou=
tdriver_type *ld_type)
>> =A0* pNFS client layout cache
>> =A0*/
>> =A0#if defined(CONFIG_SMP)
>> +#define BUG_ON_LOCKED_LO(lo) \
>> + =A0 =A0 =A0 BUG_ON(spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
>> =A0#define BUG_ON_UNLOCKED_LO(lo) \
>> =A0 =A0 =A0 =A0BUG_ON(!spin_is_locked(&PNFS_NFS_INODE(lo)->lo_lock))
>> =A0#else /* CONFIG_SMP */
>> +#define BUG_ON_LOCKED_LO(lo) do {} while (0)
>> =A0#define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
>> =A0#endif /* CONFIG_SMP */
>>
>> +static inline void lock_current_layout(struct nfs_inode *nfsi)
>> +{
>> + =A0 =A0 =A0 BUG_ON_LOCKED_LO((&nfsi->layout));
>
> I just ran into this in testing. This check causes problems. =A0If yo=
u
> know it is already unlocked, you wouldn't have to "spin".
>

Yeah I saw that too. I fixed it in the new version that is coming up.

-alexandros

> Fred
>
>> + =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> +}
>> +
>> +static inline void unlock_current_layout(struct nfs_inode *nfsi)
>> +{
>> + =A0 =A0 =A0 BUG_ON_UNLOCKED_LO((&nfsi->layout));
>> + =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> +}
>> +
>> =A0/*
>> =A0* get and lock nfsi->layout
>> =A0*/
>> @@ -310,10 +328,10 @@ get_lock_current_layout(struct nfs_inode *nfsi=
)
>> =A0{
>> =A0 =A0 =A0 =A0struct pnfs_layout_type *lo;
>>
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0lo =3D &nfsi->layout;
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> =A0 =A0 =A0 =A0if (!lo->ld_data) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>> =A0 =A0 =A0 =A0}
>>
>> @@ -333,7 +351,12 @@ put_unlock_current_layout(struct pnfs_layout_ty=
pe *lo)
>> =A0 =A0 =A0 =A0BUG_ON_UNLOCKED_LO(lo);
>> =A0 =A0 =A0 =A0BUG_ON(lo->refcount <=3D 0);
>>
>> - =A0 =A0 =A0 if (--lo->refcount =3D=3D 0 && list_empty(&lo->segs)) =
{
>> + =A0 =A0 =A0 lo->refcount--;
>> +
>> + =A0 =A0 =A0 if (lo->refcount > 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 =A0 if (list_empty(&lo->segs)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct layoutdriver_io_operations *io=
_ops =3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PNFS_LD_IO_OPS(lo);
>>
>> @@ -347,7 +370,8 @@ put_unlock_current_layout(struct pnfs_layout_typ=
e *lo)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del_init(&nfsi->lo_inodes);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&clp->cl_lock);
>> =A0 =A0 =A0 =A0}
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> +out:
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0}
>>
>> =A0void
>> @@ -356,7 +380,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,=
 atomic_t *count,
>> =A0{
>> =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D PNFS_NFS_INODE(lo);
>>
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0if (range)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_free_layout(lo, range);
>> =A0 =A0 =A0 =A0atomic_dec(count);
>> @@ -375,6 +399,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
>> =A0 =A0 =A0 =A0};
>>
>> =A0 =A0 =A0 =A0lo =3D get_lock_current_layout(nfsi);
>> + =A0 =A0 =A0 if (!lo)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 =A0pnfs_free_layout(lo, &range);
>> =A0 =A0 =A0 =A0put_unlock_current_layout(lo);
>> =A0}
>> @@ -652,7 +678,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfs=
i,
>> =A0 =A0 =A0 =A0struct pnfs_layout_segment *lseg;
>> =A0 =A0 =A0 =A0bool ret =3D false;
>>
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0list_for_each_entry (lseg, &nfsi->layout.segs, fi_lis=
t) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!should_free_lseg(lseg, range))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>> @@ -666,7 +692,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfs=
i,
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0if (atomic_read(&nfsi->layout.lgetcount))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D true;
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>>
>> =A0 =A0 =A0 =A0dprintk("%s:Return %d\n", __func__, ret);
>> =A0 =A0 =A0 =A0return ret;
>> @@ -756,7 +782,7 @@ _pnfs_return_layout(struct inode *ino, struct nf=
s4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* unlock w/o put rebalanced by event=
ual call to
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * pnfs_layout_release
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pnfs_return_layout_barrier(nfsi, =
&arg)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: waiting\=
n", __func__);
>> @@ -887,7 +913,7 @@ static int pnfs_wait_schedule(void *word)
>> =A0*
>> =A0* Note: If successful, nfsi->lo_lock is taken and the caller
>> =A0* must put and unlock current_layout by using put_unlock_current_=
layout()
>> - * when the returned layout is released.
>> + * directly or pnfs_layout_release() when the returned layout is re=
leased.
>> =A0*/
>> =A0static struct pnfs_layout_type *
>> =A0get_lock_alloc_layout(struct inode *ino)
>> @@ -922,7 +948,7 @@ get_lock_alloc_layout(struct inode *ino)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_client *cl=
p =3D NFS_SERVER(ino)->nfs_client;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* must grab the layo=
ut lock before the client lock */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_lo=
ck);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nf=
si);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&clp->cl_lo=
ck);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (list_empty(&nfsi-=
>lo_inodes))
>> @@ -1038,10 +1064,10 @@ void drain_layoutreturns(struct pnfs_layout_=
type *lo)
>> =A0 =A0 =A0 =A0while (atomic_read(&lo->lretcount)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D PNFS_NFS_I=
NODE(lo);
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: waiting\n", __func__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wait_event(nfsi->lo_waitq, (atomic_re=
ad(&lo->lretcount) =3D=3D 0));
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0}
>> =A0}
>>
>> @@ -1080,13 +1106,13 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0/* Check to see if the layout for the given range alr=
eady exists */
>> =A0 =A0 =A0 =A0lseg =3D pnfs_has_layout(lo, &arg, take_ref, !take_re=
f);
>> =A0 =A0 =A0 =A0if (lseg && !lseg->valid) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (take_ref)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_lseg(lseg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (;;) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prepare_to_wait(&nfsi=
->lo_waitq, &__wait,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0TASK_KILLABLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&nfsi->lo_lo=
ck);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nf=
si);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lseg =3D pnfs_has_lay=
out(lo, &arg, take_ref, !take_ref);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!lseg || lseg->va=
lid)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break=
;
>> @@ -1099,7 +1125,7 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0resul=
t =3D -ERESTARTSYS;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_=
lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(=
nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0finish_wait(&nfsi->lo_waitq, &__wait)=
;
>> @@ -1136,7 +1162,7 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0/* Matching dec is done in .rpc_release (on non-error=
 paths) */
>> =A0 =A0 =A0 =A0atomic_inc(&lo->lgetcount);
>> =A0 =A0 =A0 =A0/* Lose lock, but not reference, match this with pnfs=
_layout_release */
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>>
>> =A0 =A0 =A0 =A0result =3D get_layout(ino, ctx, &arg, lsegpp, lo);
>> =A0out:
>> @@ -1286,7 +1312,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget=
 *lgp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*lgp->lsegpp =3D lseg;
>> =A0 =A0 =A0 =A0}
>>
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0pnfs_insert_layout(lo, lseg);
>>
>> =A0 =A0 =A0 =A0if (res->return_on_close) {
>> @@ -1297,7 +1323,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget=
 *lgp)
>>
>> =A0 =A0 =A0 =A0/* Done processing layoutget. Set the layout stateid =
*/
>> =A0 =A0 =A0 =A0pnfs_set_layout_stateid(lo, &res->stateid);
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0out:
>> =A0 =A0 =A0 =A0return status;
>> =A0}
>> @@ -2212,7 +2238,7 @@ pnfs_layoutcommit_inode(struct inode *inode, i=
nt sync)
>> =A0 =A0 =A0 =A0if (!data)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>>
>> - =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0if (!nfsi->layout.layoutcommit_ctx)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unlock;
>>
>> @@ -2233,7 +2259,7 @@ pnfs_layoutcommit_inode(struct inode *inode, i=
nt sync)
>> =A0 =A0 =A0 =A0nfsi->layout.layoutcommit_ctx =3D NULL;
>>
>> =A0 =A0 =A0 =A0/* release lock on pnfs layoutcommit attrs */
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>>
>> =A0 =A0 =A0 =A0data->is_sync =3D sync;
>> =A0 =A0 =A0 =A0status =3D pnfs4_proc_layoutcommit(data);
>> @@ -2242,7 +2268,7 @@ out:
>> =A0 =A0 =A0 =A0return status;
>> =A0out_unlock:
>> =A0 =A0 =A0 =A0pnfs_layoutcommit_free(data);
>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>> + =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0goto out;
>> =A0}
>>
>> --
>> 1.6.2.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
