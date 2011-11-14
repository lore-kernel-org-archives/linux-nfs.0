Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37333 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab1KNPty convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 10:49:54 -0500
Message-ID: <1321285777.2632.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH] NFS: Revert pnfs ugliness from the generic NFS read
 code path
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Nov 2011 17:49:37 +0200
In-Reply-To: <4EC0F7AF.3010904@tonian.com>
References: <1320953896-20898-1-git-send-email-Trond.Myklebust@netapp.com>
	 <4EC0F7AF.3010904@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-14 at 13:12 +0200, Benny Halevy wrote: 
> On 2011-11-10 21:38, Trond Myklebust wrote:
> > pNFS-specific code belongs in the pnfs layer. It should not be
> > hijacking generic NFS read or write code paths.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/internal.h |    2 ++
> >  fs/nfs/pnfs.c     |   26 +++++++++++++++++++++-----
> >  fs/nfs/read.c     |   14 ++------------
> >  3 files changed, 25 insertions(+), 17 deletions(-)
> > 
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index c1a1bd8..3f4d957 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -299,6 +299,8 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
> >  extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
> >  		struct list_head *head);
> >  
> > +extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
> > +		struct inode *inode);
> >  extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
> >  extern void nfs_readdata_release(struct nfs_read_data *rdata);
> >  
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index baf7353..8e672a2 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -1260,6 +1260,25 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
> >  }
> >  EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
> >  
> > +static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
> > +{
> > +	struct nfs_pageio_descriptor pgio;
> > +
> > +	put_lseg(data->lseg);
> > +	data->lseg = NULL;
> > +	dprintk("pnfs write error = %d\n", data->pnfs_error);
> 
> should be "read error", might as well fix this while you're at it :)

Sure...

> > +
> > +	nfs_pageio_init_read_mds(&pgio, data->inode);
> > +
> > +	while (!list_empty(&data->pages)) {
> > +		struct nfs_page *req = nfs_list_entry(data->pages.next);
> > +
> > +		nfs_list_remove_request(req);
> > +		nfs_pageio_add_request(&pgio, req);
> > +	}
> 
> What about pgio.pg_recoalesce?

It was incorrect to set it in the first place. This is an ordinary
coalesce...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

