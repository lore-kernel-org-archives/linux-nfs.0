From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 2/5] pNFS: recoalesce when ld read pagelist fails
Date: Thu, 11 Aug 2011 08:01:07 +0800
Message-ID: <CA+a=Yy4K5qSW2BW++XV8aNd9z_xRonvGJr1D+TyE_Z2XW8JtRg@mail.gmail.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com>
 <1312685635-1593-2-git-send-email-bergwolf@gmail.com> <4E42C5F9.50807@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org,
	Peng Tao <peng_tao@emc.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:59750 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362Ab1HKAB1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 20:01:27 -0400
Received: by vxi9 with SMTP id 9so1252224vxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:01:27 -0700 (PDT)
In-Reply-To: <4E42C5F9.50807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 11, 2011 at 1:55 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 08/06/2011 07:53 PM, Peng Tao wrote:
>> For pnfs pagelist read failure, we need to pg_recoalesce and resend
>> IO to mds.
>>
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> ---
>> =C2=A0fs/nfs/internal.h | =C2=A0 =C2=A02 ++
>> =C2=A0fs/nfs/pnfs.c =C2=A0 =C2=A0 | =C2=A0 18 ++++++++++++++----
>> =C2=A0fs/nfs/read.c =C2=A0 =C2=A0 | =C2=A0 =C2=A03 ++-
>> =C2=A03 files changed, 18 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index 62f183d..78b662e 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -307,6 +307,8 @@ extern int nfs_generic_flush(struct nfs_pageio_d=
escriptor *desc,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *h=
ead);
>> =C2=A0extern int do_nfs_writepage(struct page *page, struct writebac=
k_control *wbc,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct nfs_pageio_d=
escriptor *pgio);
>> +extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *=
pgio,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inode *inode);
>> =C2=A0extern void nfs_pageio_init_write_mds(struct nfs_pageio_descri=
ptor *pgio,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inode *inode=
, int ioflags);
>> =C2=A0extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descr=
iptor *pgio);
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 08aba45..66fc854 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1300,7 +1300,7 @@ EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
>> =C2=A0int
>> =C2=A0pnfs_ld_read_done(struct nfs_read_data *data)
>> =C2=A0{
>> - =C2=A0 =C2=A0 int status;
>> + =C2=A0 =C2=A0 struct nfs_pageio_descriptor pgio;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (!data->pnfs_error) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __nfs4_read_done_cb=
(data);
>> @@ -1309,11 +1309,21 @@ pnfs_ld_read_done(struct nfs_read_data *data=
)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 put_lseg(data->lseg);
>> + =C2=A0 =C2=A0 data->lseg =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 dprintk("%s: pnfs_error=3D%d, retry via MDS\n",=
 __func__,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 data->pnfs_error);
>> - =C2=A0 =C2=A0 status =3D nfs_initiate_read(data, NFS_CLIENT(data->=
inode),
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0data->mds_ops);
>> - =C2=A0 =C2=A0 return status ? : -EAGAIN;
>> + =C2=A0 =C2=A0 nfs_pageio_init_read_mds(&pgio, data->inode);
>> + =C2=A0 =C2=A0 pgio.pg_recoalesce =3D 1;
>> + =C2=A0 =C2=A0 while (!list_empty(&data->pages)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct nfs_page *req =3D=
 nfs_list_entry(data->pages.next);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nfs_pageio_add_request(&=
pgio, req);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 nfs_pageio_complete(&pgio);
>> + =C2=A0 =C2=A0 nfs_readdata_release(data);
>> +
>> + =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>> =C2=A0EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
>>
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index 2171c04..2484131 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -112,12 +112,13 @@ static void nfs_readpage_truncate_uninitialise=
d_page(struct nfs_read_data *data)
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0}
>>
>> -static void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *=
pgio,
>> +void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct inode *inode=
)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 nfs_pageio_init(pgio, inode, &nfs_pageio_read_o=
ps,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 NFS_SERVER(inode)->rsize, 0);
>> =C2=A0}
>> +EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
>>
>
> Here to. Who is the user of this export?
Will remove it. Thanks.

>
> Boaz
>
>> =C2=A0void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *p=
gio)
>> =C2=A0{
>
>



--=20
Thanks,
-Bergwolf
