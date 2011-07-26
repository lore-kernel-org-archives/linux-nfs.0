Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56902 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1GZPhe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 11:37:34 -0400
Received: by vxh35 with SMTP id 35so397789vxh.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 08:37:33 -0700 (PDT)
In-Reply-To: <1311621204.28209.14.camel@lade.trondhjem.org>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
 <4E18614C.4010002@tonian.com> <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com>
 <1311621204.28209.14.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 26 Jul 2011 23:37:13 +0800
Message-ID: <CA+a=Yy59HXXjd4HgrqeANaQZKO9rRPKzM+r3NNq2KSMV_L4S_w@mail.gmail.com>
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: tao.peng@emc.com, linux-nfs@vger.kernel.org, bhalevy@tonian.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Trond,

On Tue, Jul 26, 2011 at 3:13 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2011-07-20 at 01:52 -0400, tao.peng@emc.com wrote:
>> Hi, Trond,
>>
>> Any comments on this patch? I still get kernel crash when pnfs write is attempted but fails and calls pnfs_ld_write_done(). It seems object layout uses the same code path as well. But I don't find the patch in either your tree or Benny's tree. Are there any concerns?
>>
>> Thanks,
>> Tao
>
> The whole pnfs_ld_write_done thing is bogus and needs to be replaced
> with something sane. It is trying to initiate a WRITE RPC call with the
> wrong block size, and is calling the MDS rpc_call_done() and
> rpc_release() with an uninitialised rpc task pointer.
>
> Ditto for pnfs_ld_read_done.
Thanks for your explanation. Is there any plan on how to fix
pnfs_ld_read/write_done? Basically, we would need an interface that
can redirect the IO to MDS if pnfs_error is set or do all necessary
cleanup work to end read/write if pnfs_error is 0. IMHO, the
recoalesce logic need to access nfs_pageio_descriptor but we do not
have that information at pnfs_ld_read/write_done.

Best,
Tao

>
> Cheers
>  Trond
>
>> > -----Original Message-----
>> > From: Benny Halevy [mailto:bhalevy@tonian.com]
>> > Sent: Saturday, July 09, 2011 10:10 PM
>> > To: Peng Tao
>> > Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Peng, Tao
>> > Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
>> >
>> > On 2011-07-04 04:30, Peng Tao wrote:
>> > > There is no need to keep lseg reference when read/write through MDS.
>> > > This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
>> > > because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
>> > > is not NULL.
>> > >
>> > > Signed-off-by: Peng Tao <peng_tao@emc.com>
>> >
>> > Looks good to me.
>> >
>> > Benny
>> >
>> > > ---
>> > >  fs/nfs/pnfs.c |    6 ++++++
>> > >  1 files changed, 6 insertions(+), 0 deletions(-)
>> > >
>> > > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> > > index 30a0394..55fdf02 100644
>> > > --- a/fs/nfs/pnfs.c
>> > > +++ b/fs/nfs/pnfs.c
>> > > @@ -1193,6 +1193,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>> > >
>> > >   dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>> > >           data->pnfs_error);
>> > > +
>> > > + put_lseg(data->lseg);
>> > > + data->lseg = NULL;
>> > >   status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>> > >                               data->mds_ops, NFS_FILE_SYNC);
>> > >   return status ? : -EAGAIN;
>> > > @@ -1240,6 +1243,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
>> > >
>> > >   dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>> > >           data->pnfs_error);
>> > > +
>> > > + put_lseg(data->lseg);
>> > > + data->lseg = NULL;
>> > >   status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
>> > >                              data->mds_ops);
>> > >   return status ? : -EAGAIN;
>>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>
