From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 05/16] SQUASHME pnfs-submit: rewrite layout allocation
Date: Tue, 13 Jul 2010 09:39:03 -0400
Message-ID: <AANLkTilb6ePL7s6H4TbhGfJt05Yw7Gc24V0C8cPHC22K@mail.gmail.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
	<1278542063-4009-2-git-send-email-andros@netapp.com>
	<1278542063-4009-3-git-send-email-andros@netapp.com>
	<1278542063-4009-4-git-send-email-andros@netapp.com>
	<1278542063-4009-5-git-send-email-andros@netapp.com>
	<1278542063-4009-6-git-send-email-andros@netapp.com>
	<4C3AD2AD.5010403@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:39719 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754367Ab0GMNjI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 09:39:08 -0400
Received: by gwj18 with SMTP id 18so2687782gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 06:39:06 -0700 (PDT)
In-Reply-To: <4C3AD2AD.5010403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 4:30 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Jul. 08, 2010, 1:34 +0300, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Don't wait on a bit if layout is not allocated. Instead, allocate,
>> check for existance, and possibly free.
>>
>> As per new layout refcounting scheme,don't take a reference on the l=
ayout.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0| =A0 84 +++++++++++++----------=
------------------------
>> =A0include/linux/nfs_fs.h | =A0 =A01 -
>> =A02 files changed, 23 insertions(+), 62 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 6d435ed..92b7772 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -914,7 +914,6 @@ alloc_init_layout(struct inode *ino)
>> =A0 =A0 =A0 struct pnfs_layout_type *lo;
>> =A0 =A0 =A0 struct layoutdriver_io_operations *io_ops;
>>
>> - =A0 =A0 BUG_ON(NFS_I(ino)->layout !=3D NULL);
>> =A0 =A0 =A0 io_ops =3D NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
>> =A0 =A0 =A0 lo =3D io_ops->alloc_layout(ino);
>> =A0 =A0 =A0 if (!lo) {
>> @@ -923,84 +922,47 @@ alloc_init_layout(struct inode *ino)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> =A0 =A0 =A0 }
>> - =A0 =A0 spin_lock(&ino->i_lock);
>> =A0 =A0 =A0 lo->refcount =3D 1;
>> =A0 =A0 =A0 INIT_LIST_HEAD(&lo->lo_layouts);
>> =A0 =A0 =A0 INIT_LIST_HEAD(&lo->segs);
>> =A0 =A0 =A0 seqlock_init(&lo->seqlock);
>> =A0 =A0 =A0 lo->lo_inode =3D ino;
>> - =A0 =A0 NFS_I(ino)->layout =3D lo;
>> - =A0 =A0 spin_unlock(&ino->i_lock);
>> =A0 =A0 =A0 return lo;
>> =A0}
>>
>> -static int pnfs_wait_schedule(void *word)
>> -{
>> - =A0 =A0 if (signal_pending(current))
>> - =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
>> - =A0 =A0 schedule();
>> - =A0 =A0 return 0;
>> -}
>> -
>> =A0/*
>> - * get, possibly allocate, and lock current_layout
>> + * Lock and possibly allocate the inode layout
>> =A0 *
>> - * Note: If successful, ino->i_lock is taken and the caller
>> - * must put and unlock current_layout when the returned layout is r=
eleased.
>> + * If successful, ino->i_lock is taken, and the caller must unlock.
>> =A0 */
>> =A0static struct pnfs_layout_type *
>> -get_lock_alloc_layout(struct inode *ino)
>> +nfs_lock_alloc_layout(struct inode *ino)
>> =A0{
>> - =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>> - =A0 =A0 struct pnfs_layout_type *lo;
>> - =A0 =A0 int res;
>> + =A0 =A0 struct pnfs_layout_type *new =3D NULL;
>>
>> =A0 =A0 =A0 dprintk("%s Begin\n", __func__);
>>
>> =A0 =A0 =A0 spin_lock(&ino->i_lock);
>> - =A0 =A0 while ((lo =3D grab_current_layout(nfsi)) =3D=3D NULL) {
>> + =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&ino->i_lock);
>
> There's no real need to take the lock here just for checking for NULL=
,
> only down below before actually committing the newly allocated struct=
=2E
> [I'll make this fix)


I'm not taking the lock just to check for NULL. I'm taking the lock
because the function returns a locked i_lock - (or did before you
changed it!)

-->Andy

>
> Benny
>
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* Compete against other threads on who's =
doing the allocation,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* wait until bit is cleared if we lost =
this race.
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 res =3D wait_on_bit_lock(
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nfsi->layout->pnfs_layout=
_state,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_INO_LAYOUT_ALLOC,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_wait_schedule, TASK_K=
ILLABLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (res) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D ERR_PTR(res);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* Was current_layout already allocated wh=
ile we slept?
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* If so, retry get_lock'ing it. Otherwi=
se, allocate it.
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nfsi->layout) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 new =3D alloc_init_layout(ino);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (new =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (NFS_I(ino)->layout =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_I(ino)->layout =3D new=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 lo =3D alloc_init_layout(ino);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (lo)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
>> - =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D ERR_PTR(-ENOMEM);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* release the NFS_INO_LAYOUT_ALLOC bit an=
d wake up waiters */
>> - =A0 =A0 =A0 =A0 =A0 =A0 clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi->=
layout->pnfs_layout_state);
>> - =A0 =A0 =A0 =A0 =A0 =A0 wake_up_bit(&nfsi->layout->pnfs_layout_sta=
te,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS_INO_LAYOUT_ALL=
OC);
>> - =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>> -
>> -#ifdef NFS_DEBUG
>> - =A0 =A0 if (!IS_ERR(lo))
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Return %p\n", __func__, lo);
>> - =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Return error %ld\n", __func__,=
 PTR_ERR(lo));
>> -#endif
>> - =A0 =A0 return lo;
>> + =A0 =A0 if (new) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Reference the layout accross i_lock rel=
ease and grab */
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_layout(NFS_I(ino)->layout);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&ino->i_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->=
free_layout(new);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&ino->i_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_layout(NFS_I(ino)->layout);
>> + =A0 =A0 }
>> + =A0 =A0 return NFS_I(ino)->layout;
>> =A0}
>>
>> =A0/*
>> @@ -1088,8 +1050,8 @@ _pnfs_update_layout(struct inode *ino,
>>
>> =A0 =A0 =A0 if (take_ref)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 *lsegpp =3D NULL;
>> - =A0 =A0 lo =3D get_lock_alloc_layout(ino);
>> - =A0 =A0 if (IS_ERR(lo)) {
>> + =A0 =A0 lo =3D nfs_lock_alloc_layout(ino);
>> + =A0 =A0 if (lo =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s ERROR: can't get pnfs_layout=
_type\n", __func__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index 7b999a4..005b3ea 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -107,7 +107,6 @@ struct pnfs_layout_type {
>> =A0 =A0 =A0 unsigned long pnfs_layout_state;
>> =A0 =A0 =A0 #define NFS_INO_RO_LAYOUT_FAILED 0 =A0 =A0 =A0/* get ro =
layout failed stop trying */
>> =A0 =A0 =A0 #define NFS_INO_RW_LAYOUT_FAILED 1 =A0 =A0 =A0/* get rw =
layout failed stop trying */
>> - =A0 =A0 #define NFS_INO_LAYOUT_ALLOC =A0 =A0 2 =A0 =A0 =A0/* bit l=
ock for layout allocation */
>> =A0 =A0 =A0 #define NFS_INO_LAYOUTCOMMIT =A0 =A0 3 =A0 =A0 =A0/* LAY=
OUTCOMMIT needed */
>> =A0 =A0 =A0 struct rpc_cred =A0 =A0 =A0 =A0 *lo_cred; /* layoutcommi=
t credential */
>> =A0 =A0 =A0 /* DH: These vars keep track of the maximum write range
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
