From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: Re: [RFC][PATCH] pnfs: unlock lo_lock spinlock before calling
	specific layoutdriver's setup_layoutcommit() operation.
Date: Fri, 21 May 2010 01:13:20 +0800
Message-ID: <AANLkTinXG7If279YbhZr9ZDFiwz6cL2YriEtxztCGILW@mail.gmail.com>
References: <20100520102507.GA31886@vmware>
	 <EF83AA1C-3AC6-4E78-BC5F-A3075E04E07D@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38628 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803Ab0ETRNV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 13:13:21 -0400
Received: by vws9 with SMTP id 9so58117vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 10:13:20 -0700 (PDT)
In-Reply-To: <EF83AA1C-3AC6-4E78-BC5F-A3075E04E07D@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 21, 2010 at 12:13 AM, Andy Adamson <andros@netapp.com> wrot=
e:
>
> On May 20, 2010, at 6:25 AM, Tao Guo wrote:
>
>> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
>> allocation in bl_setup_layoutcommit().
>>
>> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>> ---
>> fs/nfs/pnfs.c | =C2=A0 42 +++++++++++++++++++++---------------------
>> 1 files changed, 21 insertions(+), 21 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index aedda1e..8474731 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -2073,15 +2073,23 @@ pnfs_layoutcommit_done(struct
>> pnfs_layoutcommit_data *data)
>> =C2=A0* Set up the argument/result storage required for the RPC call=
=2E
>> =C2=A0*/
>> static int
>> -pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sy=
nc)
>> +pnfs_layoutcommit_setup(struct inode *inode,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 struct pnfs_layoutcommit_data *data, int sync)
>> {
>> - =C2=A0 =C2=A0 =C2=A0 struct nfs_inode *nfsi =3D NFS_I(data->args.i=
node);
>> - =C2=A0 =C2=A0 =C2=A0 struct nfs_server *nfss =3D NFS_SERVER(data->=
args.inode);
>> + =C2=A0 =C2=A0 =C2=A0 struct nfs_inode *nfsi =3D NFS_I(inode);
>> + =C2=A0 =C2=A0 =C2=A0 struct nfs_server *nfss =3D NFS_SERVER(inode)=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int result =3D 0;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s Begin (sync:%d)\n", __func__,=
 sync);
>> + =C2=A0 =C2=A0 =C2=A0 data->is_sync =3D sync;
>> + =C2=A0 =C2=A0 =C2=A0 data->cred =C2=A0=3D nfsi->layoutcommit_ctx->=
cred;
>> + =C2=A0 =C2=A0 =C2=A0 data->ctx =3D nfsi->layoutcommit_ctx;
>> + =C2=A0 =C2=A0 =C2=A0 data->args.inode =3D inode;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->args.fh =3D NFS_FH(data->args.inode=
);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->args.layout_type =3D nfss->pnfs_cur=
r_ld->id;
>> + =C2=A0 =C2=A0 =C2=A0 pnfs_get_layout_stateid(&data->args.stateid, =
&nfsi->layout);
>> + =C2=A0 =C2=A0 =C2=A0 data->res.fattr =3D &data->fattr;
>> + =C2=A0 =C2=A0 =C2=A0 nfs_fattr_init(&data->fattr);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* TODO: Need to determine the correct va=
lues */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->args.time_modify_changed =3D 0;
>> @@ -2095,6 +2103,7 @@ pnfs_layoutcommit_setup(struct
>> pnfs_layoutcommit_data *data, int sync)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i=
_size_read(&nfsi->vfs_inode) - 1);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->args.bitmask =3D nfss->attr_bitmask=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0data->res.server =3D nfss;
>> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&nfsi->lo_lock);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Call layout driver to set the argument=
s.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> @@ -2104,10 +2113,6 @@ pnfs_layoutcommit_setup(struct
>> pnfs_layoutcommit_data *data, int sync)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (result)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto out;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> - =C2=A0 =C2=A0 =C2=A0 pnfs_get_layout_stateid(&data->args.stateid, =
&nfsi->layout);
>> - =C2=A0 =C2=A0 =C2=A0 data->res.fattr =3D &data->fattr;
>> - =C2=A0 =C2=A0 =C2=A0 nfs_fattr_init(&data->fattr);
>> -
>> out:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s End Status %d\n", __func__, r=
esult);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return result;
>> @@ -2131,36 +2136,31 @@ pnfs_layoutcommit_inode(struct inode *inode,=
 int
>> sync)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -ENOME=
M;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&nfsi->lo_lock);
>> - =C2=A0 =C2=A0 =C2=A0 if (!nfsi->layoutcommit_ctx)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
>> -
>> - =C2=A0 =C2=A0 =C2=A0 data->args.inode =3D inode;
>> - =C2=A0 =C2=A0 =C2=A0 data->cred =C2=A0=3D nfsi->layoutcommit_ctx->=
cred;
>> - =C2=A0 =C2=A0 =C2=A0 data->ctx =3D nfsi->layoutcommit_ctx;
>> + =C2=A0 =C2=A0 =C2=A0 if (!nfsi->layoutcommit_ctx) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&nfsi=
->lo_lock);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_free;
>> + =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 =C2=A0 /* Set up layout commit args*/
>> - =C2=A0 =C2=A0 =C2=A0 status =3D pnfs_layoutcommit_setup(data, sync=
);
>> + =C2=A0 =C2=A0 =C2=A0 /* Set up layout commit args */
>> + =C2=A0 =C2=A0 =C2=A0 status =3D pnfs_layoutcommit_setup(inode, dat=
a, sync);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (status)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_free;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Clear layoutcommit properties in the i=
node so
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * new lc info can be generated
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&nfsi->lo_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_begin_pos =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->pnfs_write_end_pos =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0nfsi->layoutcommit_ctx =3D NULL;
>
> These should be cleared before the spin_lock is released in
> pnfs_layoutcommit_setup.
> They should be cleared (and the layoutcommit_cxt put) upon a layoutdr=
iver
> setup_layoutcommit failure.
>
> -->Andy
I just followed the old code's logic: if a layoutdriver's
setup_layoutcommit call failed(like return -ENOMEM), we just keep
nfs_inode's everything unchanged, so maybe next time we can try again
later. However, this will lead to lock lo_lock two times as in the
above code.
Maybe I should break the code's logic...
>>
>> -
>> - =C2=A0 =C2=A0 =C2=A0 /* release lock on pnfs layoutcommit attrs */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&nfsi->lo_lock);
>>
>> - =C2=A0 =C2=A0 =C2=A0 data->is_sync =3D sync;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0status =3D pnfs4_proc_layoutcommit(data);
>> out:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s end (err:%d)\n", __func__, st=
atus);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return status;
>> -out_unlock:
>> +out_free:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0pnfs_layoutcommit_free(data);
>> - =C2=A0 =C2=A0 =C2=A0 spin_unlock(&nfsi->lo_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
>> }
>>
>> --
>> 1.6.3.3



--=20
tao.
