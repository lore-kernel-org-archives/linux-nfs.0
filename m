Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26101 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab1GMOIl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2011 10:08:41 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 6/8] NFS: Move the pnfs read code into pnfs.c
Date: Wed, 13 Jul 2011 07:08:36 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A295976@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4E1DA063.70102@tonian.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com> <1310498994-12685-7-git-send-email-Trond.Myklebust@netapp.com> <4E1DA063.70102@tonian.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Benny Halevy" <bhalevy@tonian.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Wednesday, July 13, 2011 9:41 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 6/8] NFS: Move the pnfs read code into pnfs.c
> 
> On 2011-07-12 22:29, Trond Myklebust wrote:
> > ...and ensure that we recoalese to take into account differences in
> > block sizes when falling back to read through the MDS.
> >
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/internal.h            |    4 +++
> >  fs/nfs/nfs4filelayout.c      |    2 +-
> >  fs/nfs/objlayout/objio_osd.c |    2 +-
> >  fs/nfs/pnfs.c                |   57
> ++++++++++++++++++++++++++++++++++++++++-
> >  fs/nfs/pnfs.h                |   10 +------
> >  fs/nfs/read.c                |   46
++++++++++++++------------------
> -
> >  include/linux/nfs_page.h     |    1 -
> >  7 files changed, 82 insertions(+), 40 deletions(-)
> >
> > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> > index 31e8b50..795b3e0 100644
> > --- a/fs/nfs/internal.h
> > +++ b/fs/nfs/internal.h
> > @@ -295,10 +295,14 @@ extern int nfs4_get_rootfh(struct nfs_server
> *server, struct nfs_fh *mntfh);
> >  extern int nfs_initiate_read(struct nfs_read_data *data, struct
> rpc_clnt *clnt,
> >  			     const struct rpc_call_ops *call_ops);
> >  extern void nfs_read_prepare(struct rpc_task *task, void
*calldata);
> > +extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
> > +		struct list_head *head);
> >
> >  struct nfs_pageio_descriptor;
> >  extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor
> *pgio,
> >  		struct inode *inode);
> > +extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor
> *pgio);
> > +extern void nfs_readdata_release(struct nfs_read_data *rdata);
> >
> >  /* write.c */
> >  extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor
> *pgio,
> > diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> > index af9bf9e..fc556d6 100644
> > --- a/fs/nfs/nfs4filelayout.c
> > +++ b/fs/nfs/nfs4filelayout.c
> > @@ -735,7 +735,7 @@ filelayout_pg_init_write(struct
> nfs_pageio_descriptor *pgio,
> >  static const struct nfs_pageio_ops filelayout_pg_read_ops = {
> >  	.pg_init = filelayout_pg_init_read,
> >  	.pg_test = filelayout_pg_test,
> > -	.pg_doio = nfs_generic_pg_readpages,
> > +	.pg_doio = pnfs_generic_pg_readpages,
> >  };
> >
> >  static const struct nfs_pageio_ops filelayout_pg_write_ops = {
> > diff --git a/fs/nfs/objlayout/objio_osd.c
> b/fs/nfs/objlayout/objio_osd.c
> > index 70272d5..add6289 100644
> > --- a/fs/nfs/objlayout/objio_osd.c
> > +++ b/fs/nfs/objlayout/objio_osd.c
> > @@ -1007,7 +1007,7 @@ static bool objio_pg_test(struct
> nfs_pageio_descriptor *pgio,
> >  static const struct nfs_pageio_ops objio_pg_read_ops = {
> >  	.pg_init = pnfs_generic_pg_init_read,
> >  	.pg_test = objio_pg_test,
> > -	.pg_doio = nfs_generic_pg_readpages,
> > +	.pg_doio = pnfs_generic_pg_readpages,
> >  };
> >
> >  static const struct nfs_pageio_ops objio_pg_write_ops = {
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 5b3cc3f..9eca5a8 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -28,6 +28,7 @@
> >   */
> >
> >  #include <linux/nfs_fs.h>
> > +#include <linux/nfs_page.h>
> >  #include "internal.h"
> >  #include "pnfs.h"
> >  #include "iostat.h"
> > @@ -1216,18 +1217,32 @@ pnfs_ld_read_done(struct nfs_read_data
*data)
> >  }
> >  EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
> >
> > +static void
> > +pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
> > +		struct nfs_read_data *data)
> > +{
> > +	list_splice_tail_init(&data->pages, &desc->pg_list);
> > +	if (data->req && list_empty(&data->req->wb_list))
> > +		nfs_list_add_request(data->req, &desc->pg_list);
> > +	nfs_pageio_reset_read_mds(desc);
> > +	desc->pg_recoalesce = 1;
> > +	nfs_readdata_release(data);
> 
> I'm confused...
> Isn't this function supposed to call the nfs read path?
>

No. The reason for doing the above is to avoid recursing back into the
read/write code when we're already deep down in the stack.

Instead, we put the requests back on the pg_list, set the pg_recoalesce
flag, and then allow nfs_do_recoalesce() (which runs much further back
up the stack) to do it's job.

Cheers
  Trond


