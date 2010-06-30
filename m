From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 2/5] SQUASHME: pnfs_submit: move pnfs_layout_state back to
	nfs_inode
Date: Wed, 30 Jun 2010 09:48:26 -0400
Message-ID: <AANLkTilGlRlUL6lCJE6byfv17T2ihrYjj2VjHH0ok7oc@mail.gmail.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com>
	<1277829737-5465-2-git-send-email-andros@netapp.com>
	<1277829737-5465-3-git-send-email-andros@netapp.com>
	<4C2B08C4.5000105@panasas.com>
	<4C2B0ED8.4000307@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andros@netapp.com, benny@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37747 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756040Ab0F3Ns1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 09:48:27 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so463106fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jun 2010 06:48:26 -0700 (PDT)
In-Reply-To: <4C2B0ED8.4000307@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 30, 2010 at 5:31 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 06/30/2010 12:05 PM, Boaz Harrosh wrote:
>> On 06/29/2010 07:42 PM, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Prepare to embed struct pnfs_layout_tupe into layout driver private=
 structs
>>> and to make layout a pointer: state flags need to be accessible bef=
ore
>>> allocation.
>>>
>>
>> I don't get that. A pointer inspection operation is atomic. (gone ar=
e the
>> days of 16-bit large/huge models where a pointer is two registers.)
>>
>> So an: if (lo->pointer) is just as atomic as test_bit()
>>
>> And I don't see, not here, and not in the next patch, where are thes=
e used before
>> the allocation. if you throw away Fred's first patch and make:
>> =A0layoutcommit_needed(struct nfs_inode *nfsi)
>> =A0{
>> - =A0 =A0 return nfsi->layout.lo_cred !=3D NULL;
>> + =A0 =A0 return nfsi->layout !=3D NULL;
>> =A0}
>>
>
> Rrrr need my morning coffee, sorry.
>
> But still, Fred's patch can go both sites of the pointer assignment h=
ave an
> MB and a pointer inspection is there-for atomic. Above can then be:
>
> =A0layoutcommit_needed(struct nfs_inode *nfsi)
> =A0{
> - =A0 =A0 =A0 return nfsi->layout.lo_cred !=3D NULL;
> + =A0 =A0 =A0 return nfsi->layout && (nfsi->layout->lo_cred !=3D NULL=
);
> =A0}
>

This is called outside of pnfs.c, without lock.  Thus there is no
guarantee that nfsi->layout won't go to to NULL during the '&&'.

=46red

>
>> Then all three patches (first one thrown away) can just collapse to =
a single
>> embedded-to-pointer conversion.
>>
>
> This still applies
>
> Boaz
>> Boaz
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> =A0fs/nfs/inode.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
>>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0| =A0 16 ++++++++--------
>>> =A0include/linux/nfs_fs.h | =A0 10 +++++-----
>>> =A03 files changed, 14 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>> index 7989dea..66d7be2 100644
>>> --- a/fs/nfs/inode.c
>>> +++ b/fs/nfs/inode.c
>>> @@ -1364,7 +1364,6 @@ void nfs4_clear_inode(struct inode *inode)
>>> =A0static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
>>> =A0{
>>> =A0#ifdef CONFIG_NFS_V4_1
>>> - =A0 =A0nfsi->layout.pnfs_layout_state =3D 0;
>>> =A0 =A0 =A0memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
>>> =A0 =A0 =A0nfsi->layout.roc_iomode =3D 0;
>>> =A0 =A0 =A0nfsi->layout.lo_cred =3D NULL;
>>> @@ -1420,6 +1419,7 @@ static void pnfs_init_once(struct nfs_inode *=
nfsi)
>>> =A0{
>>> =A0#ifdef CONFIG_NFS_V4_1
>>> =A0 =A0 =A0init_waitqueue_head(&nfsi->lo_waitq);
>>> + =A0 =A0nfsi->pnfs_layout_state =3D 0;
>>> =A0 =A0 =A0seqlock_init(&nfsi->layout.seqlock);
>>> =A0 =A0 =A0INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
>>> =A0 =A0 =A0INIT_LIST_HEAD(&nfsi->layout.segs);
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index bf15b5c..d05cb03 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -951,7 +951,7 @@ get_lock_alloc_layout(struct inode *ino)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 * wait until bit is cleared if we lost =
this race.
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0res =3D wait_on_bit_lock(
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi->layout.pnfs_layout_=
state,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi->pnfs_layout_state,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_INO_LAYOUT_ALLOC,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_wait_schedule, TASK=
_KILLABLE);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (res) {
>>> @@ -975,8 +975,8 @@ get_lock_alloc_layout(struct inode *ino)
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0/* release the NFS_INO_LAYOUT_ALLOC bit =
and wake up waiters */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nfsi->la=
yout.pnfs_layout_state);
>>> - =A0 =A0 =A0 =A0 =A0 =A0wake_up_bit(&nfsi->layout.pnfs_layout_stat=
e,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nfsi->pn=
fs_layout_state);
>>> + =A0 =A0 =A0 =A0 =A0 =A0wake_up_bit(&nfsi->pnfs_layout_state,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_INO_LAYOUT_A=
LLOC);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>>> =A0 =A0 =A0}
>>> @@ -1104,12 +1104,12 @@ _pnfs_update_layout(struct inode *ino,
>>> =A0 =A0 =A0}
>>>
>>> =A0 =A0 =A0/* if get layout already failed once goto out */
>>> - =A0 =A0if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layou=
t_state)) {
>>> + =A0 =A0if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state=
)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(nfsi->layout.pnfs_layout_su=
spend &&
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_seconds() >=3D nfsi->layout.=
pnfs_layout_suspend)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dprintk("%s: layout_get =
resumed\n", __func__);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_bit(lo_fail_bit(io=
mode),
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi-=
>layout.pnfs_layout_state);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&nfsi-=
>pnfs_layout_state);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.pnfs_layout=
_suspend =3D 0;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_put;
>>> @@ -1121,7 +1121,7 @@ _pnfs_update_layout(struct inode *ino,
>>> =A0 =A0 =A0send_layoutget(ino, ctx, &arg, lsegpp, lo);
>>> =A0out:
>>> =A0 =A0 =A0dprintk("%s end, state 0x%lx lseg %p\n", __func__,
>>> - =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout.pnfs_layout_state, lseg);
>>> + =A0 =A0 =A0 =A0 =A0 =A0nfsi->pnfs_layout_state, lseg);
>>> =A0 =A0 =A0return;
>>> =A0out_put:
>>> =A0 =A0 =A0if (lsegpp)
>>> @@ -1226,12 +1226,12 @@ pnfs_get_layout_done(struct nfs4_pnfs_layou=
tget *lgp, int rpc_status)
>>> =A0 =A0 =A0/* remember that get layout failed and suspend trying */
>>> =A0 =A0 =A0nfsi->layout.pnfs_layout_suspend =3D suspend;
>>> =A0 =A0 =A0set_bit(lo_fail_bit(lgp->args.lseg.iomode),
>>> - =A0 =A0 =A0 =A0 =A0 =A0&nfsi->layout.pnfs_layout_state);
>>> + =A0 =A0 =A0 =A0 =A0 =A0&nfsi->pnfs_layout_state);
>>> =A0 =A0 =A0dprintk("%s: layout_get suspended until %ld\n",
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, suspend);
>>> =A0out:
>>> =A0 =A0 =A0dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
>>> - =A0 =A0 =A0 =A0 =A0 =A0__func__, lgp->status, nfsi->layout.pnfs_l=
ayout_state, lseg);
>>> + =A0 =A0 =A0 =A0 =A0 =A0__func__, lgp->status, nfsi->pnfs_layout_s=
tate, lseg);
>>> =A0 =A0 =A0return;
>>> =A0}
>>>
>>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>>> index a33e86e..e216e24 100644
>>> --- a/include/linux/nfs_fs.h
>>> +++ b/include/linux/nfs_fs.h
>>> @@ -105,11 +105,6 @@ struct pnfs_layout_type {
>>> =A0 =A0 =A0seqlock_t seqlock; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Protect=
s the stateid */
>>> =A0 =A0 =A0nfs4_stateid stateid;
>>> =A0 =A0 =A0void *ld_data; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* lay=
out driver private data */
>>> - =A0 =A0unsigned long pnfs_layout_state;
>>> - =A0 =A0#define NFS_INO_RO_LAYOUT_FAILED 0 =A0 =A0 =A0/* get ro la=
yout failed stop trying */
>>> - =A0 =A0#define NFS_INO_RW_LAYOUT_FAILED 1 =A0 =A0 =A0/* get rw la=
yout failed stop trying */
>>> - =A0 =A0#define NFS_INO_LAYOUT_ALLOC =A0 =A0 2 =A0 =A0 =A0/* bit l=
ock for layout allocation */
>>> - =A0 =A0#define NFS_INO_LAYOUTCOMMIT =A0 =A0 3 =A0 =A0 =A0/* LAYOU=
TCOMMIT needed */
>>> =A0 =A0 =A0time_t pnfs_layout_suspend;
>>> =A0 =A0 =A0struct rpc_cred =A0 =A0 =A0 =A0 *lo_cred; /* layoutcommi=
t credential */
>>> =A0 =A0 =A0/* DH: These vars keep track of the maximum write range
>>> @@ -208,6 +203,11 @@ struct nfs_inode {
>>> =A0#if defined(CONFIG_NFS_V4_1)
>>> =A0 =A0 =A0wait_queue_head_t lo_waitq;
>>> =A0 =A0 =A0struct pnfs_layout_type layout;
>>> + =A0 =A0unsigned long pnfs_layout_state;
>>> + =A0 =A0#define NFS_INO_RO_LAYOUT_FAILED 0 /* ro LAYOUTGET failed =
stop trying */
>>> + =A0 =A0#define NFS_INO_RW_LAYOUT_FAILED 1 /* rw LAYOUTGET failed =
stop trying */
>>> + =A0 =A0#define NFS_INO_LAYOUT_ALLOC =A0 =A0 2 /* bit lock for lay=
out allocation */
>>> + =A0 =A0#define NFS_INO_LAYOUTCOMMIT =A0 =A0 3 /* LAYOUTCOMMIT nee=
ded */
>>> =A0#endif /* CONFIG_NFS_V4_1 */
>>> =A0#endif /* CONFIG_NFS_V4*/
>>> =A0#ifdef CONFIG_NFS_FSCACHE
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
