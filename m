From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 13/24] pnfs_submit: read path changeover
Date: Wed, 9 Jun 2010 15:29:21 -0400
Message-ID: <AANLkTilecdPbSOJCDkGYH-X25gcZB-1fmBmU9mEpFO_y@mail.gmail.com>
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
	<1275970761-31806-13-git-send-email-iisaman@netapp.com>
	<1275970761-31806-14-git-send-email-iisaman@netapp.com>
	<4C0FE936.2090901@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57181 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab0FIT3X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 15:29:23 -0400
Received: by fxm8 with SMTP id 8so3828283fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jun 2010 12:29:21 -0700 (PDT)
In-Reply-To: <4C0FE936.2090901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 9, 2010 at 3:19 PM, Boaz Harrosh <bharrosh@panasas.com> wro=
te:
> On 06/08/2010 07:19 AM, Fred Isaman wrote:
>> Change readpages path to only call LAYOUTGET once.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> =A0fs/nfs/pagelist.c | =A0 =A02 ++
>> =A0fs/nfs/pnfs.c =A0 =A0 | =A0 37 +++++++---------------------------=
---
>> =A0fs/nfs/pnfs.h =A0 =A0 | =A0 25 ++++++++++++++++---------
>> =A03 files changed, 25 insertions(+), 39 deletions(-)
>>
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index ed647b9..c3e5a1f 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -253,6 +253,8 @@ static int nfs_can_coalesce_requests(struct nfs_=
page *prev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 if (prev->wb_pgbase + prev->wb_bytes !=3D PAGE_CACHE_SIZ=
E)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 if (req->wb_lseg !=3D prev->wb_lseg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0#ifdef CONFIG_NFS_V4_1
>> =A0 =A0 =A0 if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 2b5f6fc..692a18e 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1689,7 +1689,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
>> =A0{
>> =A0 =A0 =A0 struct nfs_readargs *args =3D &rdata->args;
>> =A0 =A0 =A0 struct inode *inode =3D rdata->inode;
>> - =A0 =A0 int numpages, status, pgcount, temp;
>> + =A0 =A0 int numpages, pgcount, temp;
>> =A0 =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(inode);
>> =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(inode);
>> =A0 =A0 =A0 struct pnfs_layout_segment *lseg;
>> @@ -1701,19 +1701,8 @@ pnfs_readpages(struct nfs_read_data *rdata)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->count,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->offset);
>>
>> - =A0 =A0 /* Retrieve and set layout if not allready cached */
>> - =A0 =A0 status =3D _pnfs_update_layout(inode,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ar=
gs->context,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ar=
gs->count,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ar=
gs->offset,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IO=
MODE_READ,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &l=
seg);
>> - =A0 =A0 if (status) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: Updating layout failed (%d), =
retry with NFS \n",
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, status);
>> - =A0 =A0 =A0 =A0 =A0 =A0 trypnfs =3D PNFS_NOT_ATTEMPTED;
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> - =A0 =A0 }
>> + =A0 =A0 lseg =3D rdata->req->wb_lseg;
>> + =A0 =A0 get_lseg(lseg);
>>
>> =A0 =A0 =A0 /* Determine number of pages. */
>> =A0 =A0 =A0 pgcount =3D args->pgbase + args->count;
>> @@ -1740,7 +1729,6 @@ pnfs_readpages(struct nfs_read_data *rdata)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rdata->pdata.lseg =3D NULL;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(lseg);
>> =A0 =A0 =A0 }
>> - out:
>> =A0 =A0 =A0 dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
>> =A0 =A0 =A0 return trypnfs;
>> =A0}
>> @@ -1749,21 +1737,10 @@ enum pnfs_try_status
>> =A0_pnfs_try_to_read_data(struct nfs_read_data *data,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct rpc_call_ops=
 *call_ops)
>> =A0{
>> - =A0 =A0 struct inode *ino =3D data->inode;
>> - =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(ino);
>> -
>> - =A0 =A0 dprintk("--> %s\n", __func__);
>> - =A0 =A0 /* Only create an rpc request if utilizing NFSv4 I/O */
>> - =A0 =A0 if (!pnfs_enabled_sb(nfss) ||
>> - =A0 =A0 =A0 =A0 !nfss->pnfs_curr_ld->ld_io_ops->read_pagelist) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("<-- %s: not using pnfs\n", __func=
__);
>> - =A0 =A0 =A0 =A0 =A0 =A0 return PNFS_NOT_ATTEMPTED;
>> - =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: Utilizing pNFS I/O\n", __func=
__);
>> - =A0 =A0 =A0 =A0 =A0 =A0 data->pdata.call_ops =3D call_ops;
>> - =A0 =A0 =A0 =A0 =A0 =A0 data->pdata.pnfs_error =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 return pnfs_readpages(data);
>> - =A0 =A0 }
>
> Wahoo, nice stuff Ha
>
> By now this can go into it's only caller.
> (And caller de-inlined, what was that all about)
>
>> + =A0 =A0 dprintk("%s: Utilizing pNFS I/O\n", __func__);
>> + =A0 =A0 data->pdata.call_ops =3D call_ops;
>> + =A0 =A0 data->pdata.pnfs_error =3D 0;
>> + =A0 =A0 return pnfs_readpages(data);
>> =A0}
>>
>> =A0enum pnfs_try_status
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 6326ed5..816ebe1 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -94,22 +94,29 @@ static inline int pnfs_enabled_sb(struct nfs_ser=
ver *nfss)
>> =A0 =A0 =A0 return nfss->pnfs_curr_ld !=3D NULL;
>> =A0}
>>
>> +static inline void _pnfs_clear_lseg_from_pages(struct list_head *he=
ad)
>> +{
>> + =A0 =A0 struct nfs_page *req;
>> +
>> + =A0 =A0 list_for_each_entry(req, head, wb_list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(req->wb_lseg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 req->wb_lseg =3D NULL;
>> + =A0 =A0 }
>> +}
>> +
>> =A0static inline enum pnfs_try_status
>> =A0pnfs_try_to_read_data(struct nfs_read_data *data,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct rpc_call_ops *c=
all_ops)
>
> Don't think this needs to be inline, whats the point?
>

The point is that it is in the header file, not a c file.

=46red

>> =A0{
>> - =A0 =A0 struct inode *inode =3D data->inode;
>> - =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(inode);
>> =A0 =A0 =A0 enum pnfs_try_status ret;
>>
>> - =A0 =A0 /* FIXME: read_pagelist should probably be mandated */
>> - =A0 =A0 if (PNFS_EXISTS_LDIO_OP(nfss, read_pagelist))
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D _pnfs_try_to_read_data(data, call_=
ops);
>> - =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D PNFS_NOT_ATTEMPTED;
>> -
>> + =A0 =A0 if (!data->req->wb_lseg)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return PNFS_NOT_ATTEMPTED;
>> + =A0 =A0 ret =3D _pnfs_try_to_read_data(data, call_ops);
>> =A0 =A0 =A0 if (ret =3D=3D PNFS_ATTEMPTED)
>> - =A0 =A0 =A0 =A0 =A0 =A0 nfs_inc_stats(inode, NFSIOS_PNFS_READ);
>> + =A0 =A0 =A0 =A0 =A0 =A0 nfs_inc_stats(data->inode, NFSIOS_PNFS_REA=
D);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 _pnfs_clear_lseg_from_pages(&data->pages);
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
