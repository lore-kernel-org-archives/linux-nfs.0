Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:41072 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab1GTFw4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jul 2011 01:52:56 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <bhalevy@tonian.com>, <bergwolf@gmail.com>
Date: Wed, 20 Jul 2011 01:52:39 -0400
Subject: RE: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
Message-ID: <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
 <4E18614C.4010002@tonian.com>
In-Reply-To: <4E18614C.4010002@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Trond,

Any comments on this patch? I still get kernel crash when pnfs write is attempted but fails and calls pnfs_ld_write_done(). It seems object layout uses the same code path as well. But I don't find the patch in either your tree or Benny's tree. Are there any concerns?

Thanks,
Tao

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Saturday, July 09, 2011 10:10 PM
> To: Peng Tao
> Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Peng, Tao
> Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
> 
> On 2011-07-04 04:30, Peng Tao wrote:
> > There is no need to keep lseg reference when read/write through MDS.
> > This fixes a null pointer crash at nfs_post_op_update_inode_force_wcc
> > because nfs4_proc_write_setup will unset wdata->res.fattr if wdata->lseg
> > is not NULL.
> >
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> 
> Looks good to me.
> 
> Benny
> 
> > ---
> >  fs/nfs/pnfs.c |    6 ++++++
> >  1 files changed, 6 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 30a0394..55fdf02 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -1193,6 +1193,9 @@ pnfs_ld_write_done(struct nfs_write_data *data)
> >
> >  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> >  		data->pnfs_error);
> > +
> > +	put_lseg(data->lseg);
> > +	data->lseg = NULL;
> >  	status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
> >  				    data->mds_ops, NFS_FILE_SYNC);
> >  	return status ? : -EAGAIN;
> > @@ -1240,6 +1243,9 @@ pnfs_ld_read_done(struct nfs_read_data *data)
> >
> >  	dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
> >  		data->pnfs_error);
> > +
> > +	put_lseg(data->lseg);
> > +	data->lseg = NULL;
> >  	status = nfs_initiate_read(data, NFS_CLIENT(data->inode),
> >  				   data->mds_ops);
> >  	return status ? : -EAGAIN;

