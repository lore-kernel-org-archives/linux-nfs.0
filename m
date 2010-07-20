From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 4/7] SQUASHME pnfs-submit consolidate write_pagelist
	parameters
Date: Tue, 20 Jul 2010 09:51:59 -0400
Message-ID: <AANLkTi=SoitJGpJOL0ecP1oB08nJstFtELewDt8ubT9G@mail.gmail.com>
References: <1279210434-2772-1-git-send-email-andros@netapp.com>
	<1279210434-2772-2-git-send-email-andros@netapp.com>
	<1279210434-2772-3-git-send-email-andros@netapp.com>
	<1279210434-2772-4-git-send-email-andros@netapp.com>
	<1279210434-2772-5-git-send-email-andros@netapp.com>
	<4C45257D.7000507@panasas.com>
	<4C452736.7010201@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64628 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab0GTNwA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 09:52:00 -0400
Received: by iwn7 with SMTP id 7so5765125iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jul 2010 06:51:59 -0700 (PDT)
In-Reply-To: <4C452736.7010201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ah - I see now. OK - numpages in write_pagelist.

-->Andy

On Tue, Jul 20, 2010 at 12:33 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> On Jul. 20, 2010, 7:26 +0300, Benny Halevy <bhalevy@panasas.com> wrot=
e:
>> On Jul. 15, 2010, 19:13 +0300, andros@netapp.com wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Remove the numpages calculation which is not used by the file layou=
t driver.
>>> Layout drivers that need the number of pages can call nfs_page_arra=
y_len in
>>> their write_pagelist operation.
>>>
>>> NOTE: API change.
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 24 +++--------------=
-------
>>> =A0include/linux/nfs4_pnfs.h | =A0 =A05 +----
>>> =A02 files changed, 4 insertions(+), 25 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 576946b..51bd66f 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -1271,39 +1271,21 @@ enum pnfs_try_status
>>> =A0pnfs_try_to_write_data(struct nfs_write_data *wdata,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct rpc_call_op=
s *call_ops, int how)
>>> =A0{
>>> - =A0 =A0struct nfs_writeargs *args =3D &wdata->args;
>>> =A0 =A0 =A0struct inode *inode =3D wdata->inode;
>>> =A0 =A0 =A0enum pnfs_try_status trypnfs;
>>> =A0 =A0 =A0struct nfs_server *nfss =3D NFS_SERVER(inode);
>>> - =A0 =A0struct nfs_inode *nfsi =3D NFS_I(inode);
>>> =A0 =A0 =A0struct pnfs_layout_segment *lseg =3D wdata->req->wb_lseg=
;
>>> - =A0 =A0int numpages;
>>>
>>> =A0 =A0 =A0wdata->pdata.call_ops =3D call_ops;
>>> =A0 =A0 =A0wdata->pdata.how =3D how;
>>>
>>> - =A0 =A0dprintk("%s: Writing ino:%lu %u@%llu\n", __func__,
>>> - =A0 =A0 =A0 =A0 =A0 =A0inode->i_ino, args->count, args->offset);
>>> + =A0 =A0dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__=
,
>>> + =A0 =A0 =A0 =A0 =A0 =A0inode->i_ino, wdata->args.count, wdata->ar=
gs.offset, how);
>>>
>>> =A0 =A0 =A0get_lseg(lseg);
>>>
>>> - =A0 =A0/* Determine number of pages
>>> - =A0 =A0 */
>>> - =A0 =A0numpages =3D nfs_page_array_len(args->pgbase, args->count)=
;
>>
>> Andy, removing this from the interface is a bit problematic
>> since nfs_page_array_len is private to the nfs module and I want to =
leave
>> the logic there rather than copying it to the layout driver.
>> Also, we still pass in its equivalent to read_pagelist so for symmet=
ry
>> reasons it would be cleaner to pass to to the write path as well.
>
> and we should use nfs_page_array_len for the read path as well.
> In any case the calculation is straight forward so we should either d=
o
> it in the generic layer in both cases or neither.
>
> Benny
>
>>
>> Benny
>>
>>> -
>>> - =A0 =A0dprintk("%s: Calling layout driver (how %d) write with %d =
pages\n",
>>> - =A0 =A0 =A0 =A0 =A0 =A0__func__, how, numpages);
>>> -
>>> =A0 =A0 =A0wdata->pdata.lseg =3D lseg;
>>> - =A0 =A0trypnfs =3D nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nfsi->layout,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->pages,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->pgbase,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0numpages,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(loff_t)args->offset,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->count,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0how,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wdata);
>>> + =A0 =A0trypnfs =3D nfss->pnfs_curr_ld->ld_io_ops->write_pagelist(=
wdata, how);
>>>
>>> =A0 =A0 =A0if (trypnfs =3D=3D PNFS_NOT_ATTEMPTED) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0wdata->pdata.lseg =3D NULL;
>>> diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
>>> index b379225..13f71ad 100644
>>> --- a/include/linux/nfs4_pnfs.h
>>> +++ b/include/linux/nfs4_pnfs.h
>>> @@ -130,10 +130,7 @@ struct layoutdriver_io_operations {
>>> =A0 =A0 =A0enum pnfs_try_status
>>> =A0 =A0 =A0(*read_pagelist) (struct nfs_read_data *nfs_data, unsign=
ed nr_pages);
>>> =A0 =A0 =A0enum pnfs_try_status
>>> - =A0 =A0(*write_pagelist) (struct pnfs_layout_type *layoutid,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages, =
unsigned int pgbase,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned nr_pages, lo=
ff_t offset, size_t count,
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int sync, struct nfs_=
write_data *nfs_data);
>>> + =A0 =A0(*write_pagelist) (struct nfs_write_data *nfs_data, int ho=
w);
>>>
>>> =A0 =A0 =A0/* Consistency ops */
>>> =A0 =A0 =A0/* 2 problems:
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
