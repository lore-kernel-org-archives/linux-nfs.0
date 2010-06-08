From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [PATCH 5/8] pnfs-submit: request whole-file layouts only
Date: Tue, 8 Jun 2010 00:33:21 -0700
Message-ID: <AANLkTim7M3uqTPupvNnyeCQqbKt2oP_sJ7M4fiIkSrEB@mail.gmail.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
	<1275945113-3436-2-git-send-email-batsakis@netapp.com>
	<1275945113-3436-3-git-send-email-batsakis@netapp.com>
	<1275945113-3436-4-git-send-email-batsakis@netapp.com>
	<1275945113-3436-5-git-send-email-batsakis@netapp.com>
	<1275945113-3436-6-git-send-email-batsakis@netapp.com>
	<4C0DEDC1.6070105@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44139 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab0FHHdW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:33:22 -0400
Received: by gye5 with SMTP id 5so2866926gye.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 00:33:21 -0700 (PDT)
In-Reply-To: <4C0DEDC1.6070105@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 8, 2010 at 12:14 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On 2010-06-08 00:11, Alexandros Batsakis wrote:
>> In the first iteration of the pNFS code, we support only whole file =
layouts.
>> To facilitate the move to multiple-segments, we keep the segment pro=
cessing
>> code, but the segment list should always contain at most one segment=
 per I/O type
>>
>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>> ---
>> =A0fs/nfs/callback_proc.c | =A0 =A07 ++++---
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0| =A0 25 ++++++++---------------=
--
>> =A02 files changed, 12 insertions(+), 20 deletions(-)
>>
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 8752239..16b4510 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -213,6 +213,10 @@ static int pnfs_recall_layout(void *data)
>> =A0 =A0 then return layouts, resume after layoutreturns complete
>> =A0 */
>>
>> + =A0 =A0 /* support whole file layouts only */
>> + =A0 =A0 rl.cbl_seg.offset =3D 0;
>> + =A0 =A0 rl.cbl_seg.length =3D NFS4_MAX_UINT64;
>> +
>> =A0 =A0 =A0 if (rl.cbl_recall_type =3D=3D RETURN_FILE) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_return_layout(inode, &rl=
=2Ecbl_seg, &rl.cbl_stateid,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 RETURN_FILE, true);
>> @@ -221,9 +225,6 @@ static int pnfs_recall_layout(void *data)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 rl.cbl_seg.offset =3D 0;
>> - =A0 =A0 rl.cbl_seg.length =3D NFS4_MAX_UINT64;
>> -
>> =A0 =A0 =A0 /* FIXME: This loop is inefficient, running in O(|s_inod=
es|^2) */
>> =A0 =A0 =A0 while ((ino =3D nfs_layoutrecall_find_inode(clp, &rl)) !=
=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* XXX need to check status on pnfs_retu=
rn_layout */
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index dd7ad26..8985e9f 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -551,12 +551,6 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst=
, struct nfs4_state *state)
>> =A0* =A0 =A0for now, assume that whole file layouts are requested.
>> =A0* =A0 =A0arg->offset: 0
>> =A0* =A0 =A0arg->length: all ones
>> -*
>> -* =A0 =A0for now, assume the LAYOUTGET operation is triggered by an=
 I/O request.
>> -* =A0 =A0the count field is the count in the I/O request, and will =
be used
>> -* =A0 =A0as the minlength. for the file operation that piggy-backs
>> -* =A0 =A0the LAYOUTGET operation with an OPEN, s
>> -* =A0 =A0arg->minlength =3D count.
>> =A0*/
>> =A0static int
>> =A0get_layout(struct inode *ino,
>> @@ -577,11 +571,11 @@ get_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 lgp->lo =3D lo;
>> - =A0 =A0 lgp->args.minlength =3D PAGE_CACHE_SIZE;
>> + =A0 =A0 lgp->args.minlength =3D NFS4_MAX_UINT64;
>> =A0 =A0 =A0 lgp->args.maxcount =3D PNFS_LAYOUT_MAXSIZE;
>> =A0 =A0 =A0 lgp->args.lseg.iomode =3D range->iomode;
>> - =A0 =A0 lgp->args.lseg.offset =3D range->offset;
>> - =A0 =A0 lgp->args.lseg.length =3D max(range->length, lgp->args.min=
length);
>> + =A0 =A0 lgp->args.lseg.offset =3D 0;
>> + =A0 =A0 lgp->args.lseg.length =3D NFS4_MAX_UINT64;
>
> I'm not sure how well this will work for pnfs-obj writes.
> We might have to revert it in the pnfs post-submit branch.
>
> Benny
>

Agreed... but bear in mind that there are other things that need to
change too to properly (and efficiently) support partial layouts (e.g.
layout operation sequencing). So maybe a fresh patch will be more
appropriate, but it's up to you of course.

-alexandros

>> =A0 =A0 =A0 lgp->args.type =3D server->pnfs_curr_ld->id;
>> =A0 =A0 =A0 lgp->args.inode =3D ino;
>> =A0 =A0 =A0 lgp->lsegpp =3D lsegpp;
>> @@ -756,7 +750,7 @@ _pnfs_return_layout(struct inode *ino, struct nf=
s4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg.iomode =3D IOMODE_ANY;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg.offset =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 arg.length =3D ~0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 arg.length =3D NFS4_MAX_UINT64;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 if (type =3D=3D RETURN_FILE) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D get_lock_current_layout(nfsi);
>> @@ -1051,8 +1045,8 @@ pnfs_update_layout(struct inode *ino,
>> =A0{
>> =A0 =A0 =A0 struct nfs4_pnfs_layout_segment arg =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .iomode =3D iomode,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .offset =3D pos,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .length =3D count
>> + =A0 =A0 =A0 =A0 =A0 =A0 .offset =3D 0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .length =3D ~0
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>> =A0 =A0 =A0 struct pnfs_layout_type *lo;
>> @@ -1142,7 +1136,6 @@ out_put:
>> =A0void
>> =A0pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_sta=
tus)
>> =A0{
>> - =A0 =A0 struct nfs4_pnfs_layoutget_res *res =3D &lgp->res;
>> =A0 =A0 =A0 struct pnfs_layout_segment *lseg =3D NULL;
>> =A0 =A0 =A0 struct nfs_inode *nfsi =3D PNFS_NFS_INODE(lgp->lo);
>> =A0 =A0 =A0 time_t suspend =3D 0;
>> @@ -1151,11 +1144,10 @@ pnfs_get_layout_done(struct nfs4_pnfs_layout=
get *lgp, int rpc_status)
>>
>> =A0 =A0 =A0 lgp->status =3D rpc_status;
>> =A0 =A0 =A0 if (likely(!rpc_status)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(res->layout.len <=3D 0)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(lgp->res.layout.len < 0)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%s: ERROR!=
 =A0Layout size is ZERO!\n", __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%s: ERROR =
Returned layout size is ZERO\n", __func__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lgp->status =3D -EIO;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto get_out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>> @@ -1233,7 +1225,6 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutge=
t *lgp, int rpc_status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>>
>> -get_out:
>> =A0 =A0 =A0 /* remember that get layout failed and suspend trying */
>> =A0 =A0 =A0 nfsi->layout.pnfs_layout_suspend =3D suspend;
>> =A0 =A0 =A0 set_bit(lo_fail_bit(lgp->args.lseg.iomode),
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
