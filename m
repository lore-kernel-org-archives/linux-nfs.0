From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 11/24] pnfs_submit: expose pnfs_update_layout, put_lseg,
	and get_lseg functions
Date: Wed, 9 Jun 2010 15:20:51 -0400
Message-ID: <AANLkTilznvzt-x7i8y3vo5JsL_FUwDzAlv5TLd-huhzt@mail.gmail.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
	<1275970761-31806-2-git-send-email-iisaman@netapp.com>
	<1275970761-31806-3-git-send-email-iisaman@netapp.com>
	<1275970761-31806-4-git-send-email-iisaman@netapp.com>
	<1275970761-31806-5-git-send-email-iisaman@netapp.com>
	<1275970761-31806-6-git-send-email-iisaman@netapp.com>
	<1275970761-31806-7-git-send-email-iisaman@netapp.com>
	<1275970761-31806-8-git-send-email-iisaman@netapp.com>
	<1275970761-31806-9-git-send-email-iisaman@netapp.com>
	<1275970761-31806-10-git-send-email-iisaman@netapp.com>
	<1275970761-31806-11-git-send-email-iisaman@netapp.com>
	<1275970761-31806-12-git-send-email-iisaman@netapp.com>
	<4C0FE44D.20507@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61977 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756515Ab0FITUx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 15:20:53 -0400
Received: by bwz11 with SMTP id 11so1658265bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jun 2010 12:20:52 -0700 (PDT)
In-Reply-To: <4C0FE44D.20507@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 9, 2010 at 2:58 PM, Boaz Harrosh <bharrosh@panasas.com> wro=
te:
> On 06/08/2010 07:19 AM, Fred Isaman wrote:
>> These will be used in the generic code. =A0Set so they will compile =
away to
>> nothing if CONFIG_NFS_V4_1 not set.
>>
>> This requires kref_put to be under lock. =A0See rule 3 of Documentat=
ion/kref.txt
>>
>
> I don't see "rule 3" in here. Please explain how?

3) If the code attempts to gain a reference to a kref-ed structure
   without already holding a valid pointer, it must serialize access
   where a kref_put() cannot occur during the kref_get(), and the
   structure must remain valid during the kref_get().

This occurs every time we call pnfs_update_layout


>
> BTW: Even "rule 3" bad example with the lists, have a counter example=
 in the Kernel
> =A0 =A0 with lists and searches that kref_put/get lockless. (By each =
element refing
> =A0 =A0 it's pear and taking the reference of the first one before se=
arch)
>

I don't follow this.

>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> =A0fs/nfs/pnfs.c | =A0 45 ++++++++++++++++++++++++++++++++----------=
---
>> =A0fs/nfs/pnfs.h | =A0 44 ++++++++++++++++++++++++++++++++++++++++++=
+-
>> =A02 files changed, 75 insertions(+), 14 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 836cb0f..a74a4b6 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -436,7 +436,25 @@ destroy_lseg(struct kref *kref)
>> =A0 =A0 =A0 PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
>> =A0}
>>
>> -static inline void
>> +static void
>> +put_lseg_locked(struct pnfs_layout_segment *lseg)
>> +{
>> + =A0 =A0 bool do_wake_up;
>> + =A0 =A0 struct nfs_inode *nfsi;
>> +
>> + =A0 =A0 if (!lseg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&lseg->kref.refcount), lseg->v=
alid);
>> + =A0 =A0 do_wake_up =3D !lseg->valid;
>> + =A0 =A0 nfsi =3D PNFS_NFS_INODE(lseg->layout);
>> + =A0 =A0 kref_put(&lseg->kref, destroy_lseg);
>> + =A0 =A0 if (do_wake_up)
>> + =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&nfsi->lo_waitq);
>> +}
>> +
>> +void
>> =A0put_lseg(struct pnfs_layout_segment *lseg)
>> =A0{
>> =A0 =A0 =A0 bool do_wake_up;
>> @@ -449,7 +467,9 @@ put_lseg(struct pnfs_layout_segment *lseg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_read(&lseg->kref.refcount), lseg-=
>valid);
>> =A0 =A0 =A0 do_wake_up =3D !lseg->valid;
>> =A0 =A0 =A0 nfsi =3D PNFS_NFS_INODE(lseg->layout);
>> + =A0 =A0 lock_current_layout(nfsi);
>> =A0 =A0 =A0 kref_put(&lseg->kref, destroy_lseg);
>> + =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 if (do_wake_up)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up(&nfsi->lo_waitq);
>> =A0}
>> @@ -674,7 +694,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg, lseg->range.iomode=
, lseg->range.offset,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg->range.length);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&lseg->fi_list);
>> - =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(lseg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_lseg_locked(lseg);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 dprintk("%s:Return\n", __func__);
>> @@ -1033,7 +1053,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (lseg->valid || !only_valid)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D lseg;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (take_ref)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&=
ret->kref);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_lseg(r=
et);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cmp_layout(range, &lseg->range) > 0)
>> @@ -1053,7 +1073,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
>> =A0 * returned to the caller.
>> =A0 */
>> =A0int
>> -pnfs_update_layout(struct inode *ino,
>> +_pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_open_context *ctx,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u64 count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t pos,
>> @@ -1085,8 +1105,7 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 lseg =3D pnfs_has_layout(lo, &arg, take_ref, !take_ref);
>> =A0 =A0 =A0 if (lseg && !lseg->valid) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (take_ref)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(lseg);
>> -
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg_locked(lseg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* someone is cleaning the layout */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg =3D NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 result =3D -EAGAIN;
>> @@ -1262,7 +1281,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget=
 *lgp)
>> =A0 =A0 =A0 init_lseg(lo, lseg);
>> =A0 =A0 =A0 lseg->range =3D res->lseg;
>> =A0 =A0 =A0 if (lgp->lsegpp) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&lseg->kref);
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_lseg(lseg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 *lgp->lsegpp =3D lseg;
>> =A0 =A0 =A0 }
>>
>> @@ -1380,7 +1399,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descri=
ptor *pgio,
>> =A0 =A0 =A0 readahead_range(inode, pages, &loff, &count);
>>
>> =A0 =A0 =A0 if (count > 0) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_update_layout(inode, ctx, =
count,
>> + =A0 =A0 =A0 =A0 =A0 =A0 status =3D _pnfs_update_layout(inode, ctx,=
 count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 loff, IOMODE_READ, NULL);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s virt update returned %d\n", =
__func__, status);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status !=3D 0)
>> @@ -1438,7 +1457,7 @@ pnfs_update_layout_commit(struct inode *inode,
>> =A0 =A0 =A0 if (start =3D=3D 0 && count =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count =3D NFS4_MAX_UINT64;
>>
>> - =A0 =A0 status =3D pnfs_update_layout(inode, nfs_page->wb_context,
>> + =A0 =A0 status =3D _pnfs_update_layout(inode, nfs_page->wb_context=
,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IOMODE_R=
W,
>> @@ -1538,7 +1557,7 @@ pnfs_file_write(struct file *filp, const char =
__user *buf, size_t count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> =A0 =A0 =A0 /* Retrieve and set layout if not allready cached */
>> - =A0 =A0 status =3D pnfs_update_layout(inode,
>> + =A0 =A0 status =3D _pnfs_update_layout(inode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
context,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
*pos,
>> @@ -1580,7 +1599,7 @@ pnfs_writepages(struct nfs_write_data *wdata, =
int how)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->offset);
>>
>> =A0 =A0 =A0 /* Retrieve and set layout if not allready cached */
>> - =A0 =A0 status =3D pnfs_update_layout(inode,
>> + =A0 =A0 status =3D _pnfs_update_layout(inode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->context,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->offset,
>> @@ -1681,7 +1700,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->offset);
>>
>> =A0 =A0 =A0 /* Retrieve and set layout if not allready cached */
>> - =A0 =A0 status =3D pnfs_update_layout(inode,
>> + =A0 =A0 status =3D _pnfs_update_layout(inode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->context,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
args->offset,
>> @@ -1845,7 +1864,7 @@ pnfs_commit(struct nfs_write_data *data, int s=
ync)
>> =A0 =A0 =A0 =A0 =A0new one. =A0If it was recalled we better commit t=
he data first
>> =A0 =A0 =A0 =A0 =A0before returning it, otherwise the data needs to =
be rewritten,
>> =A0 =A0 =A0 =A0 =A0either with a new layout or to the MDS */
>> - =A0 =A0 result =3D pnfs_update_layout(data->inode,
>> + =A0 =A0 result =3D _pnfs_update_layout(data->inode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
NULL,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
first->wb_offset,
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 214d567..6326ed5 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -31,7 +31,8 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnf=
s_layoutreturn *lrp, bool wait
>> =A0/* pnfs.c */
>> =A0extern const nfs4_stateid zero_stateid;
>>
>> -int pnfs_update_layout(struct inode *ino, struct nfs_open_context *=
ctx,
>> +void put_lseg(struct pnfs_layout_segment *lseg);
>> +int _pnfs_update_layout(struct inode *ino, struct nfs_open_context =
*ctx,
>> =A0 =A0 =A0 u64 count, loff_t pos, enum pnfs_iomode access_type,
>> =A0 =A0 =A0 struct pnfs_layout_segment **lsegpp);
>>
>> @@ -81,6 +82,12 @@ static inline int lo_fail_bit(u32 iomode)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NFS_INO_RW_LAYOUT_FAI=
LED : NFS_INO_RO_LAYOUT_FAILED;
>> =A0}
>>
>> +static inline void get_lseg(struct pnfs_layout_segment *lseg)
>> +{
>> + =A0 =A0 if (lseg)
>
> Really? That in my experience is a shoot in the foot.
>
> I don't believe any code that decided to get an lseg could get there =
without one.
> if so I want to crash.
>
> From all instances of =A0get_lseg in this patch they already ask.
>

It is needed by one instance from the following patch.  I can change th=
is.

=46red

>> + =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&lseg->kref);
>> +}
>> +
>> =A0/* Return true if a layout driver is being used for this mountpoi=
nt */
>> =A0static inline int pnfs_enabled_sb(struct nfs_server *nfss)
>> =A0{
>> @@ -170,6 +177,23 @@ static inline int pnfs_return_layout(struct ino=
de *ino,
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +static inline int pnfs_update_layout(struct inode *ino,
>> + =A0 =A0 struct nfs_open_context *ctx,
>> + =A0 =A0 u64 count, loff_t pos, enum pnfs_iomode access_type,
>> + =A0 =A0 struct pnfs_layout_segment **lsegpp)
>> +{
>> + =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(ino);
>> +
>> + =A0 =A0 if (pnfs_enabled_sb(nfss))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return _pnfs_update_layout(ino, ctx, count=
, pos,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0access_type, lsegpp);
>> + =A0 =A0 else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (lsegpp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *lsegpp =3D NULL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 }
>> +}
>> +
>> =A0static inline int pnfs_get_write_status(struct nfs_write_data *da=
ta)
>> =A0{
>> =A0 =A0 =A0 return data->pdata.pnfs_error;
>> @@ -190,6 +214,24 @@ static inline int pnfs_use_rpc(struct nfs_serve=
r *nfss)
>>
>> =A0#else =A0/* CONFIG_NFS_V4_1 */
>>
>> +static inline void get_lseg(struct pnfs_layout_segment *lseg)
>> +{
>> +}
>> +
>> +static inline void put_lseg(struct pnfs_layout_segment *lseg)
>> +{
>> +}
>> +
>> +static inline int
>> +pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>> + =A0 =A0 u64 count, loff_t pos, enum pnfs_iomode access_type,
>> + =A0 =A0 struct pnfs_layout_segment **lsegpp)
>> +{
>> + =A0 =A0 if (lsegpp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 *lsegpp =3D NULL;
>> + =A0 =A0 return 0;
>> +}
>> +
>> =A0static inline enum pnfs_try_status
>> =A0pnfs_try_to_read_data(struct nfs_read_data *data,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct rpc_call_ops *c=
all_ops)
>
> Comments aside. Good needed stuff
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
