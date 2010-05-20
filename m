From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [RFC][PATCH] pnfs: unlock lo_lock spinlock before calling
	specific layoutdriver's setup_layoutcommit() operation.
Date: Thu, 20 May 2010 13:48:07 -0400
Message-ID: <AANLkTin_r8pqUDK9IAhSn73KI2y2eSItXeut1vtI-3qb@mail.gmail.com>
References: <20100520102507.GA31886@vmware>
	 <EF83AA1C-3AC6-4E78-BC5F-A3075E04E07D@netapp.com>
	 <AANLkTinXG7If279YbhZr9ZDFiwz6cL2YriEtxztCGILW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:59694 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab0ETRsI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 May 2010 13:48:08 -0400
Received: by gxk27 with SMTP id 27so58377gxk.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 10:48:07 -0700 (PDT)
In-Reply-To: <AANLkTinXG7If279YbhZr9ZDFiwz6cL2YriEtxztCGILW-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 20, 2010 at 1:13 PM, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> On Fri, May 21, 2010 at 12:13 AM, Andy Adamson <andros@netapp.com> wr=
ote:
>>
>> On May 20, 2010, at 6:25 AM, Tao Guo wrote:
>>
>>> So in blocklayoutdriver, we can use GFP_KERNEL to do memory
>>> allocation in bl_setup_layoutcommit().
>>>
>>> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>>> ---
>>> fs/nfs/pnfs.c | =A0 42 +++++++++++++++++++++---------------------
>>> 1 files changed, 21 insertions(+), 21 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index aedda1e..8474731 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -2073,15 +2073,23 @@ pnfs_layoutcommit_done(struct
>>> pnfs_layoutcommit_data *data)
>>> =A0* Set up the argument/result storage required for the RPC call.
>>> =A0*/
>>> static int
>>> -pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int s=
ync)
>>> +pnfs_layoutcommit_setup(struct inode *inode,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pnfs_layoutcom=
mit_data *data, int sync)
>>> {
>>> - =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(data->args.inode);
>>> - =A0 =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(data->args.ino=
de);
>>> + =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(inode);
>>> + =A0 =A0 =A0 struct nfs_server *nfss =3D NFS_SERVER(inode);
>>> =A0 =A0 =A0 =A0int result =3D 0;
>>>
>>> =A0 =A0 =A0 =A0dprintk("%s Begin (sync:%d)\n", __func__, sync);
>>> + =A0 =A0 =A0 data->is_sync =3D sync;
>>> + =A0 =A0 =A0 data->cred =A0=3D nfsi->layoutcommit_ctx->cred;
>>> + =A0 =A0 =A0 data->ctx =3D nfsi->layoutcommit_ctx;
>>> + =A0 =A0 =A0 data->args.inode =3D inode;
>>> =A0 =A0 =A0 =A0data->args.fh =3D NFS_FH(data->args.inode);
>>> =A0 =A0 =A0 =A0data->args.layout_type =3D nfss->pnfs_curr_ld->id;
>>> + =A0 =A0 =A0 pnfs_get_layout_stateid(&data->args.stateid, &nfsi->l=
ayout);
>>> + =A0 =A0 =A0 data->res.fattr =3D &data->fattr;
>>> + =A0 =A0 =A0 nfs_fattr_init(&data->fattr);
>>>
>>> =A0 =A0 =A0 =A0/* TODO: Need to determine the correct values */
>>> =A0 =A0 =A0 =A0data->args.time_modify_changed =3D 0;
>>> @@ -2095,6 +2103,7 @@ pnfs_layoutcommit_setup(struct
>>> pnfs_layoutcommit_data *data, int sync)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0i_size_read(&nfsi->vfs_inode) - 1);
>>> =A0 =A0 =A0 =A0data->args.bitmask =3D nfss->attr_bitmask;
>>> =A0 =A0 =A0 =A0data->res.server =3D nfss;
>>> + =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>>>
>>> =A0 =A0 =A0 =A0/* Call layout driver to set the arguments.
>>> =A0 =A0 =A0 =A0 */
>>> @@ -2104,10 +2113,6 @@ pnfs_layoutcommit_setup(struct
>>> pnfs_layoutcommit_data *data, int sync)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (result)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>>> =A0 =A0 =A0 =A0}
>>> - =A0 =A0 =A0 pnfs_get_layout_stateid(&data->args.stateid, &nfsi->l=
ayout);
>>> - =A0 =A0 =A0 data->res.fattr =3D &data->fattr;
>>> - =A0 =A0 =A0 nfs_fattr_init(&data->fattr);
>>> -
>>> out:
>>> =A0 =A0 =A0 =A0dprintk("%s End Status %d\n", __func__, result);
>>> =A0 =A0 =A0 =A0return result;
>>> @@ -2131,36 +2136,31 @@ pnfs_layoutcommit_inode(struct inode *inode=
, int
>>> sync)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>>>
>>> =A0 =A0 =A0 =A0spin_lock(&nfsi->lo_lock);
>>> - =A0 =A0 =A0 if (!nfsi->layoutcommit_ctx)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>>> -
>>> - =A0 =A0 =A0 data->args.inode =3D inode;
>>> - =A0 =A0 =A0 data->cred =A0=3D nfsi->layoutcommit_ctx->cred;
>>> - =A0 =A0 =A0 data->ctx =3D nfsi->layoutcommit_ctx;
>>> + =A0 =A0 =A0 if (!nfsi->layoutcommit_ctx) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
>>> + =A0 =A0 =A0 }
>>>
>>> - =A0 =A0 =A0 /* Set up layout commit args*/
>>> - =A0 =A0 =A0 status =3D pnfs_layoutcommit_setup(data, sync);
>>> + =A0 =A0 =A0 /* Set up layout commit args */
>>> + =A0 =A0 =A0 status =3D pnfs_layoutcommit_setup(inode, data, sync)=
;
>>> =A0 =A0 =A0 =A0if (status)
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
>>>
>>> =A0 =A0 =A0 =A0/* Clear layoutcommit properties in the inode so
>>> =A0 =A0 =A0 =A0 * new lc info can be generated
>>> =A0 =A0 =A0 =A0 */
>>> + =A0 =A0 =A0 spin_lock(&nfsi->lo_lock);
>>> =A0 =A0 =A0 =A0nfsi->pnfs_write_begin_pos =3D 0;
>>> =A0 =A0 =A0 =A0nfsi->pnfs_write_end_pos =3D 0;
>>> =A0 =A0 =A0 =A0nfsi->layoutcommit_ctx =3D NULL;
>>
>> These should be cleared before the spin_lock is released in
>> pnfs_layoutcommit_setup.
>> They should be cleared (and the layoutcommit_cxt put) upon a layoutd=
river
>> setup_layoutcommit failure.
>>
>> -->Andy
> I just followed the old code's logic: if a layoutdriver's
> setup_layoutcommit call failed(like return -ENOMEM), we just keep
> nfs_inode's everything unchanged, so maybe next time we can try again
> later.

With a chance of another call immediately which will probably fail and =
so on

> However, this will lead to lock lo_lock two times as in the
> above code.

Note that when the setup_layoutcommit call succeeds, this code changes
the logic in that the old code did not give up the spin lock before
resetting the layout properties.

> Maybe I should break the code's logic...

I think so. If the layoutdriver has an error that it can recover from,
it should do so before returning. An ENOMEM error means that things
are really bad, and that the layoutdriver won't be able to do much of
anything.

Generally, we need to review the response to layoutcommit errors.

-->Andy


>>>
>>> -
>>> - =A0 =A0 =A0 /* release lock on pnfs layoutcommit attrs */
>>> =A0 =A0 =A0 =A0spin_unlock(&nfsi->lo_lock);
>>>
>>> - =A0 =A0 =A0 data->is_sync =3D sync;
>>> =A0 =A0 =A0 =A0status =3D pnfs4_proc_layoutcommit(data);
>>> out:
>>> =A0 =A0 =A0 =A0dprintk("%s end (err:%d)\n", __func__, status);
>>> =A0 =A0 =A0 =A0return status;
>>> -out_unlock:
>>> +out_free:
>>> =A0 =A0 =A0 =A0pnfs_layoutcommit_free(data);
>>> - =A0 =A0 =A0 spin_unlock(&nfsi->lo_lock);
>>> =A0 =A0 =A0 =A0goto out;
>>> }
>>>
>>> --
>>> 1.6.3.3
>
>
>
> --
> tao.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
